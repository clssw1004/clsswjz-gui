import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/rule/condition_model.dart';
import '../../models/vo/bookkeeping_rule_vo.dart';
import '../../providers/bookkeeping_rule_provider.dart';
import '../../providers/books_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';

// ============================================================
// 编辑器可变数据 Wrapper
// ============================================================

/// 编辑器内部可变条件数据
class _ConditionData {
  /// 条件类型：field_equals / field_in / amount_range（null 表示组节点）
  String? type;

  /// 字段名（null 表示组节点）
  String? field;

  /// 条件值（null 表示组节点）
  dynamic value;

  /// 逻辑运算符：AND / OR（组节点用）
  String? logicOperator;

  /// 子条件列表（组节点用，叶子节点为空列表）
  List<_ConditionData> children;

  _ConditionData({
    this.type,
    this.field,
    this.value,
    this.logicOperator,
    List<_ConditionData>? children,
  }) : children = children ?? [];

  /// 是否为叶子节点
  bool get isLeaf => children.isEmpty;
}

/// 编辑器内部可变操作数据
class _ActionData {
  /// 目标字段
  String field;

  /// 设置的值
  String value;

  _ActionData({required this.field, required this.value});
}

// ============================================================
// 规则表单页面
// ============================================================

/// 记账规则新增 / 编辑表单页面
class BookkeepingRuleFormPage extends StatefulWidget {
  /// 编辑模式传入已有规则，null 表示新建
  final BookkeepingRuleVO? rule;

  /// 新建时所属账本 ID
  final String? bookId;

  const BookkeepingRuleFormPage({super.key, this.rule, this.bookId});

  @override
  State<BookkeepingRuleFormPage> createState() =>
      _BookkeepingRuleFormPageState();
}

class _BookkeepingRuleFormPageState extends State<BookkeepingRuleFormPage> {
  final _nameCtrl = TextEditingController();
  final _priorityCtrl = TextEditingController(text: '0');
  bool _isActive = true;

  List<_ConditionData> _conditions = [];
  String _rootLogicOperator = 'AND';
  List<_ActionData> _actions = [];
  bool _loading = false;

  static const _actionFieldLabels = {
    'categoryCode': '分类',
    'fundId': '账户',
    'shopCode': '商家',
    'tagCode': '标签',
    'projectCode': '项目',
  };

  @override
  void initState() {
    super.initState();
    if (widget.rule != null) {
      final rule = widget.rule!;
      _nameCtrl.text = rule.name;
      _priorityCtrl.text = rule.priority.toString();
      _isActive = rule.isActive;
      _parseExistingConditions(rule.conditions);
      _actions = rule.actions
          .map((a) => _ActionData(
                field: a.field,
                value: a.value?.toString() ?? '',
              ))
          .toList();
    }
  }

  /// 解析已有条件树到编辑器数据
  void _parseExistingConditions(List<ConditionNode> nodes) {
    if (nodes.isEmpty) return;
    // 存储的 JSON 格式为 {"logicOperator":"AND","conditions":[...]}
    // conditions getter 解析为 [rootNode{logicOperator, conditions:[...]}]
    if (nodes.length == 1 && !nodes.first.isLeaf) {
      _rootLogicOperator = nodes.first.logicOperator ?? 'AND';
      _conditions =
          nodes.first.conditions?.map(_parseConditionNode).toList() ?? [];
    } else {
      _conditions = nodes.map(_parseConditionNode).toList();
    }
  }

  _ConditionData _parseConditionNode(ConditionNode node) {
    if (node.isLeaf) {
      return _ConditionData(
        type: node.type ?? 'field_equals',
        field: node.field ?? '',
        value: node.value,
      );
    }
    return _ConditionData(
      logicOperator: node.logicOperator ?? 'AND',
      children:
          node.conditions?.map(_parseConditionNode).toList() ?? [],
    );
  }

  // ============================================================
  // JSON 序列化
  // ============================================================

  /// 序列化条件树为 JSON 字符串
  String _conditionsToJson() {
    return jsonEncode({
      'logicOperator': _rootLogicOperator,
      'conditions': _conditions.map(_conditionToJson).toList(),
    });
  }

  /// 单个条件节点序列化
  Map<String, dynamic> _conditionToJson(_ConditionData c) {
    if (c.isLeaf) {
      final map = <String, dynamic>{
        'type': c.type,
        'field': c.field,
      };
      if (c.type == 'amount_range' && c.value is Map) {
        map['value'] = c.value;
      } else if (c.type == 'field_in' && c.value is String) {
        // 逗号分隔字符串 → List<String>
        final parts = (c.value as String)
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        map['value'] = parts;
      } else {
        map['value'] = c.value ?? '';
      }
      return map;
    }
    return {
      'logicOperator': c.logicOperator,
      'conditions': c.children.map(_conditionToJson).toList(),
    };
  }

