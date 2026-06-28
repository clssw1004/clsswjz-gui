import 'dart:convert';

/// 月度收支报告视图对象
/// 存储为 note.content 的 JSON 结构
class MonthlyReportVO {
  /// 数据版本
  final int version;

  /// 生成时间戳
  final int generatedAt;

  /// 报告期间
  final ReportPeriod period;

  /// 收支概览
  final ReportSummary summary;

  /// 支出分类排行榜
  final List<CategoryExpenseItem> categoryExpenses;

  /// 收入分类排行榜
  final List<IncomeCategoryItem> categoryIncomes;

  /// 大笔支出（单笔 ≥ 月总支出 5%）
  final List<LargeTransaction> largeTransactions;

  /// 预警分析
  final List<ReportAlert> alerts;

  /// 每日支出金额列表（用于趋势图）
  final List<double> dailyAmounts;

  /// 每日收入金额列表（用于趋势图）
  final List<double> dailyIncomes;

  /// 支出趋势
  final ReportTrends trends;

  /// 储蓄率（%）
  final double savingsRate;

  /// 支出笔数
  final int itemCount;

  /// 上月大笔支出笔数
  final int prevLargeTxnCount;

  /// 上月大笔支出总额
  final double prevLargeTxnTotal;

  /// 年度累计数据
  final YtdSummary? ytdSummary;

  /// 每月收支趋势（当年各月）
  final List<MonthlyTrendPoint> monthlyTrend;

  const MonthlyReportVO({
    this.version = 1,
    required this.generatedAt,
    required this.period,
    required this.summary,
    this.categoryExpenses = const [],
    this.categoryIncomes = const [],
    this.largeTransactions = const [],
    this.alerts = const [],
    this.dailyAmounts = const [],
    this.dailyIncomes = const [],
    required this.trends,
    this.savingsRate = 0,
    this.itemCount = 0,
    this.prevLargeTxnCount = 0,
    this.prevLargeTxnTotal = 0,
    this.ytdSummary,
    this.monthlyTrend = const [],
  });

