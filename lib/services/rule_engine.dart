import '../database/database.dart';
import '../enums/symbol_type.dart';
import '../models/rule/condition_model.dart';
import '../models/vo/bookkeeping_rule_vo.dart';
import '../models/vo/user_item_vo.dart';
import 'bookkeeping_rule_service.dart';

// ---------------------------------------------------------------------------
// 1. 条件评估器抽象 + 注册器
// ---------------------------------------------------------------------------

/// 条件评估器抽象
abstract class ConditionEvaluator {
  String get type;

  /// 判断条件是否匹配
  bool matches(UserItemVO item, Map<String, dynamic> data);
}

/// 条件评估器注册器（工厂模式）
class ConditionRegistry {
  ConditionRegistry._();

  static final Map<String, ConditionEvaluator Function(Map<String, dynamic>)>
      _registry = {};

  /// 注册条件评估器
  static void register(
    String type,
    ConditionEvaluator Function(Map<String, dynamic>) factory,
  ) {
    _registry[type] = factory;
  }

  /// 创建条件评估器实例
  static ConditionEvaluator? create(String type, Map<String, dynamic> data) {
    final factory = _registry[type];
    if (factory == null) return null;
    return factory(data);
  }
}

// ---------------------------------------------------------------------------
// 1a. 内建条件评估器
// ---------------------------------------------------------------------------

/// 字段等于评估器（field_equals）
class FieldEqualsEvaluator implements ConditionEvaluator {
  final String field;
  final String value;

  FieldEqualsEvaluator(Map<String, dynamic> data)
      : field = data['field'] as String,
        value = data['value']?.toString() ?? '';

  @override
  String get type => 'field_equals';

  @override
  bool matches(UserItemVO item, Map<String, dynamic> _) {
    final fieldValue = _getFieldValue(item, field);
    return fieldValue?.toString() == value;
  }
}

/// 字段在集合中评估器（field_in）
class FieldInEvaluator implements ConditionEvaluator {
  final String field;
  final List<String> values;

