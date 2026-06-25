import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/symbol_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/rule/condition_model.dart';
import '../../models/vo/bookkeeping_rule_vo.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../providers/bookkeeping_rule_provider.dart';
import '../../providers/books_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/common_select_form_field.dart';

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
  bool _dataLoading = true;

  // 引用数据
  List<AccountCategory> _categories = [];
  List<UserFundVO> _funds = [];
  List<AccountShop> _shops = [];
  List<AccountSymbol> _tags = [];
  List<AccountSymbol> _projects = [];

  /// 操作字段列表（用于 DropdownButtonFormField 的 items）
  List<MapEntry<String, String>> _actionFieldValues() {
    final l = L10nManager.l10n;
    return [
      MapEntry('categoryCode', l.bookkeepingRuleLabelFieldCategory),
      MapEntry('fundId', l.bookkeepingRuleLabelFieldFund),
      MapEntry('shopCode', l.bookkeepingRuleLabelFieldShop),
      MapEntry('tagCode', l.bookkeepingRuleLabelFieldTag),
      MapEntry('projectCode', l.bookkeepingRuleLabelFieldProject),
    ];
  }

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
    final bookId =
        widget.bookId ?? context.read<BooksProvider>().selectedBook?.id;
    if (bookId == null) return;
    final userId = AppConfigManager.instance.userId;
    try {
      final r1 = await DriverFactory.driver.listCategoriesByBook(userId, bookId);
      final r2 = await DriverFactory.driver.listFundsByBook(userId, bookId);
      final r3 = await DriverFactory.driver.listShopsByBook(userId, bookId);
      final r4 = await DriverFactory.driver.listSymbolsByBook(userId, bookId, symbolType: SymbolType.tag);
      final r5 = await DriverFactory.driver.listSymbolsByBook(userId, bookId, symbolType: SymbolType.project);
      if (mounted) {
        setState(() {
          _categories = r1.data ?? [];
          _funds = r2.data ?? [];
          _shops = r3.data ?? [];
          _tags = r4.data ?? [];
          _projects = r5.data ?? [];
          _dataLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _dataLoading = false);
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
  // 自动命名
  // ============================================================

  String _fieldLabelName(String field) {
    final l = L10nManager.l10n;
    return switch (field) {
      'type' => l.bookkeepingRuleLabelFieldType,
      'categoryCode' => l.bookkeepingRuleLabelFieldCategory,
      'fundId' => l.bookkeepingRuleLabelFieldFund,
      'shopCode' => l.bookkeepingRuleLabelFieldShop,
      'tagCode' => l.bookkeepingRuleLabelFieldTag,
      'projectCode' => l.bookkeepingRuleLabelFieldProject,
      'amount' => l.bookkeepingRuleLabelFieldAmount,
      _ => field,
    };
  }

  /// 解析字段值code为展示名称
  String _resolveName(String field, dynamic value) {
    if (value == null || value.toString().isEmpty) return '';
    final key = value.toString();
    switch (field) {
      case 'type':
        return switch (key) {
          'EXPENSE' => L10nManager.l10n.expense,
          'INCOME' => L10nManager.l10n.income,
          'TRANSFER' => L10nManager.l10n.transfer,
          _ => key,
        };
      case 'categoryCode':
        return _categories.where((c) => c.code == key).firstOrNull?.name ?? key;
      case 'fundId':
        return _funds.where((f) => f.id == key).firstOrNull?.name ?? key;
      case 'shopCode':
        return _shops.where((s) => s.code == key).firstOrNull?.name ?? key;
      default:
        return key;
    }
  }

  /// 根据条件和操作自动生成规则名称
  String _generateRuleName() {
    final l10n = L10nManager.l10n;
    final parts = <String>[];

    // 条件摘要
    if (_conditions.isNotEmpty) {
      final condText = _buildConditionSummary(_conditions, _rootLogicOperator);
      parts.add('${l10n.bookkeepingRuleAutoNamePrefix}$condText${l10n.bookkeepingRuleAutoNameSeparator}');
    }

    // 操作摘要
    if (_actions.isNotEmpty) {
      final actionTexts = _actions.map((a) {
        final fieldLabel = _fieldLabelName(a.field);
        final displayValue = _resolveName(a.field, a.value);
        return l10n.bookkeepingRuleNameSetField(fieldLabel, displayValue);
      });
      parts.add(actionTexts.join('，'));
    }

    return parts.join(l10n.bookkeepingRuleAutoNameConnector);
  }

  String _buildConditionSummary(List<_ConditionData> conds, String logicOp) {
    final l10n = L10nManager.l10n;
    final textParts = conds.map((c) {
      if (c.isLeaf) {
        final fieldLabel = _fieldLabelName(c.field ?? '');
        if (c.type == 'amount_range' && c.value is Map) {
          final map = c.value as Map;
          final min = map['minAmount'];
          final max = map['maxAmount'];
          if (min != null && max != null) {
            return '$fieldLabel${l10n.bookkeepingRuleNameAmountBetween(min.toString(), max.toString())}';
          }
          if (min != null) return '$fieldLabel${l10n.bookkeepingRuleNameAmountGte}$min';
          if (max != null) return '$fieldLabel${l10n.bookkeepingRuleNameAmountLte}$max';
          return fieldLabel;
        }
        final displayValue = _resolveName(c.field ?? '', c.value);
        if (c.type == 'field_in') {
          String vals;
          if (c.value is List) {
            vals = (c.value as List).map((v) => _resolveName(c.field ?? '', v)).join('、');
          } else vals = displayValue;
          return '$fieldLabel${l10n.bookkeepingRuleNameFieldIn}$vals';
        }
        return '$fieldLabel${l10n.bookkeepingRuleNameFieldIs}$displayValue';
      }
      return c.children.isNotEmpty
          ? '(${_buildConditionSummary(c.children, c.logicOperator ?? 'AND')})'
          : '';
    }).toList();

    final conj = logicOp == 'OR' ? l10n.bookkeepingRuleAutoNameOr : l10n.bookkeepingRuleAutoNameAnd;
    return textParts.join(' $conj ');
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
    // 自动命名：用户未填写名称时根据条件和操作生成
    if (_nameCtrl.text.trim().isEmpty) {
      _nameCtrl.text = _generateRuleName();
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
        ToastUtil.showError(result.message?.toString() ?? L10nManager.l10n.bookkeepingRuleMessageSaveFailed);
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
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(L10nManager.l10n.bookkeepingRuleLabelSave),
          ),
        ],
      ),
      body: _dataLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: spacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBasicInfoCard(theme),
                  const SizedBox(height: 16),
                  _buildConditionCard(theme),
                  const SizedBox(height: 16),
                  _buildActionsCard(theme, colorScheme),
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
          Text(L10nManager.l10n.bookkeepingRuleLabelBasicInfo,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: L10nManager.l10n.bookkeepingRuleName,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: Text(_isActive ? L10nManager.l10n.bookkeepingRuleEnabled : L10nManager.l10n.bookkeepingRuleDisabled),
            value: _isActive,
            onChanged: (v) => setState(() => _isActive = v),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _priorityCtrl,
            decoration: InputDecoration(
              labelText: L10nManager.l10n.bookkeepingRulePriority,
              border: OutlineInputBorder(),
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
              Text(L10nManager.l10n.bookkeepingRuleCondition,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: L10nManager.l10n.bookkeepingRuleAddCondition,
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'leaf', child: Text(L10nManager.l10n.bookkeepingRuleCondition)),
                  PopupMenuItem(value: 'group', child: Text(L10nManager.l10n.bookkeepingRuleConditionGroup)),
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
            tags: _tags,
            projects: _projects,
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
              Text(L10nManager.l10n.bookkeepingRuleAction,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: L10nManager.l10n.bookkeepingRuleAddAction,
                onPressed: _addAction,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_actions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(L10nManager.l10n.bookkeepingRulePlaceholderActionEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withAlpha(128))),
              ),
            )
          else
            ..._actions.asMap().entries.map((entry) {
              final idx = entry.key;
              final action = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: _FieldLabelChip(
                              label: L10nManager.l10n.bookkeepingRuleLabelField,
                              color: colorScheme.primary,
                            ),
                          ),
                          DropdownButtonFormField<String>(
                            initialValue: action.field,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              isDense: true,
                              filled: true,
                              fillColor: colorScheme.primary.withAlpha(8),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                            ),
                            items: _actionFieldValues()
                                .map((e) => DropdownMenuItem(
                                    value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => action.field = v);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4, left: 4),
                            child: _FieldLabelChip(
                              label: L10nManager.l10n.bookkeepingRuleLabelValue,
                              color: colorScheme.secondary,
                            ),
                          ),
                          _ActionValueSelector(
                          field: action.field,
                          value: action.value,
                          onChanged: (v) => setState(() => action.value = v),
                          categories: _categories,
                          funds: _funds,
                          shops: _shops,
                          tags: _tags,
                          projects: _projects,
                        ),
                      ],
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

}

