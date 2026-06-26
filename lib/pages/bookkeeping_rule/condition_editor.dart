import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/common_select_form_field.dart';
import 'editor_models.dart';
class ConditionGroupEditor extends StatelessWidget {
  final List<ConditionData> conditions;
  final String logicOperator;
  final ValueChanged<String> onLogicOperatorChanged;
  final VoidCallback onStateChanged;
  final List<AccountCategory> categories;
  final List<UserFundVO> funds;
  final List<AccountShop> shops;
  final List<AccountSymbol> tags;
  final List<AccountSymbol> projects;
  final bool showLogicSelector;

  const ConditionGroupEditor({
    super.key,
    required this.conditions,
    required this.logicOperator,
    required this.onLogicOperatorChanged,
    required this.onStateChanged,
    this.categories = const [],
    this.funds = const [],
    this.shops = const [],
    this.tags = const [],
    this.projects = const [],
    this.showLogicSelector = true,
  });

  static String typeLabel(String type) {
    final l = L10nManager.l10n;
    return switch (type) {
      'field_equals' => l.bookkeepingRuleLabelTypeEq,
      'field_in' => l.bookkeepingRuleLabelTypeIn,
      'amount_range' => l.bookkeepingRuleLabelTypeRange,
      _ => type,
    };
  }

  static String fieldLabel(String f) {
    final l = L10nManager.l10n;
    return switch (f) {
      'type' => l.bookkeepingRuleLabelFieldType,
      'categoryCode' => l.bookkeepingRuleLabelFieldCategory,
      'fundId' => l.bookkeepingRuleLabelFieldFund,
      'shopCode' => l.bookkeepingRuleLabelFieldShop,
      'tagCode' => l.bookkeepingRuleLabelFieldTag,
      'projectCode' => l.bookkeepingRuleLabelFieldProject,
      'amount' => l.bookkeepingRuleLabelFieldAmount,
      _ => f,
    };
  }