  FieldInEvaluator(Map<String, dynamic> data)
      : field = data['field'] as String,
        values = (data['value'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

  @override
  String get type => 'field_in';

  @override
  bool matches(UserItemVO item, Map<String, dynamic> _) {
    final fieldValue = _getFieldValue(item, field);
    return values.contains(fieldValue?.toString());
  }
}

/// 金额范围评估器（amount_range）
class AmountRangeEvaluator implements ConditionEvaluator {
  final String field;
  final double? minAmount;
  final double? maxAmount;

  AmountRangeEvaluator(Map<String, dynamic> data)
      : field = (data['field'] as String?) ?? 'amount',
        minAmount = (() {
          final raw = data['value'];
          if (raw is Map) {
            final v = raw['minAmount'];
            return (v as num?)?.toDouble();
          }
          return null;
        })(),
        maxAmount = (() {
          final raw = data['value'];
          if (raw is Map) {
            final v = raw['maxAmount'];
            return (v as num?)?.toDouble();
          }
          return null;
        })();

  @override
  String get type => 'amount_range';

  @override
  bool matches(UserItemVO item, Map<String, dynamic> _) {
    final fieldValue = _getFieldValue(item, field);
    if (fieldValue is! num) return false;
    final amount = fieldValue.toDouble();
    if (minAmount != null && amount < minAmount!) return false;
    if (maxAmount != null && amount > maxAmount!) return false;
    return true;
  }
}

// ---------------------------------------------------------------------------
// 2. 动作执行器抽象 + 注册器
// ---------------------------------------------------------------------------

/// 动作执行器抽象
abstract class ActionExecutor {
  String get type;

  /// 执行操作，返回被修改的字段名列表
  List<String> apply(UserItemVO item, Map<String, dynamic> data);
}

/// 动作执行器注册器（工厂模式）
class ActionRegistry {
  ActionRegistry._();

  static final Map<String, ActionExecutor Function(Map<String, dynamic>)>
      _registry = {};

  /// 注册动作执行器
  static void register(
    String type,
    ActionExecutor Function(Map<String, dynamic>) factory,
  ) {
    _registry[type] = factory;
  }

  /// 创建动作执行器实例
  static ActionExecutor? create(String type, Map<String, dynamic> data) {
    final factory = _registry[type];
    if (factory == null) return null;
    return factory(data);
  }
}

// ---------------------------------------------------------------------------
// 2a. 内建动作执行器
// ---------------------------------------------------------------------------

/// 设置字段值动作（set_value）
class SetValueAction implements ActionExecutor {
  final String field;
  final String value;
  final bool append;

  SetValueAction(Map<String, dynamic> data)
      : field = data['field'] as String,
        value = data['value']?.toString() ?? '',
        append = data['append'] == true;

  @override
  String get type => 'set_value';

  @override
  List<String> apply(UserItemVO item, Map<String, dynamic> _) {
    if (append && (field == 'tagCode' || field == 'tagCodes')) {
      // 追加模式：在已有标签列表末尾添加，不覆盖
      final existingCodes = item.tags.map((t) => t.code).toSet();
      if (!existingCodes.contains(value) && value.isNotEmpty) {
        item.tags = [...item.tags, AccountSymbol(
          code: value,
          name: '',
          symbolType: SymbolType.tag.code,
          accountBookId: item.accountBookId,
          id: '', lastAccountItemAt: null,
          createdAt: 0, createdBy: '',
          updatedAt: 0, updatedBy: '',
        )];
      }
      return ['tagCodes'];
    }
    _setFieldValue(item, field, value);
    return [field];
  }
}

// ---------------------------------------------------------------------------
// 3. 条件树评估器
// ---------------------------------------------------------------------------

/// 条件树评估器 — 递归评估条件树
class ConditionTreeEvaluator {
  ConditionTreeEvaluator._();

  /// 递归评估条件树
  static bool evaluate(ConditionNode node, UserItemVO item) {
    if (node.isLeaf) {
      final evaluator = ConditionRegistry.create(node.type!, {
        'field': node.field,
        'value': node.value,
      });
      if (evaluator == null) return false;
      return evaluator.matches(item, {});
    }

    // 非叶子节点：按逻辑运算符评估所有子条件
    if (node.conditions == null || node.conditions!.isEmpty) {
      return true; // 空分组视为通过
    }

    if (node.logicOperator == 'OR') {
      return node.conditions!.any((c) => evaluate(c, item));
    }
    // 默认 AND
    return node.conditions!.every((c) => evaluate(c, item));
  }
}

// ---------------------------------------------------------------------------
// 4. 规则引擎
// ---------------------------------------------------------------------------

/// 记账规则引擎
class RuleEngine {
  RuleEngine._();

  /// 初始化：注册内置的条件和操作类型
  static void init() {
    ConditionRegistry.register(
      'field_equals',
      (data) => FieldEqualsEvaluator(data),
    );
    ConditionRegistry.register(
      'field_in',
      (data) => FieldInEvaluator(data),
    );
    ConditionRegistry.register(
      'amount_range',
      (data) => AmountRangeEvaluator(data),
    );
    ActionRegistry.register(
      'set_value',
      (data) => SetValueAction(data),
    );
  }

  /// 字段变更后触发规则评估
  ///
  /// [changedField] 变更的字段名
  /// [item] 当前账目数据
  /// [rules] 激活的规则列表（已带 parsed conditions/actions）
  /// 返回被规则修改的字段名列表
  static List<String> evaluate({
    required String changedField,
    required UserItemVO item,
    required List<BookkeepingRuleVO> rules,
  }) {
    final modifiedFields = <String>{};

    // 只考虑激活的规则
    final activeRules = rules.where((r) => r.isActive).toList();
    // 按优先级排序
    final sortedRules = BookkeepingRuleService.sortByPriority(activeRules);

    for (final rule in sortedRules) {
      // 跳过条件不涉及变更字段的规则（性能优化）
      if (!BookkeepingRuleService.conditionInvolvesField(
        rule.conditions,
        changedField,
      )) {
        continue;
      }

      // 评估条件树 — 根层条件全部满足才算匹配
      bool allMatch = true;
      for (final condition in rule.conditions) {
        if (!ConditionTreeEvaluator.evaluate(condition, item)) {
          allMatch = false;
          break;
        }
      }
      if (!allMatch) continue;

      // 执行规则的动作
      for (final action in rule.actions) {
        final executor = ActionRegistry.create(
          action.type,
          {'field': action.field, 'value': action.value},
        );
        if (executor == null) continue;
        final modified = executor.apply(item, {});
        modifiedFields.addAll(modified);
      }
    }

    return modifiedFields.toList();
  }

  /// 检查规则条件列表是否涉及某字段
  @Deprecated('Use BookkeepingRuleService.conditionInvolvesField instead')
  static bool conditionInvolvesField(
    List<ConditionNode> conditions,
    String field,
  ) {
    return BookkeepingRuleService.conditionInvolvesField(conditions, field);
  }
}

// ---------------------------------------------------------------------------
// 5. 辅助函数
// ---------------------------------------------------------------------------

/// 通过字段名获取 UserItemVO 的字段值
dynamic _getFieldValue(UserItemVO item, String field) {
  switch (field) {
    case 'type':
      return item.type;
    case 'amount':
      return item.amount;
    case 'categoryCode':
      return item.categoryCode;
    case 'fundId':
      return item.fundId;
    case 'shopCode':
      return item.shopCode;
    case 'tagCode':
    case 'tagCodes':
      return item.firstTagCode;
    case 'projectCode':
      return item.projectCode;
    default:
      return null;
  }
}

/// 通过字段名设置 UserItemVO 的字段值
void _setFieldValue(UserItemVO item, String field, dynamic value) {
  switch (field) {
    case 'type':
      item.type = value as String;
      break;
    case 'amount':
      item.amount = (value as num).toDouble();
      break;
    case 'categoryCode':
      item.categoryCode = value as String?;
      break;
    case 'fundId':
      item.fundId = value as String?;
      break;
    case 'shopCode':
      item.shopCode = value as String?;
      break;
    case 'tagCode':
    case 'tagCodes':
      // 规则引擎仅保持向后兼容，写入单标签
      if (value != null) {
        item.tags = [AccountSymbol(
          code: value as String,
          name: '',
          symbolType: SymbolType.tag.code,
          accountBookId: item.accountBookId,
          id: '',
          lastAccountItemAt: null,
          createdAt: 0,
          createdBy: '',
          updatedAt: 0,
          updatedBy: '',
        )];
      } else {
        item.tags = [];
      }
      break;
    case 'projectCode':
      item.projectCode = value as String?;
      break;
  }
}
