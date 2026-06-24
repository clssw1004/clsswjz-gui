import 'dart:convert';

import '../../database/database.dart';
import '../rule/action_model.dart';
import '../rule/condition_model.dart';

/// 记账规则展示对象
class BookkeepingRuleVO {
  final String id;
  final String accountBookId;
  final String name;
  final bool isActive;
  final int priority;
  final String conditionsJson;
  final String actionsJson;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;

  BookkeepingRuleVO({
    required this.id,
    required this.accountBookId,
    required this.name,
    required this.isActive,
    required this.priority,
    required this.conditionsJson,
    required this.actionsJson,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从数据库实体构建
  factory BookkeepingRuleVO.fromBookkeepingRule(BookkeepingRule rule) {
    return BookkeepingRuleVO(
      id: rule.id,
      accountBookId: rule.accountBookId,
      name: rule.name,
      isActive: rule.isActive,
      priority: rule.priority,
      conditionsJson: rule.conditionsJson,
      actionsJson: rule.actionsJson,
      createdBy: rule.createdBy,
      updatedBy: rule.updatedBy,
      createdAt: rule.createdAt,
      updatedAt: rule.updatedAt,
    );
  }

  /// 解析条件JSON为条件节点列表
  List<ConditionNode> get conditions {
    if (conditionsJson.isEmpty) return [];
    try {
      final parsed = jsonDecode(conditionsJson);
      if (parsed is List) {
        return parsed
            .map((e) => ConditionNode.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // 单个对象时包装为列表
      return [ConditionNode.fromJson(parsed as Map<String, dynamic>)];
    } catch (_) {
      return [];
    }
  }

  /// 解析动作JSON为动作节点列表
  List<ActionNode> get actions {
    if (actionsJson.isEmpty) return [];
    try {
      final parsed = jsonDecode(actionsJson);
      if (parsed is List) {
        return parsed
            .map((e) => ActionNode.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [ActionNode.fromJson(parsed as Map<String, dynamic>)];
    } catch (_) {
      return [];
    }
  }
}