  /// 序列化操作列表为 JSON 字符串
  String _actionsToJson() {
    return jsonEncode(
      _actions.map((a) => {
        'type': 'set_value',
        'field': a.field,
        'value': a.value,
      }).toList(),
    );
  }

  // ============================================================
  // 保存逻辑
  // ============================================================

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ToastUtil.showWarning('请输入规则名称');
      return;
    }

    setState(() => _loading = true);

    final provider = context.read<BookkeepingRuleProvider>();

    if (widget.rule == null) {
      // 新建
      final bookId = widget.bookId ??
          context.read<BooksProvider>().selectedBook?.id;
      if (bookId == null) {
        if (mounted) {
          setState(() => _loading = false);
          ToastUtil.showError('未选择账本');
        }
        return;
      }
      final result = await provider.createRule(
        bookId,
        name: _nameCtrl.text.trim(),
        isActive: _isActive,
        priority: int.tryParse(_priorityCtrl.text) ?? 0,
        conditionsJson: _conditionsToJson(),
        actionsJson: _actionsToJson(),
      );
      if (!mounted) return;
      if (result.ok) {
        Navigator.pop(context, true);
      } else {
        ToastUtil.showError(result.message ?? '保存失败');
      }
    } else {
      // 编辑
      final result = await provider.updateRule(
        widget.rule!.id,
        name: _nameCtrl.text.trim(),
        isActive: _isActive,
        priority: int.tryParse(_priorityCtrl.text) ?? 0,
        conditionsJson: _conditionsToJson(),
        actionsJson: _actionsToJson(),
      );
      if (!mounted) return;
      if (result.ok) {
        Navigator.pop(context, true);
      } else {
        ToastUtil.showError(result.message ?? '保存失败');
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  // ============================================================
  // 辅助方法
  // ============================================================

  _ConditionData _createLeafCondition() {
    return _ConditionData(
      type: 'field_equals',
      field: 'categoryCode',
      value: '',
    );
  }

  _ConditionData _createGroupCondition() {
    return _ConditionData(logicOperator: 'AND');
  }

  void _addAction() {
    setState(() {
      _actions.add(_ActionData(field: 'categoryCode', value: ''));
    });
  }

  void _removeAction(int index) {
    setState(() => _actions.removeAt(index));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priorityCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // 构建 UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    final isEdit = widget.rule != null;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(isEdit ? '编辑规则' : '新增规则'),
      ),
      body: SingleChildScrollView(
        padding: spacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---- 基础信息卡片 ----
            CommonCardContainer(
              padding: spacing.formPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '基础信息',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: '规则名称',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('启用'),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priorityCtrl,
                    decoration: const InputDecoration(
                      labelText: '优先级',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- 条件编辑卡片 ----
            CommonCardContainer(
              padding: spacing.formPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '条件',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: '添加条件',
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'leaf', child: Text('条件')),
                          PopupMenuItem(value: 'group', child: Text('条件组')),
                        ],
                        onSelected: (value) {
                          setState(() {
                            if (value == 'leaf') {
                              _conditions.add(_createLeafCondition());
                            } else {
                              _conditions.add(_createGroupCondition());
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ConditionGroupEditor(
                    conditions: _conditions,
                    logicOperator: _rootLogicOperator,
                    onLogicOperatorChanged: (v) =>
                        setState(() => _rootLogicOperator = v),
                    onStateChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- 操作编辑卡片 ----
            CommonCardContainer(
              padding: spacing.formPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '操作',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: '添加操作',
                        onPressed: _addAction,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_actions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          '暂无操作，请点击右上角添加',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withAlpha(128),
                          ),
                        ),
                      ),
                    )
                  else
                    ..._actions.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final action = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _actionFieldLabels
                                        .containsKey(action.field)
                                    ? action.field
                                    : _actionFieldLabels.keys.first,
                                decoration: const InputDecoration(
                                  labelText: '字段',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 12),
                                ),
                                items: _actionFieldLabels.entries
                                    .map((e) => DropdownMenuItem(
                                        value: e.key,
                                        child: Text(e.value)))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() => action.field = v);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: '值',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                controller:
                                    TextEditingController(text: action.value),
                                onChanged: (v) => action.value = v,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline,
                                  color: colorScheme.error),
                              onPressed: () => _removeAction(idx),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- 保存按钮 ----
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 条件组编辑器（递归组件）
// ============================================================

class _ConditionGroupEditor extends StatelessWidget {
  final List<_ConditionData> conditions;
  final String logicOperator;
  final ValueChanged<String> onLogicOperatorChanged;
  final VoidCallback onStateChanged;

  const _ConditionGroupEditor({
    required this.conditions,
    required this.logicOperator,
    required this.onLogicOperatorChanged,
    required this.onStateChanged,
  });

  static const _typeLabels = {
    'field_equals': '等于',
    'field_in': '属于',
    'amount_range': '金额范围',
  };

  static const _fieldLabels = {
    'type': '类型',
    'categoryCode': '分类',
    'fundId': '账户',
    'shopCode': '商家',
    'tagCode': '标签',
    'projectCode': '项目',
    'amount': '金额',
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
            '暂无条件，请点击右上角添加',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withAlpha(128),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AND / OR 选择器
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'AND', label: Text('AND')),
            ButtonSegment(value: 'OR', label: Text('OR')),
          ],
          selected: {logicOperator},
          onSelectionChanged: (v) => onLogicOperatorChanged(v.first),
        ),
        const SizedBox(height: 8),
        // 条件列表
        ...conditions.asMap().entries.map((entry) {
          final idx = entry.key;
          final condition = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: condition.isLeaf
                ? _buildLeafRow(context, condition, idx)
                : _buildGroupRow(context, condition, idx),
          );
        }),
        // 添加条件按钮
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: PopupMenuButton<String>(
            child: TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加条件'),
              onPressed: null, // PopupMenuButton handles press
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'leaf', child: Text('条件')),
              PopupMenuItem(value: 'group', child: Text('条件组')),
            ],
            onSelected: (value) {
              if (value == 'leaf') {
                conditions.add(
                  _ConditionData(
                    type: 'field_equals',
                    field: 'categoryCode',
                    value: '',
                  ),
                );
              } else {
                conditions.add(_ConditionData(logicOperator: 'AND'));
              }
              onStateChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeafRow(BuildContext context, _ConditionData condition, int index) {
    final theme = Theme.of(context);

    return CommonCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 条件类型下拉
          SizedBox(
            width: 100,
            child: DropdownButtonFormField<String>(
              initialValue: _typeLabels.containsKey(condition.type)
                  ? condition.type!
                  : 'field_equals',
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              items: _typeLabels.entries
                  .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  condition.type = v;
                  // 切换类型时重置值
                  if (v == 'amount_range') {
                    condition.value = <String, dynamic>{
                      'minAmount': null,
                      'maxAmount': null,
                    };
                  } else if (v == 'field_in') {
                    condition.value = '';
                  } else {
                    condition.value = '';
                  }
                  onStateChanged();
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          // 字段下拉
          SizedBox(
            width: 100,
            child: DropdownButtonFormField<String>(
              initialValue: _fieldLabels.containsKey(condition.field)
                  ? condition.field!
                  : _fieldLabels.keys.first,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
              items: _fieldLabels.entries
                  .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: const TextStyle(fontSize: 13))))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  condition.field = v;
                  onStateChanged();
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          // 值选择器（根据字段+类型动态切换）
          Expanded(
            child: _ValueSelector(
              key: ValueKey('${condition.type}_${condition.field}_$index'),
              conditionType: condition.type ?? 'field_equals',
              field: condition.field ?? '',
              value: condition.value,
              onChanged: (v) {
                condition.value = v;
                onStateChanged();
              },
            ),
          ),
          // 删除按钮
          IconButton(
            icon: Icon(Icons.remove_circle_outline,
                color: theme.colorScheme.error, size: 20),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
            onPressed: () {
              conditions.removeAt(index);
              onStateChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupRow(BuildContext context, _ConditionData condition, int index) {
    return CommonCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 删除按钮
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.remove_circle_outline,
                  color: Theme.of(context).colorScheme.error, size: 20),
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              onPressed: () {
                conditions.removeAt(index);
                onStateChanged();
              },
            ),
          ),
          // 递归渲染子条件组
          _ConditionGroupEditor(
            conditions: condition.children,
            logicOperator: condition.logicOperator ?? 'AND',
            onLogicOperatorChanged: (op) {
              condition.logicOperator = op;
              onStateChanged();
            },
            onStateChanged: onStateChanged,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 值选择器（根据字段和条件类型动态切换）
// ============================================================

class _ValueSelector extends StatelessWidget {
  final String conditionType;
  final String field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  const _ValueSelector({
    super.key,
    required this.conditionType,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // 类型字段 + field_equals → SegmentedButton
    if (field == 'type' && conditionType == 'field_equals') {
      return _buildTypeSelector();
    }

    // 金额范围 → 双输入（min / max）
    if (conditionType == 'amount_range') {
      return _buildAmountRange();
    }

    // 属于 → 逗号分隔多值
    if (conditionType == 'field_in') {
      return _buildMultiValueField();
    }

    // 默认：单值 TextField
    return _buildSingleValueField();
  }

  Widget _buildTypeSelector() {
    final current = value?.toString() ?? 'EXPENSE';
    return SegmentedButton<String>(
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

  Widget _buildMultiValueField() {
    // 兼容 List<String>（来自 JSON 反序列化）和 String（来自编辑器）
    String initialText;
    if (value is List) {
      initialText = (value as List).join(', ');
    } else {
      initialText = value?.toString() ?? '';
    }
    return TextFormField(
      initialValue: initialText,
      decoration: const InputDecoration(
        hintText: '多个值用逗号分隔',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
      onChanged: (v) => onChanged(v),
    );
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