  static const _fieldComparisons = {
    'type': ['field_equals'],
    'categoryCode': ['field_equals', 'field_in'],
    'fundId': ['field_equals', 'field_in'],
    'shopCode': ['field_equals', 'field_in'],
    'tagCode': ['field_equals', 'field_in'],
    'projectCode': ['field_equals', 'field_in'],
    'amount': ['field_equals', 'amount_range'],
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (conditions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            L10nManager.l10n.bookkeepingRulePlaceholderConditionEmpty,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurface.withAlpha(128)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        // 条件列表（带 AND/OR 连接芯片）
        ...() {
          final items = <Widget>[];
          for (var i = 0; i < conditions.length; i++) {
            final condition = conditions[i];
            items.add(
              condition.isLeaf
                  ? _buildLeafRow(context, condition, i)
                  : _buildGroupRow(context, condition, i),
            );
            // 条件之间的 AND/OR 连接芯片
            if (showLogicSelector && i < conditions.length - 1) {
              items.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Center(
                    child: _LogicChip(
                      logic: logicOperator,
                      onToggle: () => onLogicOperatorChanged(
                        logicOperator == 'AND' ? 'OR' : 'AND',
                      ),
                    ),
                  ),
                ),
              );
            }
          }
          return items;
        }(),
        // 内部添加条件按钮
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: PopupMenuButton<String>(
            child: TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text(L10nManager.l10n.bookkeepingRuleAddCondition),
              onPressed: null,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'leaf', child: Text(L10nManager.l10n.bookkeepingRuleCondition)),
              PopupMenuItem(value: 'group', child: Text(L10nManager.l10n.bookkeepingRuleConditionGroup)),
            ],
            onSelected: (value) {
              if (value == 'leaf') {
                conditions.add(ConditionData(
                    type: 'field_equals', field: 'categoryCode', value: ''));
              } else {
                conditions.add(ConditionData(
                    logicOperator: 'AND',
                    children: [ConditionData(
                        type: 'field_equals', field: 'categoryCode', value: '')]));
              }
              onStateChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeafRow(BuildContext context, ConditionData condition, int index) {
    final theme = Theme.of(context);
    final availableComparisons =
        _fieldComparisons[condition.field] ?? ['field_equals'];
    if (condition.type != null &&
        !availableComparisons.contains(condition.type)) {
      condition.type = availableComparisons.first;
    }

    return CommonCardContainer(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：字段 + 比较方式 + 删除
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: condition.field ?? _fieldComparisons.keys.first,
                    decoration: const InputDecoration(
                      labelText: '字段',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                    items: _fieldComparisons.keys
                        .map((k) => DropdownMenuItem(
                            value: k, child: Text(fieldLabel(k), style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        condition.field = v;
                        condition.type =
                            (_fieldComparisons[v] ?? ['field_equals']).first;
                        condition.value = '';
                        onStateChanged();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 90,
                  child: DropdownButtonFormField<String>(
                    initialValue: availableComparisons.contains(condition.type)
                        ? condition.type!
                        : availableComparisons.first,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    ),
                    items: availableComparisons
                        .map((key) => DropdownMenuItem(
                            value: key,
                            child: Text(typeLabel(key),
                                style: const TextStyle(fontSize: 12))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        condition.type = v;
                        condition.value = '';
                        onStateChanged();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                      color: theme.colorScheme.error, size: 20),
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    conditions.removeAt(index);
                    onStateChanged();
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            // 第二行：值选择器（独占一行）
            ConditionValueSelector(
              key: ValueKey('${condition.type}_${condition.field}_$index'),
              conditionType: condition.type ?? 'field_equals',
              field: condition.field ?? '',
              value: condition.value,
              onChanged: (v) {
                condition.value = v;
                onStateChanged();
              },
              categories: categories,
              funds: funds,
              shops: shops,
              tags: tags,
              projects: projects,
            ),
          ],
        ),
    );
  }

  Widget _buildGroupRow(
      BuildContext context, ConditionData condition, int index) {
    return CommonCardContainer(
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.folder_outlined, size: 14,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(L10nManager.l10n.bookkeepingRuleConditionGroup,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Theme.of(context).colorScheme.primary)),
                  if (condition.children.length >= 2) ...[
                    const SizedBox(width: 6),
                    _LogicChip(
                      logic: condition.logicOperator ?? 'AND',
                      onToggle: () {
                        condition.logicOperator =
                            condition.logicOperator == 'AND' ? 'OR' : 'AND';
                        onStateChanged();
                      },
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline,
                        color: Theme.of(context).colorScheme.error, size: 16),
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      conditions.removeAt(index);
                      onStateChanged();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            ConditionGroupEditor(
              showLogicSelector: false,
              conditions: condition.children,
              logicOperator: condition.logicOperator ?? 'AND',
              onLogicOperatorChanged: (op) {
                condition.logicOperator = op;
                onStateChanged();
              },
              onStateChanged: onStateChanged,
              categories: categories,
              funds: funds,
              shops: shops,
              tags: tags,
              projects: projects,
            ),
          ],
        ),
    );
  }
}

/// 小巧的 AND/OR 切换标签（内联使用）
class _LogicChip extends StatelessWidget {
  final String logic;
  final VoidCallback onToggle;

  const _LogicChip({required this.logic, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAnd = logic == 'AND';
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isAnd ? cs.primary.withAlpha(25) : cs.tertiary.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isAnd ? cs.primary.withAlpha(80) : cs.tertiary.withAlpha(80),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              logic,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isAnd ? cs.primary : cs.tertiary,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.swap_horiz_rounded, size: 10,
                color: cs.onSurfaceVariant.withAlpha(100)),
          ],
        ),
      ),
    );
  }
}

class ConditionValueSelector extends StatelessWidget {
  final String conditionType;
  final String field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final List<AccountCategory> categories;
  final List<UserFundVO> funds;
  final List<AccountShop> shops;
  final List<AccountSymbol> tags;
  final List<AccountSymbol> projects;

