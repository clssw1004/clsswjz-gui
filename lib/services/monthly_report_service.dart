import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';

import '../database/database.dart';
import '../enums/account_type.dart';
import '../enums/note_type.dart';
import '../manager/app_config_manager.dart';
import '../manager/database_manager.dart';
import '../manager/dao_manager.dart';
import '../drivers/driver_factory.dart';
import '../models/vo/monthly_report_vo.dart';
import '../models/vo/user_note_vo.dart';

/// 月度收支报告生成服务
class MonthlyReportService {
  final AppDatabase _db = DatabaseManager.db;

  /// 为指定账本生成指定月份的收支报告
  /// [bookId] 账本ID
  /// [year] 年份
  /// [month] 月份 (1-12)
  /// 返回生成的笔记ID，如果已存在返回null
  Future<String?> generateReport(String bookId, int year, int month) async {
    // 检查报告是否已存在
    final existing = await _findExistingReport(bookId, year, month);
    if (existing != null) return null;

    // 构建报告数据
    final report = await buildReport(bookId, year, month);
    if (report == null) return null;

    // 通过 Driver 创建笔记
    final userId = AppConfigManager.instance.userId;
    final title = '月度收支报告 —— $year年$month月';
    final result = await DriverFactory.driver.createNote(
      userId,
      bookId,
      title: title,
      noteType: NoteType.report,
      content: report.toJsonString(),
      plainContent: report.toPlainText(),
    );

    if (result.ok) {
      return result.data;
    }
    return null;
  }

  /// 重新生成报告（覆盖已有）
  Future<String?> regenerateReport(
      String bookId, int year, int month) async {
    final existing = await _findExistingReport(bookId, year, month);
    final report = await buildReport(bookId, year, month);
    if (report == null) return null;

    final userId = AppConfigManager.instance.userId;
    if (existing != null) {
      // 更新已有报告
      final result = await DriverFactory.driver.updateNote(
        userId,
        bookId,
        existing.id,
        title: '月度收支报告 —— $year年$month月',
        content: report.toJsonString(),
        plainContent: report.toPlainText(),
      );
      if (result.ok) return existing.id;
      return null;
    } else {
      // 创建新报告
      final result = await DriverFactory.driver.createNote(
        userId,
        bookId,
        title: '月度收支报告 —— $year年$month月',
        noteType: NoteType.report,
        content: report.toJsonString(),
        plainContent: report.toPlainText(),
      );
      if (result.ok) return result.data;
      return null;
    }
  }

