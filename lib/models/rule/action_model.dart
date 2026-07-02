/// 规则动作节点（扁平结构）
class ActionNode {
  /// 动作类型，例如: set_value
  final String type;

  /// 目标字段名
  final String field;

  /// 动作值
  final dynamic value;

  /// 标签追加模式（仅 tagCode/tagCodes 字段有效）
  final bool append;

  const ActionNode({
    required this.type,
    required this.field,
    this.value,
    this.append = false,
  });

  factory ActionNode.fromJson(Map<String, dynamic> json) {
    return ActionNode(
      type: json['type'] as String,
      field: json['field'] as String,
      value: json['value'],
      append: json['append'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'field': field,
      'value': value,
      if (field == 'tagCode') 'append': append,
    };
  }
}
