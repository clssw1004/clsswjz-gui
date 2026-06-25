import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/dao_manager.dart';
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

class _ConditionData {
  String? type;
  String? field;
  dynamic value;
  String? logicOperator;
  List<_ConditionData> children;

  _ConditionData({
    this.type,
    this.field,
    this.value,
    this.logicOperator,
    List<_ConditionData>? children,
  }) : children = children ?? [];

  bool get isLeaf => children.isEmpty;
}

class _ActionData {
  String field;
  String value;
  _ActionData({required this.field, required this.value});
}

// ============================================================
// 规则表单页面
// ============================================================

class BookkeepingRuleFormPage extends StatefulWidget {
  final BookkeepingRuleVO? rule;
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

  // 引用数据加载状态
  List<dynamic> _categories = [];
  List<dynamic> _funds = [];
  List<dynamic> _shops = [];

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
    _loadReferenceData();
  }

  Future<void> _loadReferenceData() async {
    final bookId = widget.bookId ??
        (context.read<BooksProvider>().selectedBook?.id);
    if (bookId == null) return;
    try {
      final cats = await DaoManager.categoryDao.listByBook(bookId);
      final funds = await DaoManager.fundDao.listByBook(bookId);
      final shops = await DaoManager.shopDao.listByBook(bookId);
      // symbols (tags + projects) loaded on demand
      if (mounted) {
        setState(() {
          _categories = cats;
          _funds = funds;
          _shops = shops;
        });
      }
    } catch (_) {
      // silent — form still usable with text input
    }
  }

  void _parseExistingConditions(List<ConditionNode> nodes) {
    if (nodes.isEmpty) return;
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
      children: node.conditions?.map(_parseConditionNode).toList() ?? [],
    );
  }

  // ============================================================
  // JSON 序列化
  // ============================================================

  String _conditionsToJson() {
    return jsonEncode({
      'logicOperator': _rootLogicOperator,
      'conditions': _conditions.map(_conditionToJson).toList(),
    });
  }

  Map<String, dynamic> _conditionToJson(_ConditionData c) {
    if (c.isLeaf) {
      final map = <String, dynamic>{'type': c.type, 'field': c.field};
      if (c.type == 'amount_range' && c.value is Map) {
        map['value'] = c.value;
      } else if (c.type == 'field_in' && c.value is String) {
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
      ToastUtil.showWarning(L10nManager.l10n.bookkeepingRuleNameRequired);
      return;
    }
    setState(() => _loading = true);
    final provider = context.read<BookkeepingRuleProvider>();

    if (widget.rule == null) {
      final bookId =
          widget.bookId ?? context.read<BooksProvider>().selectedBook?.id;
      if (bookId == null) {
        if (mounted) {
          setState(() => _loading = false);
          ToastUtil.showError(L10nManager.l10n.selectAccountBook);
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
        ToastUtil.showError(result.message?.toString() ?? '保存失败');
      }
    } else {
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
        ToastUtil.showError(result.message?.toString() ?? '保存失败');
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  _ConditionData _createLeafCondition() =>
      _ConditionData(type: 'field_equals', field: 'categoryCode', value: '');

  _ConditionData _createGroupCondition() =>
      _ConditionData(logicOperator: 'AND', children: [_createLeafCondition()]);

  void _addAction() =>
      setState(() => _actions.add(_ActionData(field: 'categoryCode', value: '')));

  void _removeAction(int index) => setState(() => _actions.removeAt(index));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priorityCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // 字段值选择弹窗
  // ============================================================

  Future<void> _showFieldValuePicker({
    required String field,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) async {
    List<String> options = [];
    String title = '';

    switch (field) {
      case 'type':
        title = '选择类型';
        options = ['EXPENSE', 'INCOME', 'TRANSFER'];
        final labels = {'EXPENSE': '支出', 'INCOME': '收入', 'TRANSFER': '转账'};
        final result = await showDialog<String>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text(title),
            children: options
                .map((o) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, o),
                      child: Text(labels[o] ?? o),
                    ))
                .toList(),
          ),
        );
        if (result != null) onChanged(result);
        return;

      case 'categoryCode':
        title = '选择分类';
        options = _categories
            .map((c) => (c as dynamic).name?.toString() ?? '')
            .where((n) => n.isNotEmpty)
            .toList();
        break;
      case 'fundId':
        title = '选择账户';
        options = _funds
            .map((f) => (f as dynamic).name?.toString() ?? '')
            .where((n) => n.isNotEmpty)
            .toList();
        break;
      case 'shopCode':
        title = '选择商家';
        options = _shops
            .map((s) => (s as dynamic).name?.toString() ?? '')
            .where((n) => n.isNotEmpty)
            .toList();
        break;
      case 'tagCode':
        title = '选择标签';
        options = _loadSymbolNames('TAG');
        break;
      case 'projectCode':
        title = '选择项目';
        options = _loadSymbolNames('PROJECT');
        break;
      default:
        return;
    }

    // Show a simple bottom sheet / dialog with options
    if (!mounted) return;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: [
          ...options.map((o) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, o),
                child: Text(o),
              )),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, '__custom__'),
            child: Text('其他...', style: TextStyle(color: Theme.of(ctx).colorScheme.primary)),
          ),
        ],
      ),
    );
    if (result == '__custom__') {
      // Let user type directly — handled by caller fallback
      onChanged('');
    } else if (result != null) {
      onChanged(result);
    }
  }

  Future<void> _showActionFieldPicker({
    required String field,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) async {
    await _showFieldValuePicker(
      field: field,
      currentValue: currentValue,
      onChanged: onChanged,
    );
  }

  List<String> _loadSymbolNames(String symbolType) {
    try {
      final bookId = widget.bookId ??
          (context.read<BooksProvider>().selectedBook?.id);
      if (bookId == null) return [];
      // Symbols are loaded on-demand — for now return empty to show text field
      return [];
    } catch (_) {
      return [];
    }
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
        title: Text(isEdit
            ? L10nManager.l10n.bookkeepingRuleEdit
            : L10nManager.l10n.bookkeepingRuleAdd),
      ),
      body: SingleChildScrollView(
        padding: spacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBasicInfoCard(theme),
            const SizedBox(height: 16),
            _buildConditionCard(theme),
            const SizedBox(height: 16),
            _buildActionsCard(theme, colorScheme),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard(ThemeData theme) {
    return CommonCardContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('基础信息',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: '规则名称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(_isActive ? '已启用' : '已停用'),
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _priorityCtrl,
            decoration: const InputDecoration(
              labelText: '优先级',
              border: OutlineInputBorder(),
              helperText: '数值越大优先级越高',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildConditionCard(ThemeData theme) {
    return CommonCardContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('条件',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: '添加',
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'leaf', child: const Text('条件')),
                  PopupMenuItem(value: 'group', child: const Text('条件组')),
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
            categories: _categories,
            funds: _funds,
            shops: _shops,
            onShowFieldPicker: _showFieldValuePicker,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(ThemeData theme, ColorScheme colorScheme) {
    return CommonCardContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('操作',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
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
                child: Text('暂无操作，请点击右上角添加',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurface.withAlpha(128))),
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
                        initialValue: _actionFieldLabels.containsKey(action.field)
                            ? action.field
                            : _actionFieldLabels.keys.first,
                        decoration: const InputDecoration(
                          labelText: '字段',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: _actionFieldLabels.entries
                            .map((e) =>
                                DropdownMenuItem(value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => action.field = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ActionValueField(
                        field: action.field,
                        value: action.value,
                        onChanged: (v) => action.value = v,
                        onShowFieldPicker: _showActionFieldPicker,
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
    );
  }

  Widget _buildSaveButton() {
    return FilledButton(
      onPressed: _loading ? null : _save,
      child: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('保存'),
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
  final List<dynamic> categories;
  final List<dynamic> funds;
  final List<dynamic> shops;
  final Future<void> Function({
    required String field,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) onShowFieldPicker;

  const _ConditionGroupEditor({
    required this.conditions,
    required this.logicOperator,
    required this.onLogicOperatorChanged,
    required this.onStateChanged,
    this.categories = const [],
    this.funds = const [],
    this.shops = const [],
    required this.onShowFieldPicker,
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

  /// 各字段支持的比较方式
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
            '暂无条件，请点击右上角添加',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colorScheme.onSurface.withAlpha(128)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AND / OR 选择器
        SegmentedButton<String>(
          showSelectedIcon: false,
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
            padding: const EdgeInsets.only(bottom: 8),
            child: condition.isLeaf
                ? _buildLeafRow(context, condition, idx)
                : _buildGroupRow(context, condition, idx),
          );
        }),
        // 内部添加条件按钮
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: PopupMenuButton<String>(
            child: TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('添加条件'),
              onPressed: null,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'leaf', child: Text('条件')),
              const PopupMenuItem(value: 'group', child: Text('条件组')),
            ],
            onSelected: (value) {
              if (value == 'leaf') {
                conditions.add(
                    _ConditionData(type: 'field_equals', field: 'categoryCode', value: ''));
              } else {
                conditions.add(_ConditionData(
                    logicOperator: 'AND',
                    children: [
                      _ConditionData(type: 'field_equals', field: 'categoryCode', value: '')
                    ]));
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
    final availableComparisons =
        _fieldComparisons[condition.field] ?? ['field_equals'];
    // 如果当前选中的比较方式不支持当前字段，重置为第一个支持的
    if (condition.type != null && !availableComparisons.contains(condition.type)) {
      condition.type = availableComparisons.first;
    }

    return CommonCardContainer(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：字段选择（左侧）
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: _fieldLabels.containsKey(condition.field)
                      ? condition.field!
                      : _fieldLabels.keys.first,
                  decoration: const InputDecoration(
                    labelText: '字段',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  items: _fieldLabels.entries
                      .map((e) => DropdownMenuItem(
                          value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      condition.field = v;
                      // 重置比较方式为字段支持的第一个
                      condition.type =
                          (_fieldComparisons[v] ?? ['field_equals']).first;
                      condition.value = '';
                      onStateChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: 4),
              // 删除按钮（右上角）
              IconButton(
                icon: Icon(Icons.remove_circle_outline,
                    color: theme.colorScheme.error, size: 20),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () {
                  conditions.removeAt(index);
                  onStateChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 第二行：比较方式（左侧） + 值选择器（右侧）
          Row(
            children: [
              // 比较方式下拉（左侧，较窄）
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
                        EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  ),
                  items: availableComparisons
                      .map((key) => DropdownMenuItem(
                          value: key,
                          child: Text(_typeLabels[key] ?? key,
                              style: const TextStyle(fontSize: 13))))
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
              const SizedBox(width: 8),
              // 值选择器（右侧，弹性）
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
                  onShowFieldPicker: onShowFieldPicker,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupRow(BuildContext context, _ConditionData condition, int index) {
    return CommonCardContainer(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('条件组',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary)),
              IconButton(
                icon: Icon(Icons.remove_circle_outline,
                    color: Theme.of(context).colorScheme.error, size: 20),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () {
                  conditions.removeAt(index);
                  onStateChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          _ConditionGroupEditor(
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
            onShowFieldPicker: onShowFieldPicker,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 操作值字段（根据字段类型展示选择器或输入框）
// ============================================================

class _ActionValueField extends StatelessWidget {
  final String field;
  final String value;
  final ValueChanged<String> onChanged;
  final Future<void> Function({
    required String field,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) onShowFieldPicker;

  const _ActionValueField({
    required this.field,
    required this.value,
    required this.onChanged,
    required this.onShowFieldPicker,
  });

  @override
  Widget build(BuildContext context) {
    final isReferenceField = [
      'categoryCode', 'fundId', 'shopCode', 'tagCode', 'projectCode',
    ].contains(field);

    if (isReferenceField) {
      final labels = {
        'categoryCode': '分类',
        'fundId': '账户',
        'shopCode': '商家',
        'tagCode': '标签',
        'projectCode': '项目',
      };
      return InkWell(
        onTap: () => onShowFieldPicker(
          field: field,
          currentValue: value,
          onChanged: onChanged,
        ),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: labels[field] ?? '值',
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          child: Text(
            value.isNotEmpty ? value : '请选择',
            style: TextStyle(
              color: value.isNotEmpty
                  ? null
                  : Theme.of(context).colorScheme.onSurface.withAlpha(128),
            ),
          ),
        ),
      );
    }

    return TextField(
      decoration: const InputDecoration(
        labelText: '值',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      controller: TextEditingController(text: value),
      onChanged: onChanged,
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
  final Future<void> Function({
    required String field,
    required String currentValue,
    required ValueChanged<String> onChanged,
  }) onShowFieldPicker;

  const _ValueSelector({
    super.key,
    required this.conditionType,
    required this.field,
    required this.value,
    required this.onChanged,
    required this.onShowFieldPicker,
  });

  @override
  Widget build(BuildContext context) {
    // 金额范围 → 双输入（min / max）
    if (conditionType == 'amount_range') {
      return _buildAmountRange();
    }
    // 属于 → 逗号分隔多值
    if (conditionType == 'field_in') {
      return _buildMultiValueField();
    }
    // 字段等于 → 根据字段类型展示选择器或输入框
    return _buildValueByField(context);
  }

  Widget _buildValueByField(BuildContext context) {
    switch (field) {
      case 'type':
        return _buildTypeSelector();
      case 'categoryCode':
      case 'fundId':
      case 'shopCode':
      case 'tagCode':
      case 'projectCode':
        return _buildSelectionField(context);
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

  Widget _buildSelectionField(BuildContext context) {
    final labels = {
      'categoryCode': '分类',
      'fundId': '账户',
      'shopCode': '商家',
      'tagCode': '标签',
      'projectCode': '项目',
    };
    return InkWell(
      onTap: () => onShowFieldPicker(
        field: field,
        currentValue: value?.toString() ?? '',
        onChanged: (v) => onChanged(v),
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labels[field] ?? '值',
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        child: Text(
          value != null && value.toString().isNotEmpty ? value.toString() : '请选择',
          style: TextStyle(
            color: value != null && value.toString().isNotEmpty
                ? null
                : Theme.of(context).colorScheme.onSurface.withAlpha(128),
          ),
        ),
      ),
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
