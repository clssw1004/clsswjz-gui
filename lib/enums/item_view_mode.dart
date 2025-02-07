/// 账目列表显示模式
enum ItemViewMode {
  /// 详细模式
  advance('ADVANCE'),

  /// 简约模式
  timeline('TIMELINE');

  /// 编码
  final String code;

  const ItemViewMode(this.code);

  /// 从编码获取枚举值
  static ItemViewMode fromCode(String code) {
    return ItemViewMode.values.firstWhere(
      (e) => e.code == code,
      orElse: () => ItemViewMode.advance,
    );
  }
}
