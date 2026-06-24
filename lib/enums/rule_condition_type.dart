/// 规则条件类型
enum RuleConditionType {
  /// 字段等于
  fieldEquals('field_equals'),

  /// 字段在集合中
  fieldIn('field_in'),

  /// 金额范围
  amountRange('amount_range');

  final String code;
  const RuleConditionType(this.code);

  static RuleConditionType? fromCode(String? code) {
    if (code == null) return null;
    return RuleConditionType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => throw Exception('Invalid rule condition type code: $code'),
    );
  }
}
