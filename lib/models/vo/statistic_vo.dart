import '../../enums/account_type.dart';

/// 用户统计信息
class UserStatisticVO {
  /// 账本数量
  final int bookCount;

  /// 账目数量
  final int itemCount;

  /// 记账天数
  final int dayCount;

  const UserStatisticVO({
    required this.bookCount,
    required this.itemCount,
    required this.dayCount,
  });
}

class BookStatisticVO {
  /// 收入
  final double totalIncome;

  /// 支出
  final double totalExpense;

  /// 结余
  final double totalBalance;

  /// 最后一天收入
  final double lastDayIncome;

  /// 最后一天支出
  final double lastDayExpense;

  /// 最后一天结余
  final double lastDayBalance;

  /// 最后一天日期
  final String? lastDate;

  const BookStatisticVO({
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.totalBalance = 0,
    this.lastDayIncome = 0,
    this.lastDayExpense = 0,
    this.lastDayBalance = 0,
    this.lastDate,
  });
}

class CategoryStatisticVO {
  /// 分类编码
  final String categoryCode;

  /// 分类名称
  final String categoryName;

  /// 金额
  final double amount;

  const CategoryStatisticVO({
    required this.categoryCode,
    required this.categoryName,
    required this.amount,
  });
}

class CategoryStatisticGroupVO {
  /// 分类名称
  final AccountItemType itemType;

  /// 金额
  final List<CategoryStatisticVO> categoryGroupList;

  const CategoryStatisticGroupVO({
    required this.itemType,
    required this.categoryGroupList,
  });
}