// ============================================================
// 条件组编辑器（递归组件）
// ============================================================

class _ConditionGroupEditor extends StatelessWidget {
  final List<_ConditionData> conditions;
  final String logicOperator;
  final ValueChanged<String> onLogicOperatorChanged;
  final VoidCallback onStateChanged;
  final List<AccountCategory> categories;
  final List<UserFundVO> funds;
  final List<AccountShop> shops;
  final List<AccountSymbol> tags;
  final List<AccountSymbol> projects;

  const _ConditionGroupEditor({
    required this.conditions,
    required this.logicOperator,
    required this.onLogicOperatorChanged,
    required this.onStateChanged,
    this.categories = const [],
    this.funds = const [],
    this.shops = const [],
    this.tags = const [],
    this.projects = const [],
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
        // AND / OR 选择器（≥2个条件时才显示）
        if (conditions.length >= 2)
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
              label: Text(L10nManager.l10n.bookkeepingRuleAddCondition),
              onPressed: null,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'leaf', child: Text(L10nManager.l10n.bookkeepingRuleCondition)),
              PopupMenuItem(value: 'group', child: Text(L10nManager.l10n.bookkeepingRuleConditionGroup)),
            ],
            onSelected: (value) {
              if (value == 'leaf') {
                conditions.add(_ConditionData(
                    type: 'field_equals', field: 'categoryCode', value: ''));
              } else {
                conditions.add(_ConditionData(
                    logicOperator: 'AND',
                    children: [_ConditionData(
                        type: 'field_equals', field: 'categoryCode', value: '')]));
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
    if (condition.type != null &&
        !availableComparisons.contains(condition.type)) {
      condition.type = availableComparisons.first;
    }

    return CommonCardContainer(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 第一行：字段选择
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: condition.field ?? _fieldComparisons.keys.first,
                  decoration: const InputDecoration(
                    labelText: '字段',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  ),
                  items: _fieldComparisons.keys
                      .map((k) => DropdownMenuItem(
                          value: k, child: Text(fieldLabel(k))))
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
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.remove_circle_outline,
                    color: theme.colorScheme.error, size: 20),
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
                onPressed: () {
                  conditions.removeAt(index);
                  onStateChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 第二行：比较方式 + 值选择器
          Row(
            children: [
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
                          child: Text(typeLabel(key),
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
              Expanded(
                child: _ConditionValueSelector(
                  key: ValueKey(
                      '${condition.type}_${condition.field}_$index'),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupRow(
      BuildContext context, _ConditionData condition, int index) {
    return CommonCardContainer(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(L10nManager.l10n.bookkeepingRuleConditionGroup,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary)),
              IconButton(
                icon: Icon(Icons.remove_circle_outline,
                    color: Theme.of(context).colorScheme.error, size: 20),
                constraints:
                    const BoxConstraints(minWidth: 32, minHeight: 32),
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
            tags: tags,
            projects: projects,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 条件值选择器 — 根据字段类型复用 CommonSelectFormField
// ============================================================

class _ConditionValueSelector extends StatelessWidget {
  final String conditionType;
  final String field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final List<AccountCategory> categories;
  final List<UserFundVO> funds;
  final List<AccountShop> shops;
  final List<AccountSymbol> tags;
  final List<AccountSymbol> projects;

  const _ConditionValueSelector({
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

// ============================================================
// 操作值选择器 — 复用 CommonSelectFormField
// ============================================================

class _ActionValueSelector extends StatelessWidget {
  final String field;
  final String value;
  final ValueChanged<String> onChanged;
  final List<AccountCategory> categories;
  final List<UserFundVO> funds;
  final List<AccountShop> shops;
  final List<AccountSymbol> tags;
  final List<AccountSymbol> projects;

  const _ActionValueSelector({
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
    switch (field) {
      case 'categoryCode':
        return CommonSelectFormField<AccountCategory>(
          key: ValueKey('act_cat_$value'),
          items: categories,
          displayField: (c) => c.name,
          keyField: (c) => c.code,
          value: value,
          label: '分类',
          allowCreate: false,
          onChanged: (v) { if (v is AccountCategory) onChanged(v.code); },
        );
      case 'fundId':
        return CommonSelectFormField<UserFundVO>(
          key: ValueKey('act_fund_$value'),
          items: funds,
          displayField: (f) => f.name,
          keyField: (f) => f.id,
          value: value,
          label: '账户',
          allowCreate: false,
          onChanged: (v) { if (v is UserFundVO) onChanged(v.id); },
        );
      case 'shopCode':
        return CommonSelectFormField<AccountShop>(
          key: ValueKey('act_shop_$value'),
          items: shops,
          displayField: (s) => s.name,
          keyField: (s) => s.code,
          value: value,
          label: '商家',
          allowCreate: false,
          onChanged: (v) { if (v is AccountShop) onChanged(v.code); },
        );
      case 'tagCode':
        return CommonSelectFormField<AccountSymbol>(
          key: ValueKey('act_tag_$value'),
          items: tags,
          displayField: (s) => s.name,
          keyField: (s) => s.code,
          value: value,
          label: '标签',
          allowCreate: false,
          onChanged: (v) { if (v is AccountSymbol) onChanged(v.code); },
        );
      case 'projectCode':
        return CommonSelectFormField<AccountSymbol>(
          key: ValueKey('act_proj_$value'),
          items: projects,
          displayField: (s) => s.name,
          keyField: (s) => s.code,
          value: value,
          label: '项目',
          allowCreate: false,
          onChanged: (v) { if (v is AccountSymbol) onChanged(v.code); },
        );
      default:
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
}

/// 字段/值标签小徽章
class _FieldLabelChip extends StatelessWidget {
  final String label;
  final Color color;
  const _FieldLabelChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
