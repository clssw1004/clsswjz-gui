/// 编辑器可变条件数据
class ConditionData {
  String? type;
  String? field;
  dynamic value;
  String? logicOperator;
  List<ConditionData> children;

  ConditionData({
    this.type,
    this.field,
    this.value,
    this.logicOperator,
    List<ConditionData>? children,
  }) : children = children ?? [];

  bool get isLeaf => children.isEmpty;
}

/// 编辑器可变操作数据
class ActionData {
  String field;
  String value;
  ActionData({required this.field, required this.value});
}
