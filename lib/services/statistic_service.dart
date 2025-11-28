import '../manager/database_manager.dart';
import '../manager/user_config_manager.dart';
import '../models/common.dart';
import '../models/vo/statistic_vo.dart';
import '../models/vo/user_vo.dart';
import '../enums/account_type.dart';
import '../enums/business_type.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';

class StatisticService {
  // 统计当前用户的账本数、账目数、记账天数
  Future<OperateResult<UserStatisticVO>> getUserStatisticInfo(
      String userId) async {
    UserVO user = UserConfigManager.instance.currentUser;
    final db = DatabaseManager.db;
    // 1. 统计账本数量
    final bookCount = await (db.select(db.relAccountbookUserTable)
          ..where((tbl) => tbl.userId.equals(user.id)))
        .get()
        .then((value) => value.length);

    // 2. 统计账目数量
    final itemQuery = db.select(db.accountItemTable).join([
      leftOuterJoin(
        db.relAccountbookUserTable,
        db.relAccountbookUserTable.accountBookId.equalsExp(
          db.accountItemTable.accountBookId,
        ),
      ),
    ]);

    itemQuery.where(db.relAccountbookUserTable.userId.equals(user.id) &
        db.relAccountbookUserTable.canViewItem.equals(true));

    final itemCount = await itemQuery
        .map((row) => row.readTable(db.accountItemTable))
        .get()
        .then((value) => value.length);

    // 3. 统计记账天数(根据账目创建时间去重计算)
    final query = db.select(db.accountItemTable).join([
      leftOuterJoin(
        db.relAccountbookUserTable,
        db.relAccountbookUserTable.accountBookId.equalsExp(
          db.accountItemTable.accountBookId,
        ),
      ),
    ]);

    query.where(db.relAccountbookUserTable.userId.equals(user.id) &
        db.relAccountbookUserTable.canViewItem.equals(true));

    final days = await query
        .map((row) => row.readTable(db.accountItemTable))
        .get()
        .then((items) => items
            .map((item) => item.accountDate)
            .map((date) => date.toString().split(' ')[0])
            .toSet()
            .length);

    return OperateResult.success(UserStatisticVO(
      bookCount: bookCount,
      itemCount: itemCount,
      dayCount: days,
    ));
  }

  /// 获取最近一天的统计数据
  Future<OperateResult<BookStatisticVO>> getLastDayStatistic(
      String accountBookId, {DateTime? start, DateTime? end}) async {
    final db = DatabaseManager.db;

    // (refund subquery inlined where needed)

    // 获取最近一天的日期
    final lastDayQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          (db.accountItemTable.type.equals(AccountItemType.income.code) |
              db.accountItemTable.type.equals(AccountItemType.expense.code)))
      ..orderBy([OrderingTerm.desc(db.accountItemTable.accountDate)])
      ..limit(1)
      ..addColumns([db.accountItemTable.accountDate]);

    final lastDayResult = await lastDayQuery.getSingleOrNull();

    if (lastDayResult == null) {
      // 如果没有数据，返回空结果
      return OperateResult.success(
          const BookStatisticVO(income: 0, expense: 0, balance: 0));
    }

    final lastDay = lastDayResult.read(db.accountItemTable.accountDate) ?? '';
    // 获取最近一天的起始时间和结束时间
    final lastDayStart = '${lastDay.split(' ')[0]} 00:00:00';
    final lastDayEnd = '${lastDay.split(' ')[0]} 23:59:59';

