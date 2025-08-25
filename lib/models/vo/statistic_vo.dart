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

/// 账本统计信息
class BookStatisticVO {
  /// 收入
  final double income;

  /// 支出
  final double expense;

  /// 结余
  final double balance;

  /// 日期
  final String? date;

  const BookStatisticVO({
    this.income = 0,
    this.expense = 0,
    this.balance = 0,
    this.date,
  });
}

class CategoryStatisticVO {
  /// 分类编码
  final String categoryCode;

  /// 分类名称
  final String categoryName;

  /// 金额
  final double amount;

  /// 笔数
  final int count;

  const CategoryStatisticVO({
    required this.categoryCode,
    required this.categoryName,
    required this.amount,
    this.count = 0,
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

/// 每日收支统计信息
class DailyStatisticVO {
  /// 日期
  final String date;
  
  /// 收入
  final double income;
  
  /// 支出
  final double expense;
  
  /// 结余
  final double balance;

  const DailyStatisticVO({
    required this.date,
    this.income = 0,
    this.expense = 0,
    this.balance = 0,
  });
}
