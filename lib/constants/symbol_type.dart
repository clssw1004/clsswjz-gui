/// 符号类型枚举
/// 用于区分标签和项目
enum SymbolType {
  /// 标签类型
  tag('TAG', '标签'),

  /// 项目类型
  project('PROJECT', '项目');

  /// 构造函数
  const SymbolType(this.value, this.name);

  /// 枚举值
  final String value;

  /// 名称
  final String name;

  /// 从字符串转换为枚举
  static SymbolType? fromString(String? value) {
    if (value == null) return null;
    return SymbolType.values.firstWhere(
      (element) => element.value == value,
      orElse: () => tag,
    );
  }

  /// 转换为字符串
  String toJson() => value;
}
