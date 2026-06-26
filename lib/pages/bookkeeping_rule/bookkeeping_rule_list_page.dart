import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/rule/action_model.dart';
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
      child: Dismissible(
        key: ValueKey('rule_${rule.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(L10nManager.l10n.bookkeepingRuleConfirmDelete),
              content: Text(L10nManager.l10n.bookkeepingRuleLabelConfirmDelete),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(L10nManager.l10n.cancel)),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(L10nManager.l10n.bookkeepingRuleLabelDelete)),
              ],
            ),
          );
          if (confirm == true) {
            final bookId = _currentBookId;
            final result = await provider.deleteRule(rule.id, bookId: bookId);
            if (!result.ok && context.mounted) {
              ToastUtil.showError(result.message ?? L10nManager.l10n.bookkeepingRuleMessageOpFailed);
            }
          }
          return false; // We handle deletion ourselves via provider
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: cs.error,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.delete_outline, color: cs.onError, size: 24),
        ),
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
                            Text(rule.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                    child: Row(
                      children: [
                        Icon(Icons.filter_alt_outlined, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildConditionRichText(rule, provider, cs),
                        ),
                      ],
                    ),
                  ),
                // ── 操作摘要 ──
                if (rule.actions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow_outlined, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildActionRichText(rule.actions, provider, cs),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
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

  /// 条件摘要 RichText
  Widget _buildConditionRichText(BookkeepingRuleVO rule, BookkeepingRuleProvider provider, ColorScheme cs) {
    final spans = <InlineSpan>[];
    spans.add(TextSpan(
      text: L10nManager.l10n.bookkeepingRuleLabelConditionTitle,
      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
    ));
    for (final c in rule.conditions) {
      if (c.isLeaf) {
        final fieldLabel = _fieldLabelName(c.field ?? '');
        final displayVal = provider.resolveValue(c.field ?? '', c.value);
        if (c.type == 'amount_range') {
          if (c.value is Map) {
            final m = c.value as Map;
            final min = m['minAmount'];
            final max = m['maxAmount'];
            if (min != null && max != null) {
              spans.add(TextSpan(text: '$fieldLabel${L10nManager.l10n.bookkeepingRuleNameAmountBetween(min.toString(), max.toString())}', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)));
            } else if (min != null) {
              spans.add(TextSpan(text: fieldLabel, style: TextStyle(color: cs.primary, fontSize: 13, fontWeight: FontWeight.w600)));
              spans.add(TextSpan(text: L10nManager.l10n.bookkeepingRuleNameAmountGte, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)));
              spans.add(TextSpan(text: '$min', style: TextStyle(color: cs.secondary, fontSize: 13, fontWeight: FontWeight.w600)));
            } else if (max != null) {
              spans.add(TextSpan(text: fieldLabel, style: TextStyle(color: cs.primary, fontSize: 13, fontWeight: FontWeight.w600)));
              spans.add(TextSpan(text: L10nManager.l10n.bookkeepingRuleNameAmountLte, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)));
              spans.add(TextSpan(text: '$max', style: TextStyle(color: cs.secondary, fontSize: 13, fontWeight: FontWeight.w600)));
            } else {
              spans.add(TextSpan(text: fieldLabel, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)));
            }
          }
        } else {
          spans.add(TextSpan(text: fieldLabel, style: TextStyle(color: cs.primary, fontSize: 13, fontWeight: FontWeight.w600)));
          spans.add(TextSpan(text: L10nManager.l10n.bookkeepingRuleNameFieldIs, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)));
          spans.add(TextSpan(text: displayVal, style: TextStyle(color: cs.secondary, fontSize: 13, fontWeight: FontWeight.w600)));
        }
        spans.add(TextSpan(text: '  ', style: TextStyle(fontSize: 13)));
      } else {
        final op = c.logicOperator ?? 'AND';
        spans.add(TextSpan(text: '(${c.conditions?.length ?? 0}${L10nManager.l10n.bookkeepingRuleLabelSubItem}$op)', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)));
      }
    }
    return Text.rich(TextSpan(children: spans), maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  /// 操作摘要 RichText（字段名和值使用不同颜色）
  Widget _buildActionRichText(List<ActionNode> actions, BookkeepingRuleProvider provider, ColorScheme cs) {
    final spans = <InlineSpan>[];
    spans.add(TextSpan(
      text: L10nManager.l10n.bookkeepingRuleLabelActionTitle,
      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
    ));
    for (var i = 0; i < actions.length; i++) {
      final a = actions[i];
      final fieldLabel = _fieldLabelName(a.field);
      final valueText = provider.resolveValue(a.field, a.value);
      if (i > 0) {
        spans.add(TextSpan(text: '，', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)));
      }
      spans.add(TextSpan(text: '设置', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)));
      spans.add(TextSpan(
        text: fieldLabel,
        style: TextStyle(color: cs.primary, fontSize: 13, fontWeight: FontWeight.w600),
      ));
      spans.add(TextSpan(text: '为', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)));
      spans.add(TextSpan(
        text: valueText,
        style: TextStyle(color: cs.secondary, fontSize: 13, fontWeight: FontWeight.w600),
      ));
    }
    return Text.rich(TextSpan(children: spans), maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