    // 查询最近一天的收入
    final incomeQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
            db.accountItemTable.type.equals(AccountItemType.income.code) &
          db.accountItemTable.accountDate
              .isBetweenValues(
              start != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(start) : lastDayStart,
              end != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(end) : lastDayEnd,
              ))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final incomeResult = await incomeQuery.getSingle();
    final income = incomeResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 查询最近一天的退款（source='item' 且 sourceId 指向本账本中 type == expense 的账目）
    final refundQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.source.equals(BusinessType.item.code) &
            db.accountItemTable.sourceId.isInQuery(db.selectOnly(db.accountItemTable)
              ..addColumns([db.accountItemTable.id])
              ..where(db.accountItemTable.accountBookId.equals(accountBookId))
              ..where(db.accountItemTable.type.equals(AccountItemType.expense.code))) &
          db.accountItemTable.accountDate.isBetweenValues(
            start != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(start) : lastDayStart,
            end != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(end) : lastDayEnd,
          ))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final refundResult = await refundQuery.getSingle();
    final refund = refundResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 查询最近一天的支出
    final expenseQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.expense.code) &
          db.accountItemTable.accountDate
              .isBetweenValues(
                start != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(start) : lastDayStart,
                end != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(end) : lastDayEnd,
              ))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final expenseResult = await expenseQuery.getSingle();
    final expense = expenseResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 计算结余：收入 - 支出 + 退款
    final balance = income - expense + refund;

    return OperateResult.success(BookStatisticVO(
      income: income,
      expense: expense,
      balance: balance,
      date: lastDay.split(' ')[0],
    ));
  }

  /// 获取本月（从1号开始）的统计数据
  Future<OperateResult<BookStatisticVO>> getCurrentMonthStatistic(
      String accountBookId, {DateTime? start, DateTime? end}) async {
    final db = DatabaseManager.db;
    // 子查询：判定 sourceId 是否指向本账本中类型为支出的原始账目（用于识别退款）
    final refundSubQuery = db.selectOnly(db.accountItemTable)
      ..addColumns([db.accountItemTable.id])
      ..where(db.accountItemTable.accountBookId.equals(accountBookId))
      ..where(db.accountItemTable.type.equals(AccountItemType.expense.code));

    // 获取当前月份的起始日期和结束日期
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final monthStart =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(firstDayOfMonth);
    final monthEnd = DateFormat('yyyy-MM-dd HH:mm:ss').format(lastDayOfMonth);

    // 查询本月的收入
    final incomeQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.income.code) &
          db.accountItemTable.accountDate.isBetweenValues(
            start != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(start) : monthStart,
            end != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(end) : monthEnd,
          ))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final incomeResult = await incomeQuery.getSingle();
    final income = incomeResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 本月退款
    final refundQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.source.equals(BusinessType.item.code) &
          db.accountItemTable.sourceId.isInQuery(refundSubQuery) &
          db.accountItemTable.accountDate.isBetweenValues(
            start != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(start) : monthStart,
            end != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(end) : monthEnd,
          ))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final refundResult = await refundQuery.getSingle();
    final refund = refundResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 查询本月的支出
    final expenseQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.expense.code) &
          db.accountItemTable.accountDate.isBetweenValues(
            start != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(start) : monthStart,
            end != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(end) : monthEnd,
          ))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final expenseResult = await expenseQuery.getSingle();
    final expense = expenseResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 计算结余：收入 - 支出 + 退款
    final balance = income - expense + refund;

    return OperateResult.success(BookStatisticVO(
      income: income,
      expense: expense+ refund,
      balance: balance - refund,
      date: DateFormat('yyyy-MM').format(now),
    ));
  }

  /// 获取所有时间的统计数据
  Future<OperateResult<BookStatisticVO>> getAllTimeStatistic(
      String accountBookId, {DateTime? start, DateTime? end}) async {
    final db = DatabaseManager.db;
    final refundSubQuery = db.selectOnly(db.accountItemTable)
      ..addColumns([db.accountItemTable.id])
      ..where(db.accountItemTable.accountBookId.equals(accountBookId))
      ..where(db.accountItemTable.type.equals(AccountItemType.expense.code));

    // 使用SQL聚合函数直接计算收入总额
    final incomeQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.income.code) &
          (start != null && end != null
              ? db.accountItemTable.accountDate.isBetweenValues(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(start),
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(end),
                )
              : const Constant(true)))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final incomeResult = await incomeQuery.getSingle();
    final income = incomeResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 所有时间段的退款
    final refundQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.source.equals(BusinessType.item.code) &
          db.accountItemTable.sourceId.isInQuery(refundSubQuery) &
          (start != null && end != null
              ? db.accountItemTable.accountDate.isBetweenValues(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(start),
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(end),
                )
              : const Constant(true)))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final refundResult = await refundQuery.getSingle();
    final refund = refundResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 使用SQL聚合函数直接计算支出总额
    final expenseQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.expense.code) &
          (start != null && end != null
              ? db.accountItemTable.accountDate.isBetweenValues(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(start),
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(end),
                )
              : const Constant(true)))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final expenseResult = await expenseQuery.getSingle();
    final expense = expenseResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 计算结余：收入 - 支出 + 退款
    final balance = income - expense + refund;

    return OperateResult.success(BookStatisticVO(
      income: income,
      expense: expense,
      balance: balance,
    ));
  }

  /// 按照分类查询统计收入、支出各分类的金额和
  Future<OperateResult<List<CategoryStatisticGroupVO>>>
      statisticGroupByCategory(String accountBookId, {DateTime? start, DateTime? end}) async {
    final db = DatabaseManager.db;
    final refundSubQuery = db.selectOnly(db.accountItemTable)
      ..addColumns([db.accountItemTable.id])
      ..where(db.accountItemTable.accountBookId.equals(accountBookId))
      ..where(db.accountItemTable.type.equals(AccountItemType.expense.code));
    final List<CategoryStatisticGroupVO> result = [];

    // 统计收入类别
    final incomeQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.income.code) &
          (db.accountItemTable.source.equals(BusinessType.item.code) &
                  db.accountItemTable.sourceId.isInQuery(refundSubQuery))
              .not() &
          (start != null && end != null
              ? db.accountItemTable.accountDate.isBetweenValues(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(start),
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(end),
                )
              : const Constant(true)))
      ..addColumns([
        db.accountItemTable.categoryCode,
        db.accountItemTable.amount.sum(),
        db.accountItemTable.id.count(),
      ])
      ..groupBy([db.accountItemTable.categoryCode]);

    final incomeResults = await incomeQuery.get();
    if (incomeResults.isNotEmpty) {
      // 获取分类名称
      final categoryCodes = incomeResults
          .map((row) => row.read(db.accountItemTable.categoryCode))
          .whereType<String>()
          .toList();
      final categories = await (db.select(db.accountCategoryTable)
            ..where((tbl) => tbl.code.isIn(categoryCodes)))
          .get();
      final categoryMap = {for (var c in categories) c.code: c.name};

      result.add(
        CategoryStatisticGroupVO(
          itemType: AccountItemType.income,
          categoryGroupList: incomeResults.map((row) {
            final categoryCode = row.read(db.accountItemTable.categoryCode);
            return CategoryStatisticVO(
              categoryName:
                  categoryCode != null ? categoryMap[categoryCode] ?? '' : '',
              amount: row.read(db.accountItemTable.amount.sum()) ?? 0.0,
              categoryCode: categoryCode ?? '',
              count: row.read(db.accountItemTable.id.count()) ?? 0,
            );
          }).toList(),
        ),
      );
    }

    // 统计支出类别
    final expenseQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.expense.code) &
          (start != null && end != null
              ? db.accountItemTable.accountDate.isBetweenValues(
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(start),
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(end),
                )
              : const Constant(true)))
      ..addColumns([
        db.accountItemTable.categoryCode,
        db.accountItemTable.amount.sum(),
        db.accountItemTable.id.count(),
      ])
      ..groupBy([db.accountItemTable.categoryCode]);

    final expenseResults = await expenseQuery.get();
    if (expenseResults.isNotEmpty) {
      // 获取分类名称
      final categoryCodes = expenseResults
          .map((row) => row.read(db.accountItemTable.categoryCode))
          .whereType<String>()
          .toList();
      final categories = await (db.select(db.accountCategoryTable)
            ..where((tbl) => tbl.code.isIn(categoryCodes)))
          .get();
      final categoryMap = {for (var c in categories) c.code: c.name};

      result.add(
        CategoryStatisticGroupVO(
          itemType: AccountItemType.expense,
          categoryGroupList: expenseResults.map((row) {
            final categoryCode = row.read(db.accountItemTable.categoryCode);
            return CategoryStatisticVO(
              categoryName:
                  categoryCode != null ? categoryMap[categoryCode] ?? '' : '',
              amount: row.read(db.accountItemTable.amount.sum()) ?? 0.0,
              categoryCode: categoryCode ?? '',
              count: row.read(db.accountItemTable.id.count()) ?? 0,
            );
          }).toList(),
        ),
      );
    }

    return OperateResult.success(result);
  }

  /// 获取当月每天的收支统计数据
  Future<OperateResult<List<DailyStatisticVO>>> getCurrentMonthDailyStatistic(
      String accountBookId) async {
    final db = DatabaseManager.db;
    final refundSubQuery = db.selectOnly(db.accountItemTable)
      ..addColumns([db.accountItemTable.id])
      ..where(db.accountItemTable.accountBookId.equals(accountBookId))
      ..where(db.accountItemTable.type.equals(AccountItemType.expense.code));

    // 获取当前月份的起始日期和结束日期
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    final monthStart = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    final monthEnd = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);

    // 查询当月有收支记录的日期
    final dateQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.accountDate.isBetweenValues('$monthStart 00:00:00', '$monthEnd 23:59:59'))
      ..addColumns([db.accountItemTable.accountDate])
      ..groupBy([db.accountItemTable.accountDate]);

    final dateResults = await dateQuery.get();
    final List<String> datesWithData = dateResults
        .map((row) => DateFormat('yyyy-MM-dd').format(
            DateTime.parse(row.read(db.accountItemTable.accountDate)!)))
        .toSet()
        .toList()
      ..sort(); // 按日期排序

    final List<DailyStatisticVO> dailyStats = [];

    // 只为有数据的日期生成统计数据
    for (final dateStr in datesWithData) {
      final dateStart = '$dateStr 00:00:00';
      final dateEnd = '$dateStr 23:59:59';

      // 查询当天的收入
      final incomeQuery = db.selectOnly(db.accountItemTable)
        ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
            db.accountItemTable.type.equals(AccountItemType.income.code) &
            db.accountItemTable.accountDate.isBetweenValues(dateStart, dateEnd))
        ..addColumns([db.accountItemTable.amount.sum()]);

      final incomeResult = await incomeQuery.getSingleOrNull();
      final income = incomeResult?.read(db.accountItemTable.amount.sum()) ?? 0.0;

      // 查询当天的支出
      final expenseQuery = db.selectOnly(db.accountItemTable)
        ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
            db.accountItemTable.type.equals(AccountItemType.expense.code) &
            db.accountItemTable.accountDate.isBetweenValues(dateStart, dateEnd))
        ..addColumns([db.accountItemTable.amount.sum()]);

      final expenseResult = await expenseQuery.getSingleOrNull();
      final expense = expenseResult?.read(db.accountItemTable.amount.sum()) ?? 0.0;

      // 本日退款
      final refundQuery = db.selectOnly(db.accountItemTable)
        ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
            db.accountItemTable.source.equals(BusinessType.item.code) &
            db.accountItemTable.sourceId.isInQuery(refundSubQuery) &
            db.accountItemTable.accountDate.isBetweenValues(dateStart, dateEnd))
        ..addColumns([db.accountItemTable.amount.sum()]);

      final refundResult = await refundQuery.getSingleOrNull();
      final refund = refundResult?.read(db.accountItemTable.amount.sum()) ?? 0.0;

      // 计算结余：收入 - 支出 + 退款
      final balance = income - expense + refund;

      dailyStats.add(DailyStatisticVO(
        date: dateStr,
        income: income,
        expense: expense,
        balance: balance,
      ));
    }

    return OperateResult.success(dailyStats);
  }

  /// 获取当月按用户分组的记账笔数、收入、支出
  Future<OperateResult<List<UserMonthlyStatisticVO>>> getCurrentMonthUserStatistic(
      String accountBookId) async {
    final db = DatabaseManager.db;

    // 当月起止
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final monthStart = DateFormat('yyyy-MM-dd HH:mm:ss').format(firstDayOfMonth);
    final monthEnd = DateFormat('yyyy-MM-dd HH:mm:ss').format(lastDayOfMonth);

    // 以 createdBy 作为用户ID分组统计收入
    final incomeQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.income.code) &
          db.accountItemTable.accountDate.isBetweenValues(monthStart, monthEnd))
      ..addColumns([
        db.accountItemTable.createdBy,
        db.accountItemTable.amount.sum(),
        db.accountItemTable.id.count(),
      ])
      ..groupBy([db.accountItemTable.createdBy]);

    final expenseQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.expense.code) &
          db.accountItemTable.accountDate.isBetweenValues(monthStart, monthEnd))
      ..addColumns([
        db.accountItemTable.createdBy,
        db.accountItemTable.amount.sum(),
        db.accountItemTable.id.count(),
      ])
      ..groupBy([db.accountItemTable.createdBy]);

    final incomeRows = await incomeQuery.get();
    final expenseRows = await expenseQuery.get();

    // 合并收入/支出
    final Map<String, UserMonthlyStatisticVO> map = {};

    for (final row in incomeRows) {
      final userId = row.read(db.accountItemTable.createdBy) ?? '';
      final income = row.read(db.accountItemTable.amount.sum()) ?? 0.0;
      final count = row.read(db.accountItemTable.id.count()) ?? 0;
      map[userId] = UserMonthlyStatisticVO(
        userId: userId,
        userName: userId,
        income: income,
        expense: 0,
        count: count,
      );
    }

    for (final row in expenseRows) {
      final userId = row.read(db.accountItemTable.createdBy) ?? '';
      final expense = row.read(db.accountItemTable.amount.sum()) ?? 0.0;
      final count = row.read(db.accountItemTable.id.count()) ?? 0;
      final prev = map[userId];
      if (prev == null) {
        map[userId] = UserMonthlyStatisticVO(
          userId: userId,
          userName: userId,
          income: 0,
          expense: expense,
          count: count,
        );
      } else {
        map[userId] = UserMonthlyStatisticVO(
          userId: prev.userId,
          userName: prev.userName,
          income: prev.income,
          expense: expense,
          count: prev.count + count,
        );
      }
    }

    // 映射用户名
    if (map.isNotEmpty) {
      final ids = map.keys.where((e) => e.isNotEmpty).toList();
      if (ids.isNotEmpty) {
        final users = await (db.select(db.userTable)
              ..where((t) => t.id.isIn(ids)))
            .get();
        final id2name = {
          for (var u in users)
            u.id: (u.nickname.isNotEmpty ? u.nickname : u.username)
        };
        map.updateAll((key, value) => UserMonthlyStatisticVO(
              userId: value.userId,
              userName: id2name[key] ?? value.userName,
              income: value.income,
              expense: value.expense,
              count: value.count,
            ));
      }
    }

    final list = map.values.toList()
      ..sort((a, b) => (b.income + b.expense.abs()).compareTo(a.income + a.expense.abs()));

    return OperateResult.success(list);
  }
}