  const ConditionValueSelector({
    super.key,
    required this.conditionType,
    required this.field,
    required this.value,
    required this.onChanged,
    required this.categories,
    required this.funds,
    required this.shops,
    required this.tags,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    // 金额范围 → 双输入
    if (conditionType == 'amount_range') {
      return _buildAmountRange();
    }
    // 属于 → 多选组件
    if (conditionType == 'field_in') {
      return _buildMultiSelect();
    }
    // 等于 → 按字段类型使用选择组件或输入框
    return _buildEqualsSelector();
  }

  Widget _buildEqualsSelector() {
    switch (field) {
      case 'type':
        return _buildTypeSelector();
      case 'categoryCode':
      case 'fundId':
      case 'shopCode':
      case 'tagCode':
      case 'projectCode':
        return _buildCommonSelectField(
          key: ValueKey('eq_${field}_${value?.toString()}'),
        );
      default:
        return _buildSingleValueField();
    }
  }

  Widget _buildTypeSelector() {
    final current = value?.toString() ?? 'EXPENSE';
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: 'EXPENSE', label: Text('支出')),
        ButtonSegment(value: 'INCOME', label: Text('收入')),
        ButtonSegment(value: 'TRANSFER', label: Text('转账')),
      ],
      selected: {current},
      onSelectionChanged: (v) => onChanged(v.first),
    );
  }

  Widget _buildAmountRange() {
    final map =
        value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: (map['minAmount'] ?? '').toString(),
            decoration: const InputDecoration(
              hintText: '最低',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              map['minAmount'] = v.isEmpty ? null : num.tryParse(v);
              onChanged(Map<String, dynamic>.from(map));
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('~'),
        ),
        Expanded(
          child: TextFormField(
            initialValue: (map['maxAmount'] ?? '').toString(),
            decoration: const InputDecoration(
              hintText: '最高',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              map['maxAmount'] = v.isEmpty ? null : num.tryParse(v);
              onChanged(Map<String, dynamic>.from(map));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelect() {
    // Parse current selection from stored comma-separated string
    final List<String> currentIds;
    if (value is List) {
      currentIds = (value as List).map((e) => e.toString()).toList();
    } else if (value is String && value.toString().isNotEmpty) {
      currentIds = value.toString().split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    } else {
      currentIds = [];
    }
    return _buildCommonSelectField(
      key: ValueKey('multi_${field}_${currentIds.join(",")}'),
      selectedIds: currentIds,
      multiSelect: true,
      onChanged: (ids) {
        if (ids is List<String>) {
          onChanged(ids.join(', '));
        }
      },
    );
  }

  Widget _buildCommonSelectField({
    required Key key,
    String? selectedId,
    List<String>? selectedIds,
    bool multiSelect = false,
    ValueChanged<dynamic>? onChanged,
  }) {
    // 对于单选，计算当前选中的值用于匹配
    final singleValue = selectedId ?? value?.toString();
    switch (field) {
      case 'categoryCode':
        return CommonSelectFormField<AccountCategory>(
          key: key,
          items: categories,
          multiSelect: multiSelect,
          value: multiSelect ? (selectedIds ?? <String>[]) : singleValue,
          displayField: (c) => c.name,
          keyField: (c) => c.code,
          label: '分类',
          allowCreate: false,
          onChanged: onChanged ?? (v) {
            if (v is AccountCategory) { this.onChanged(v.code); }
          },
        );
      case 'fundId':
        return CommonSelectFormField<UserFundVO>(
          key: key,
          items: funds,
          multiSelect: multiSelect,
          value: multiSelect ? (selectedIds ?? <String>[]) : singleValue,
          displayField: (f) => f.name,
          keyField: (f) => f.id,
          label: '账户',
          allowCreate: false,
          onChanged: onChanged ?? (v) {
            if (v is UserFundVO) { this.onChanged(v.id); }
          },
        );
      case 'shopCode':
        return CommonSelectFormField<AccountShop>(
          key: key,
          items: shops,
          multiSelect: multiSelect,
          value: multiSelect ? (selectedIds ?? <String>[]) : singleValue,
          displayField: (s) => s.name,
          keyField: (s) => s.code,
          label: '商家',
          allowCreate: false,
          onChanged: onChanged ?? (v) {
            if (v is AccountShop) { this.onChanged(v.code); }
          },
        );
      case 'tagCode':
        return CommonSelectFormField<AccountSymbol>(
          key: key,
          items: tags,
          multiSelect: multiSelect,
          value: multiSelect ? (selectedIds ?? <String>[]) : singleValue,
          displayField: (s) => s.name,
          keyField: (s) => s.code,
          label: '标签',
          allowCreate: false,
          onChanged: onChanged ?? (v) {
            if (v is AccountSymbol) { this.onChanged(v.code); }
          },
        );
      case 'projectCode':
        return CommonSelectFormField<AccountSymbol>(
          key: key,
          items: projects,
          multiSelect: multiSelect,
          value: multiSelect ? (selectedIds ?? <String>[]) : singleValue,
          displayField: (s) => s.name,
          keyField: (s) => s.code,
          label: '项目',
          allowCreate: false,
          onChanged: onChanged ?? (v) {
            if (v is AccountSymbol) { this.onChanged(v.code); }
          },
        );
      default:
        return _buildSingleValueField();
    }
  }

  Widget _buildSingleValueField() {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      onChanged: (v) => onChanged(v),
    );
  }
}
