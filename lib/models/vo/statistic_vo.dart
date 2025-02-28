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
  final double income;

  /// 支出
  final double expense;

  /// 结余
  final double balance;

  const BookStatisticVO({
    this.income = 0,
    this.expense = 0,
    this.balance = 0,
  });
}
