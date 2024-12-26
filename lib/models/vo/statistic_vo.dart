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
