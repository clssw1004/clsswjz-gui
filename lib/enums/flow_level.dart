/// 流量等级
enum FlowLevel {
  none('none'),
  light('light'),
  medium('medium'),
  heavy('heavy');

  final String code;
  const FlowLevel(this.code);

  static FlowLevel fromCode(String code) =>
    values.firstWhere((e) => e.code == code, orElse: () => none);

  String get text => switch(this) {
    none => '无',
    light => '少量',
    medium => '中等',
    heavy => '大量',
  };
}
