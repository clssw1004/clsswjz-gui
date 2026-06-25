import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vo/bookkeeping_rule_vo.dart';
import '../../providers/bookkeeping_rule_provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_empty_view.dart';
import '../../widgets/common/common_loading_view.dart';
import '../../utils/toast_util.dart';

/// 记账规则列表页
class BookkeepingRuleListPage extends StatefulWidget {
  const BookkeepingRuleListPage({super.key});
  @override State<BookkeepingRuleListPage> createState() => _BookkeepingRuleListPageState();
}

class _BookkeepingRuleListPageState extends State<BookkeepingRuleListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    if (!mounted) return;
    final provider = context.read<BookkeepingRuleProvider>();
    final bookId = context.read<BooksProvider>().selectedBook?.id;
    if (bookId == null) return;
    provider.loadRules(bookId);
  }

  String? get _currentBookId => context.read<BooksProvider>().selectedBook?.id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.bookkeepingRuleList), // 先写死，后续国际化
      ),
      body: Consumer<BookkeepingRuleProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.rules.isEmpty) return const CommonLoadingView();
          if (provider.error != null && provider.rules.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(provider.error!, style: TextStyle(color: cs.error)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: Text(L10nManager.l10n.retry)),
            ]));
          }
          if (provider.rules.isEmpty) return CommonEmptyView(message: L10nManager.l10n.bookkeepingRuleEmpty);

          return RefreshIndicator(
            onRefresh: () async {
              final id = _currentBookId;
              if (id != null) await provider.loadRules(id);
            },
            child: ListView.builder(
              padding: spacing.listPadding,
              itemCount: provider.rules.length,
              itemBuilder: (_, i) => _buildCard(provider.rules[i], provider),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bookId = _currentBookId;
          if (bookId == null) return;
          if (await Navigator.pushNamed(context, AppRoutes.bookkeepingRuleForm, arguments: {'bookId': bookId}) == true) {
            context.read<BookkeepingRuleProvider>().loadRules(bookId);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(BookkeepingRuleVO rule, BookkeepingRuleProvider provider) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pushNamed(context, AppRoutes.bookkeepingRuleForm, arguments: {'rule': rule}).then((_) {
            final bookId = _currentBookId;
            if (bookId != null) provider.loadRules(bookId);
          }),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 头部：名称 + 优先级 + 启用开关 ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
                  child: Row(
                    children: [
                      // 优先级指示条
                      Container(
                        width: 4, height: 32,
                        decoration: BoxDecoration(
                          color: rule.isActive ? cs.primary : cs.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rule.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(L10nManager.l10n.bookkeepingRuleLabelPriority(rule.priority), style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Switch(
                        value: rule.isActive,
                        onChanged: (v) async {
                          final result = await provider.updateRule(rule.id, isActive: v);
                          if (!result.ok && mounted) {
                            ToastUtil.showError(result.message ?? L10nManager.l10n.bookkeepingRuleMessageOpFailed);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // ── 条件摘要 ──
                if (rule.conditions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 2, 16, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.tertiary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(color: cs.tertiary.withAlpha(100), width: 3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt_outlined, size: 14, color: cs.tertiary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _conditionSummary(rule, provider),
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                // ── 操作摘要 ──
                if (rule.actions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(color: cs.primary.withAlpha(100), width: 3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow_outlined, size: 14, color: cs.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildActionRichText(rule, provider, theme, cs),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fieldLabelName(String field) {
    final l10n = L10nManager.l10n;
    return switch (field) {
      'type' => l10n.bookkeepingRuleLabelFieldType,
      'categoryCode' => l10n.bookkeepingRuleLabelFieldCategory,
      'fundId' => l10n.bookkeepingRuleLabelFieldFund,
      'shopCode' => l10n.bookkeepingRuleLabelFieldShop,
      'tagCode' => l10n.bookkeepingRuleLabelFieldTag,
      'projectCode' => l10n.bookkeepingRuleLabelFieldProject,
      'amount' => l10n.bookkeepingRuleLabelFieldAmount,
      _ => field,
    };
  }

  String _typeLabelName(String type) {
    final l10n = L10nManager.l10n;
    return switch (type) {
      'field_equals' => l10n.bookkeepingRuleLabelTypeEq,
      'field_in' => l10n.bookkeepingRuleLabelTypeIn,
      'amount_range' => l10n.bookkeepingRuleLabelTypeRange,
      _ => type,
    };
  }

  /// 生成条件摘要文本
  String _conditionSummary(BookkeepingRuleVO rule, BookkeepingRuleProvider provider) {
    final l10n = L10nManager.l10n;
    final parts = <String>[];
    for (final c in rule.conditions) {
      if (c.isLeaf) {
        final fieldLabel = _fieldLabelName(c.field ?? '');
        if (c.type == 'amount_range') {
          if (c.value is Map) {
            final m = c.value as Map;
            final min = m['minAmount'];
            final max = m['maxAmount'];
            if (min != null && max != null) parts.add('$fieldLabel${l10n.bookkeepingRuleNameAmountBetween(min.toString(), max.toString())}');
            else if (min != null) parts.add('$fieldLabel${l10n.bookkeepingRuleNameAmountGte}$min');
            else if (max != null) parts.add('$fieldLabel${l10n.bookkeepingRuleNameAmountLte}$max');
            else parts.add(fieldLabel);
          }
        } else {
          final op = _typeLabelName(c.type ?? '');
          final displayVal = provider.resolveValue(c.field ?? '', c.value);
          if (c.type == 'field_equals') {
            parts.add('$fieldLabel${l10n.bookkeepingRuleNameFieldIs}$displayVal');
          } else {
            parts.add('$fieldLabel$op$displayVal');
          }
        }
      } else {
        final op = c.logicOperator ?? 'AND';
        parts.add('(${c.conditions?.length ?? 0}${l10n.bookkeepingRuleLabelSubItem}$op)');
      }
    }
    return '${l10n.bookkeepingRuleLabelConditionTitle}${parts.join(' ')}';
  }

  /// 操作摘要文本（纯文本，用于条件判断）
  String _actionSummary(BookkeepingRuleVO rule, BookkeepingRuleProvider provider) {
    final l10n = L10nManager.l10n;
    final parts = rule.actions.map((a) {
      final fieldLabel = _fieldLabelName(a.field);
      return l10n.bookkeepingRuleNameSetField(fieldLabel, provider.resolveValue(a.field, a.value));
    });
    return '${l10n.bookkeepingRuleLabelActionTitle}${parts.join('，')}';
  }

  /// 操作摘要 RichText（字段名和值使用不同颜色）
  Widget _buildActionRichText(BookkeepingRuleVO rule, BookkeepingRuleProvider provider, ThemeData theme, ColorScheme cs) {
    final l10n = L10nManager.l10n;
    final spans = <InlineSpan>[];
    spans.add(TextSpan(
      text: l10n.bookkeepingRuleLabelActionTitle,
      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
    ));
    for (var i = 0; i < rule.actions.length; i++) {
      final a = rule.actions[i];
      final fieldLabel = _fieldLabelName(a.field);
      final valueText = provider.resolveValue(a.field, a.value);
      if (i > 0) {
        spans.add(TextSpan(text: '，', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)));
      }
      // "设置" prefix
      spans.add(TextSpan(
        text: l10n.bookkeepingRuleAutoNamePrefix == 'When' ? 'set ' : '设置',
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ));
      // field name (primary color, bold)
      spans.add(TextSpan(
        text: fieldLabel,
        style: theme.textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
      ));
      // "为" / "to" middle
      spans.add(TextSpan(
        text: l10n.bookkeepingRuleAutoNamePrefix == 'When' ? ' to ' : '为',
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ));
      // value (secondary color, bold)
      spans.add(TextSpan(
        text: valueText,
        style: theme.textTheme.bodySmall?.copyWith(color: cs.secondary, fontWeight: FontWeight.w600),
      ));
    }
    return Text.rich(
      TextSpan(children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
