import '../models/rule/condition_model.dart';
import '../models/vo/bookkeeping_rule_vo.dart';

/// 记账规则服务层
class BookkeepingRuleService {
  BookkeepingRuleService._();

  /// 检查规则条件列表是否涉及某字段
  ///
  /// 递归遍历条件树，检查是否有叶子节点的 [field] 等于目标字段。
  static bool conditionInvolvesField(
    List<ConditionNode> conditions,
    String field,
  ) {
    for (final c in conditions) {
      if (c.isLeaf) {
        if (c.field == field) return true;
      } else {
        if (c.conditions != null &&
            conditionInvolvesField(c.conditions!, field)) {
          return true;
        }
      }
    }
    return false;
  }

  /// 按优先级排序规则（高优先级在前）
  static List<BookkeepingRuleVO> sortByPriority(
    List<BookkeepingRuleVO> rules,
  ) {
    final sorted = List<BookkeepingRuleVO>.from(rules);
    sorted.sort((a, b) => b.priority.compareTo(a.priority));
    return sorted;
  }
}