  factory MonthlyReportVO.fromJson(Map<String, dynamic> json) {
    return MonthlyReportVO(
      version: json['version'] as int? ?? 1,
      generatedAt: json['generatedAt'] as int,
      period: ReportPeriod.fromJson(json['period'] as Map<String, dynamic>),
      summary: ReportSummary.fromJson(json['summary'] as Map<String, dynamic>),
      categoryExpenses: (json['categoryExpenses'] as List<dynamic>?)
              ?.map((e) =>
                  CategoryExpenseItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categoryIncomes: (json['categoryIncomes'] as List<dynamic>?)
              ?.map((e) =>
                  IncomeCategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      largeTransactions: (json['largeTransactions'] as List<dynamic>?)
              ?.map((e) =>
                  LargeTransaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => ReportAlert.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dailyAmounts: (json['dailyAmounts'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      dailyIncomes: (json['dailyIncomes'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      trends: ReportTrends.fromJson(json['trends'] as Map<String, dynamic>),
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0,
      itemCount: json['itemCount'] as int? ?? 0,
      prevLargeTxnCount: json['prevLargeTxnCount'] as int? ?? 0,
      prevLargeTxnTotal: (json['prevLargeTxnTotal'] as num?)?.toDouble() ?? 0,
      ytdSummary: json['ytdSummary'] != null
          ? YtdSummary.fromJson(json['ytdSummary'] as Map<String, dynamic>)
          : null,
      monthlyTrend: (json['monthlyTrend'] as List<dynamic>?)
              ?.map((e) =>
                  MonthlyTrendPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'generatedAt': generatedAt,
        'period': period.toJson(),
        'summary': summary.toJson(),
        'categoryExpenses':
            categoryExpenses.map((e) => e.toJson()).toList(),
        'categoryIncomes':
            categoryIncomes.map((e) => e.toJson()).toList(),
        'largeTransactions':
            largeTransactions.map((e) => e.toJson()).toList(),
        'alerts': alerts.map((e) => e.toJson()).toList(),
        'dailyAmounts': dailyAmounts,
        'dailyIncomes': dailyIncomes,
        'trends': trends.toJson(),
        'savingsRate': savingsRate,
        'itemCount': itemCount,
        'prevLargeTxnCount': prevLargeTxnCount,
        'prevLargeTxnTotal': prevLargeTxnTotal,
        'ytdSummary': ytdSummary?.toJson(),
        'monthlyTrend': monthlyTrend.map((e) => e.toJson()).toList(),
      };

  String toJsonString() => jsonEncode(toJson());

  String toPlainText() {
    final buf = StringBuffer();
    buf.writeln('月度收支报告 —— ${period.year}年${period.month}月');
    buf.writeln('收入: ¥${summary.totalIncome.toStringAsFixed(2)}');
    buf.writeln('支出: ¥${summary.totalExpense.toStringAsFixed(2)}');
    buf.writeln('结余: ¥${summary.balance.toStringAsFixed(2)}');
    if (summary.prevExpense > 0) {
      final diff = summary.totalExpense - summary.prevExpense;
      final sign = diff >= 0 ? '+' : '';
      buf.writeln('支出环比: $sign${diff.toStringAsFixed(2)}');
    }
    if (alerts.isNotEmpty) {
      buf.writeln('预警: ${alerts.length}条');
      for (final alert in alerts.take(3)) {
        buf.writeln('  ${alert.message}');
      }
    }
    return buf.toString();
  }

}

/// 报告期间
class ReportPeriod {
  final int year;
  final int month;

  const ReportPeriod({required this.year, required this.month});

  factory ReportPeriod.fromJson(Map<String, dynamic> json) => ReportPeriod(
        year: json['year'] as int,
        month: json['month'] as int,
      );

  Map<String, dynamic> toJson() => {'year': year, 'month': month};
}

/// 收支概览
class ReportSummary {
  /// 本月总收入
  final double totalIncome;

  /// 本月总支出
  final double totalExpense;

  /// 本月结余
  final double balance;

  /// 上月收入
  final double prevIncome;

  /// 上月支出
  final double prevExpense;

  /// 上月结余
  final double prevBalance;

  /// 日均支出
  final double dailyAverage;

  const ReportSummary({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.balance = 0,
    this.prevIncome = 0,
    this.prevExpense = 0,
    this.prevBalance = 0,
    this.dailyAverage = 0,
  });

  /// 支出环比率
  double get expenseChangeRatio =>
      prevExpense > 0 ? (totalExpense - prevExpense) / prevExpense : 0;

  /// 支出差额
  double get expenseDiff => totalExpense - prevExpense;

  /// 收入环比率
  double get incomeChangeRatio =>
      prevIncome > 0 ? (totalIncome - prevIncome) / prevIncome : 0;

  /// 收入差额
  double get incomeDiff => totalIncome - prevIncome;

  /// 是否有环比数据
  bool get hasComparison => prevExpense > 0 || prevIncome > 0;

  factory ReportSummary.fromJson(Map<String, dynamic> json) => ReportSummary(
        totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
        totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0,
        balance: (json['balance'] as num?)?.toDouble() ?? 0,
        prevIncome: (json['prevIncome'] as num?)?.toDouble() ?? 0,
        prevExpense: (json['prevExpense'] as num?)?.toDouble() ?? 0,
        prevBalance: (json['prevBalance'] as num?)?.toDouble() ?? 0,
        dailyAverage: (json['dailyAverage'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': balance,
        'prevIncome': prevIncome,
        'prevExpense': prevExpense,
        'prevBalance': prevBalance,
        'dailyAverage': dailyAverage,
      };
}

/// 支出分类项
class CategoryExpenseItem {
  final String categoryCode;
  final String categoryName;
  final double amount;
  final double percentage;
  final int count;

  /// 上月金额
  final double prevAmount;

  /// 上月笔数
  final int prevCount;

  const CategoryExpenseItem({
    required this.categoryCode,
    required this.categoryName,
    this.amount = 0,
    this.percentage = 0,
    this.count = 0,
    this.prevAmount = 0,
    this.prevCount = 0,
  });

  /// 差额
  double get diff => amount - prevAmount;

  /// 环比率
  double get diffPercent =>
      prevAmount > 0 ? (amount - prevAmount) / prevAmount : 0;

  factory CategoryExpenseItem.fromJson(Map<String, dynamic> json) =>
      CategoryExpenseItem(
        categoryCode: json['categoryCode'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
        count: json['count'] as int? ?? 0,
        prevAmount: (json['prevAmount'] as num?)?.toDouble() ?? 0,
        prevCount: json['prevCount'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'categoryCode': categoryCode,
        'categoryName': categoryName,
        'amount': amount,
        'percentage': percentage,
        'count': count,
        'prevAmount': prevAmount,
        'prevCount': prevCount,
      };
}

/// 收入分类项
class IncomeCategoryItem {
  final String categoryCode;
  final String categoryName;
  final double amount;
  final double percentage;
  final int count;
  final double prevAmount;
  final int prevCount;

  const IncomeCategoryItem({
    required this.categoryCode,
    required this.categoryName,
    this.amount = 0,
    this.percentage = 0,
    this.count = 0,
    this.prevAmount = 0,
    this.prevCount = 0,
  });

  double get diff => amount - prevAmount;
  double get diffPercent =>
      prevAmount > 0 ? (amount - prevAmount) / prevAmount : 0;

  factory IncomeCategoryItem.fromJson(Map<String, dynamic> json) =>
      IncomeCategoryItem(
        categoryCode: json['categoryCode'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
        count: json['count'] as int? ?? 0,
        prevAmount: (json['prevAmount'] as num?)?.toDouble() ?? 0,
        prevCount: json['prevCount'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'categoryCode': categoryCode,
        'categoryName': categoryName,
        'amount': amount,
        'percentage': percentage,
        'count': count,
        'prevAmount': prevAmount,
        'prevCount': prevCount,
      };
}

/// 大笔支出
class LargeTransaction {
  /// 日期字符串 (yyyy-MM-dd)
  final String date;

  /// 分类名称
  final String categoryName;

  /// 描述
  final String? description;

  /// 金额
  final double amount;

  /// 占月总支出百分比
  final double percentage;

  const LargeTransaction({
    required this.date,
    required this.categoryName,
    this.description,
    required this.amount,
    this.percentage = 0,
  });

  factory LargeTransaction.fromJson(Map<String, dynamic> json) =>
      LargeTransaction(
        date: json['date'] as String? ?? '',
        categoryName: json['categoryName'] as String? ?? '',
        description: json['description'] as String?,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'categoryName': categoryName,
        'description': description,
        'amount': amount,
        'percentage': percentage,
      };
}

/// 报告预警
class ReportAlert {
  /// 预警类型: overThreshold / abnormalGrowth / newCategory / disappearedCategory
  final String type;

  /// 严重程度: warning / info
  final String severity;

  /// 分类名称
  final String categoryName;

  /// 预警描述
  final String message;

  /// 超出/差额金额
  final double? exceededAmount;

  /// 环比变化率（异常增长用）
  final double? diffPercent;

  const ReportAlert({
    required this.type,
    required this.severity,
    required this.categoryName,
    required this.message,
    this.exceededAmount,
    this.diffPercent,
  });

  factory ReportAlert.fromJson(Map<String, dynamic> json) => ReportAlert(
        type: json['type'] as String? ?? '',
        severity: json['severity'] as String? ?? 'info',
        categoryName: json['categoryName'] as String? ?? '',
        message: json['message'] as String? ?? '',
        exceededAmount: (json['exceededAmount'] as num?)?.toDouble(),
        diffPercent: (json['diffPercent'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'severity': severity,
        'categoryName': categoryName,
        'message': message,
        'exceededAmount': exceededAmount,
        'diffPercent': diffPercent,
      };
}

/// 支出趋势
class ReportTrends {
  final double dailyAverage;
  final String? maxSpendDay;
  final double? maxSpendAmount;
  final String? minSpendDay;
  final double? minSpendAmount;

  const ReportTrends({
    this.dailyAverage = 0,
    this.maxSpendDay,
    this.maxSpendAmount,
    this.minSpendDay,
    this.minSpendAmount,
  });

  factory ReportTrends.fromJson(Map<String, dynamic> json) => ReportTrends(
        dailyAverage: (json['dailyAverage'] as num?)?.toDouble() ?? 0,
        maxSpendDay: json['maxSpendDay'] as String?,
        maxSpendAmount: (json['maxSpendAmount'] as num?)?.toDouble(),
        minSpendDay: json['minSpendDay'] as String?,
        minSpendAmount: (json['minSpendAmount'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'dailyAverage': dailyAverage,
        'maxSpendDay': maxSpendDay,
        'maxSpendAmount': maxSpendAmount,
        'minSpendDay': minSpendDay,
        'minSpendAmount': minSpendAmount,
      };
}

/// 年度累计数据
class YtdSummary {
  final double totalIncome;
  final double totalExpense;
  final double monthlyAvgIncome;
  final double monthlyAvgExpense;
  final int monthsWithData;
  final int monthCount;

  const YtdSummary({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.monthlyAvgIncome = 0,
    this.monthlyAvgExpense = 0,
    this.monthsWithData = 0,
    this.monthCount = 0,
  });

  double get savingsRate =>
      totalIncome > 0 ? ((totalIncome - totalExpense.abs()) / totalIncome) * 100 : 0;

  factory YtdSummary.fromJson(Map<String, dynamic> json) => YtdSummary(
        totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0,
        totalExpense: (json['totalExpense'] as num?)?.toDouble() ?? 0,
        monthlyAvgIncome: (json['monthlyAvgIncome'] as num?)?.toDouble() ?? 0,
        monthlyAvgExpense: (json['monthlyAvgExpense'] as num?)?.toDouble() ?? 0,
        monthsWithData: json['monthsWithData'] as int? ?? 0,
        monthCount: json['monthCount'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'monthlyAvgIncome': monthlyAvgIncome,
        'monthlyAvgExpense': monthlyAvgExpense,
        'monthsWithData': monthsWithData,
        'monthCount': monthCount,
      };
}

/// 每月收支趋势点
class MonthlyTrendPoint {
  final int month;
  final double income;
  final double expense;

  const MonthlyTrendPoint({
    required this.month,
    this.income = 0,
    this.expense = 0,
  });

  factory MonthlyTrendPoint.fromJson(Map<String, dynamic> json) =>
      MonthlyTrendPoint(
        month: json['month'] as int? ?? 0,
        income: (json['income'] as num?)?.toDouble() ?? 0,
        expense: (json['expense'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'month': month,
        'income': income,
        'expense': expense,
      };
}
