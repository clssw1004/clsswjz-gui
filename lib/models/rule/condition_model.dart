/// 规则条件节点（树形结构）
///
/// 叶子节点: type + field + value
/// 非叶子节点: logicOperator + conditions
class ConditionNode {
  /// 条件类型（叶子节点）
  final String? type;

  /// 字段名（叶子节点）
  final String? field;

  /// 条件值（叶子节点）
  final dynamic value;

  /// 逻辑运算符: AND / OR（非叶子节点）
  final String? logicOperator;

  /// 子条件列表（非叶子节点）
  final List<ConditionNode>? conditions;

  /// 是否为叶子节点
  bool get isLeaf => conditions == null || conditions!.isEmpty;

  const ConditionNode({
    this.type,
    this.field,
    this.value,
    this.logicOperator,
    this.conditions,
  });

  factory ConditionNode.fromJson(Map<String, dynamic> json) {
    // 非叶子节点（包含逻辑运算符和子条件）
    if (json.containsKey('logicOperator') || json.containsKey('conditions')) {
      return ConditionNode(
        logicOperator: json['logicOperator'] as String?,
        conditions: (json['conditions'] as List<dynamic>?)
            ?.map((c) => ConditionNode.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
    }
    // 叶子节点
    return ConditionNode(
      type: json['type'] as String?,
      field: json['field'] as String?,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    if (isLeaf) {
      return {
        'type': type,
        'field': field,
        'value': value,
      };
    }
    return {
      'logicOperator': logicOperator,
      'conditions': conditions?.map((c) => c.toJson()).toList() ?? [],
    };
  }
}
