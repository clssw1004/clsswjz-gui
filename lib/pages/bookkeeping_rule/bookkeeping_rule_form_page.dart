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
import 'editor_models.dart';
import 'condition_editor.dart';
import 'action_value_widgets.dart';

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
  List<ConditionData> _conditions = [];
  String _rootLogicOperator = 'AND';
  List<ActionData> _actions = [];
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
          .map((a) => ActionData(
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

  ConditionData _parseConditionNode(ConditionNode node) {
    if (node.isLeaf) {
      return ConditionData(
        type: node.type ?? 'field_equals',
        field: node.field ?? '',
        value: node.value,
      );
    }
    return ConditionData(
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

  String _buildConditionSummary(List<ConditionData> conds, String logicOp) {
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

  Map<String, dynamic> _conditionToJson(ConditionData c) {
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

  ConditionData _createLeafCondition() =>
      ConditionData(type: 'field_equals', field: 'categoryCode', value: '');

  ConditionData _createGroupCondition() =>
      ConditionData(logicOperator: 'AND', children: [_createLeafCondition()]);

  void _addAction() =>
      setState(() => _actions.add(ActionData(field: 'categoryCode', value: '')));

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(L10nManager.l10n.bookkeepingRuleCondition,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              if (_conditions.length >= 2)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 'AND', label: Text('AND')),
                      ButtonSegment(value: 'OR', label: Text('OR')),
                    ],
                    selected: {_rootLogicOperator},
                    onSelectionChanged: (v) =>
                        setState(() => _rootLogicOperator = v.first),
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
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
          ConditionGroupEditor(
            showLogicSelector: false,
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
                      child: DropdownButtonFormField<String>(
                        initialValue: action.field,
                        decoration: InputDecoration(
                          labelText: L10nManager.l10n.bookkeepingRuleLabelField,
                          border: const OutlineInputBorder(),
                          isDense: true,
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
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: ActionValueSelector(
                        field: action.field,
                        value: action.value,
                        onChanged: (v) => setState(() => action.value = v),
                        categories: _categories,
                        funds: _funds,
                        shops: _shops,
                        tags: _tags,
                        projects: _projects,
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

