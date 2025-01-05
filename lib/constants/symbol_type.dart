/// 符号类型枚举
/// 用于区分标签和项目
enum SymbolType {
  /// 标签类型
  tag('TAG'),

  /// 项目类型
  project('PROJECT');

  /// 构造函数
  const SymbolType(this.value);

  /// 枚举值
  final String value;

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
