enum DebtType {
  /// 借出
  lend('LEND'),
  /// 借入
  borrow('BORROW');

  final String code;
  const DebtType(this.code);

  static DebtType fromCode(String code) {
    return DebtType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => DebtType.lend,
    );
  }
} 