  /// 构建报告数据
  Future<MonthlyReportVO?> buildReport(
      String bookId, int year, int month) async {
    // 计算目标月份的时间范围
    final period = _monthRange(year, month);
    final lastYear = month > 1 ? year : year - 1;
    final lastMonth = month > 1 ? month - 1 : 12;
    final prevPeriod = _monthRange(lastYear, lastMonth);

    // 并行查询目标月和上月的统计数据
    final results = await Future.wait([
      _querySummary(bookId, period.start, period.end),
      _querySummary(bookId, prevPeriod.start, prevPeriod.end),
      _queryCategoryExpenses(bookId, period.start, period.end),
      _queryCategoryExpenses(bookId, prevPeriod.start, prevPeriod.end),
      _queryDailyStats(bookId, period.start, period.end),
      _queryExpenseItems(bookId, period.start, period.end),
    ]);

    final summary = results[0] as _SummaryResult;
    final prevSummary = results[1] as _SummaryResult;
    final categoryExpenses = results[2] as List<_CategoryResult>;
    final prevCategoryExpenses = results[3] as List<_CategoryResult>;
    final dailyStats = results[4] as List<_DailyStatResult>;
    final expenseItems = results[5] as List<_ExpenseItemResult>;

    // 如果目标月没有数据，返回null
    if (summary.income == 0 && summary.expense == 0) return null;

    // 计算有支出的天数
    final daysWithData = dailyStats.length;

    // 构建 summary
    final balance = summary.income + summary.expense;
    final prevBalance = prevSummary.income + prevSummary.expense;
    final reportSummary = ReportSummary(
      totalIncome: summary.income,
      totalExpense: summary.expense,
      balance: balance,
      prevIncome: prevSummary.income,
      prevExpense: prevSummary.expense,
      prevBalance: prevBalance,
      dailyAverage: daysWithData > 0 ? summary.expense / daysWithData : 0,
    );

    // 构建分类排行（合并上月数据）
    final prevMap = {
      for (final p in prevCategoryExpenses) p.categoryCode: p
    };
    final reportCategories = categoryExpenses.map((c) {
      final prev = prevMap[c.categoryCode];
      final total = summary.expense > 0
          ? c.amount.abs() / summary.expense.abs()
          : 0.0;
      return CategoryExpenseItem(
        categoryCode: c.categoryCode,
        categoryName: c.categoryName,
        amount: c.amount.abs(),
        percentage: total * 100,
        count: c.count,
        prevAmount: prev?.amount.abs() ?? 0,
        prevCount: prev?.count ?? 0,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // 找出新增/消失的分类
    final prevCodes = prevCategoryExpenses.map((p) => p.categoryCode).toSet();
    final currentCodes = categoryExpenses.map((c) => c.categoryCode).toSet();
    final newCodes = currentCodes.difference(prevCodes);
    final disappearedCodes = prevCodes.difference(currentCodes);

    // 构建大笔支出（单笔 >= 总支出5%）
    final threshold = summary.expense.abs() * 0.05;
    final largeTxns = expenseItems
        .where((e) => e.amount.abs() >= threshold)
        .map((e) => LargeTransaction(
              date: e.date,
              categoryName: e.categoryName,
              description: e.description,
              amount: e.amount.abs(),
              percentage:
                  (e.amount.abs() / summary.expense.abs()) * 100,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // 构建预警
    final alerts = <ReportAlert>[];

    // 1. 占比越线预警（单分类 > 30%）
    for (final c in reportCategories) {
      if (c.percentage > 30 && summary.expense > 0) {
        final thresholdAmount = summary.expense.abs() * 0.3;
        alerts.add(ReportAlert(
          type: 'overThreshold',
          severity: 'warning',
          categoryName: c.categoryName,
          message: '${c.categoryName}占比 ${c.percentage.toStringAsFixed(1)}% > 建议阈值30%',
          exceededAmount: c.amount - thresholdAmount,
        ));
      }
    }

    // 2. 异常增长预警（环比 > 50% 且上月有数据）
    for (final c in reportCategories) {
      if (c.prevAmount > 0 && c.diffPercent > 0.5) {
        alerts.add(ReportAlert(
          type: 'abnormalGrowth',
          severity: 'warning',
          categoryName: c.categoryName,
          message:
              '${c.categoryName} ¥${c.amount.toStringAsFixed(2)} vs 上月 ¥${c.prevAmount.toStringAsFixed(2)}，差额 +${c.diff.toStringAsFixed(2)}',
          exceededAmount: c.diff,
          diffPercent: c.diffPercent * 100,
        ));
      }
    }

    // 3. 新增分类
    for (final c in reportCategories) {
      if (newCodes.contains(c.categoryCode)) {
        alerts.add(ReportAlert(
          type: 'newCategory',
          severity: 'info',
          categoryName: c.categoryName,
          message: '新增支出分类「${c.categoryName}」¥${c.amount.toStringAsFixed(2)}',
          exceededAmount: c.amount,
        ));
      }
    }

    // 4. 消失分类
    for (final p in prevCategoryExpenses) {
      if (disappearedCodes.contains(p.categoryCode)) {
        alerts.add(ReportAlert(
          type: 'disappearedCategory',
          severity: 'info',
          categoryName: p.categoryName,
          message:
              '消失支出分类「${p.categoryName}」上月 ¥${p.amount.abs().toStringAsFixed(2)}',
          exceededAmount: p.amount.abs(),
        ));
      }
    }

    // 构建趋势
    ReportTrends trends;
    if (dailyStats.isNotEmpty) {
      final maxStat = dailyStats.reduce(
          (a, b) => a.expense.abs() > b.expense.abs() ? a : b);
      final minStat = dailyStats
          .where((d) => d.expense.abs() > 0)
          .fold<_DailyStatResult?>(null, (prev, d) {
        if (prev == null || d.expense.abs() < prev.expense.abs()) return d;
        return prev;
      });

      trends = ReportTrends(
        dailyAverage: daysWithData > 0 ? summary.expense / daysWithData : 0,
        maxSpendDay: maxStat.date,
        maxSpendAmount: maxStat.expense.abs(),
        minSpendDay: minStat?.date,
        minSpendAmount: minStat?.expense.abs(),
      );
    } else {
      trends = const ReportTrends();
    }

    return MonthlyReportVO(
      generatedAt: DateTime.now().millisecondsSinceEpoch,
      period: ReportPeriod(year: year, month: month),
      summary: reportSummary,
      categoryExpenses: reportCategories,
      largeTransactions: largeTxns,
      alerts: alerts,
      trends: trends,
    );
  }

  /// 检查指定月份是否已有报告
  Future<UserNoteVO?> _findExistingReport(
      String bookId, int year, int month) async {
    final title = '月度收支报告 —— $year年$month月';
    final notes = await DaoManager.noteDao.listByBook(bookId, limit: 100);

    for (final note in notes) {
      if (note.title == title && note.noteType == NoteType.report.code) {
        return UserNoteVO.fromAccountNote(note, null);
      }
    }
    return null;
  }

  // ---- 内部查询方法 ----

  _Period _monthRange(int year, int month) {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    return _Period(start: start, end: end);
  }

  Future<_SummaryResult> _querySummary(
      String bookId, DateTime start, DateTime end) async {
    final startStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(start);
    final endStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(end);

    // 收入
    final incomeQuery = _db.selectOnly(_db.accountItemTable)
      ..where(_db.accountItemTable.accountBookId.equals(bookId) &
          _db.accountItemTable.type.equals(AccountItemType.income.code) &
          _db.accountItemTable.accountDate.isBetweenValues(startStr, endStr))
      ..addColumns([_db.accountItemTable.amount.sum()]);
    final incomeResult = await incomeQuery.getSingle();
    final income = incomeResult.read(_db.accountItemTable.amount.sum()) ?? 0.0;

    // 支出（不含退款）
    final expenseQuery = _db.selectOnly(_db.accountItemTable)
      ..where(_db.accountItemTable.accountBookId.equals(bookId) &
          _db.accountItemTable.type.equals(AccountItemType.expense.code) &
          _db.accountItemTable.accountDate.isBetweenValues(startStr, endStr))
      ..addColumns([_db.accountItemTable.amount.sum(), _db.accountItemTable.id.count()]);
    final expenseResult = await expenseQuery.getSingle();
    final expense = expenseResult.read(_db.accountItemTable.amount.sum()) ?? 0.0;
    final count = expenseResult.read(_db.accountItemTable.id.count()) ?? 0;

    return _SummaryResult(income: income, expense: expense, count: count);
  }

  Future<List<_CategoryResult>> _queryCategoryExpenses(
      String bookId, DateTime start, DateTime end) async {
    final startStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(start);
    final endStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(end);

    final query = _db.selectOnly(_db.accountItemTable)
      ..where(_db.accountItemTable.accountBookId.equals(bookId) &
          _db.accountItemTable.type.equals(AccountItemType.expense.code) &
          _db.accountItemTable.accountDate.isBetweenValues(startStr, endStr))
      ..addColumns([
        _db.accountItemTable.categoryCode,
        _db.accountItemTable.amount.sum(),
        _db.accountItemTable.id.count(),
      ])
      ..groupBy([_db.accountItemTable.categoryCode]);

    final rows = await query.get();
    if (rows.isEmpty) return [];

    // 解析分类名称
    final categoryCodes = rows
        .map((r) => r.read(_db.accountItemTable.categoryCode))
        .whereType<String>()
        .where((c) => c.isNotEmpty)
        .toList();

    final categoryMap = <String, String>{};
    if (categoryCodes.isNotEmpty) {
      final categories = await (_db.select(_db.accountCategoryTable)
            ..where((t) => t.code.isIn(categoryCodes)))
          .get();
      for (final c in categories) {
        categoryMap[c.code] = c.name;
      }
    }

    return rows.map((r) {
      final code = r.read(_db.accountItemTable.categoryCode) ?? '';
      return _CategoryResult(
        categoryCode: code,
        categoryName: categoryMap[code] ?? code,
        amount: r.read(_db.accountItemTable.amount.sum()) ?? 0.0,
        count: r.read(_db.accountItemTable.id.count()) ?? 0,
      );
    }).toList();
  }

  Future<List<_DailyStatResult>> _queryDailyStats(
      String bookId, DateTime start, DateTime end) async {
    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final endStr = DateFormat('yyyy-MM-dd').format(end);

    final dateQuery = _db.selectOnly(_db.accountItemTable)
      ..where(_db.accountItemTable.accountBookId.equals(bookId) &
          _db.accountItemTable.type.equals(AccountItemType.expense.code) &
          _db.accountItemTable.accountDate
              .isBetweenValues('$startStr 00:00:00', '$endStr 23:59:59'))
      ..addColumns([_db.accountItemTable.accountDate])
      ..groupBy([_db.accountItemTable.accountDate]);

    final dateResults = await dateQuery.get();
    final dates = dateResults
        .map((r) => DateFormat('yyyy-MM-dd').format(
            DateTime.parse(r.read(_db.accountItemTable.accountDate)!)))
        .toSet()
        .toList()
      ..sort();

    final result = <_DailyStatResult>[];
    for (final dateStr in dates) {
      final dayStart = '$dateStr 00:00:00';
      final dayEnd = '$dateStr 23:59:59';

      final expenseQuery = _db.selectOnly(_db.accountItemTable)
        ..where(_db.accountItemTable.accountBookId.equals(bookId) &
            _db.accountItemTable.type.equals(AccountItemType.expense.code) &
            _db.accountItemTable.accountDate.isBetweenValues(dayStart, dayEnd))
        ..addColumns([_db.accountItemTable.amount.sum()]);

      final row = await expenseQuery.getSingleOrNull();
      final expense = row?.read(_db.accountItemTable.amount.sum()) ?? 0.0;
      result.add(_DailyStatResult(date: dateStr, expense: expense));
    }
    return result;
  }

  Future<List<_ExpenseItemResult>> _queryExpenseItems(
      String bookId, DateTime start, DateTime end) async {
    final startStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(start);
    final endStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(end);

    final items = await (_db.select(_db.accountItemTable)
          ..where((t) =>
              t.accountBookId.equals(bookId) &
              t.type.equals(AccountItemType.expense.code) &
              t.accountDate.isBetweenValues(startStr, endStr))
          ..orderBy([(t) => OrderingTerm.desc(t.amount)]))
        .get();

    // 解析分类名称
    final categoryCodes = items
        .map((i) => i.categoryCode)
        .where((c) => c != null && c.isNotEmpty)
        .map((c) => c!)
        .toSet()
        .toList();

    final categoryMap = <String, String>{};
    if (categoryCodes.isNotEmpty) {
      final categories = await (_db.select(_db.accountCategoryTable)
            ..where((t) => t.code.isIn(categoryCodes)))
          .get();
      for (final c in categories) {
        categoryMap[c.code] = c.name;
      }
    }

    return items.map((i) {
      final date = i.accountDate;
      return _ExpenseItemResult(
        date: date.length >= 10 ? date.substring(0, 10) : date,
        categoryName: categoryMap[i.categoryCode ?? ''] ?? i.categoryCode ?? '未分类',
        description: i.description,
        amount: i.amount,
      );
    }).toList();
  }
}

// ---- 内部结果类型 ----

class _Period {
  final DateTime start;
  final DateTime end;
  const _Period({required this.start, required this.end});
}

class _SummaryResult {
  final double income;
  final double expense;
  final int count;
  const _SummaryResult({
    this.income = 0,
    this.expense = 0,
    this.count = 0,
  });
}

class _CategoryResult {
  final String categoryCode;
  final String categoryName;
  final double amount;
  final int count;
  const _CategoryResult({
    required this.categoryCode,
    required this.categoryName,
    this.amount = 0,
    this.count = 0,
  });
}

class _DailyStatResult {
  final String date;
  final double expense;
  const _DailyStatResult({required this.date, this.expense = 0});
}

class _ExpenseItemResult {
  final String date;
  final String categoryName;
  final String? description;
  final double amount;
  const _ExpenseItemResult({
    required this.date,
    required this.categoryName,
    this.description,
    this.amount = 0,
  });
}
