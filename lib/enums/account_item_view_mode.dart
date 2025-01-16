/// 账目列表显示模式
enum AccountItemViewMode {
  /// 详细模式
  detail('DETAIL'),

  /// 简约模式
  simple('SIMPLE');

  /// 编码
  final String code;

  const AccountItemViewMode(this.code);

  /// 从编码获取枚举值
  static AccountItemViewMode fromCode(String code) {
    return AccountItemViewMode.values.firstWhere(
      (e) => e.code == code,
      orElse: () => AccountItemViewMode.detail,
    );
  }
}
