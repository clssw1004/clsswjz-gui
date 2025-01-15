/// 账目类型
enum AccountItemType {
  /// 支出
  expense('EXPENSE'),

  /// 收入
  income('INCOME'),

  /// 转账
  transfer('TRANSFER');

  final String code;
  const AccountItemType(this.code);

  static AccountItemType? fromCode(String? code) {
    if (code == null) return null;
    return AccountItemType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => AccountItemType.expense,
    );
  }
}
