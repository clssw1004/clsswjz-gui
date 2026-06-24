import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vo/bookkeeping_rule_vo.dart';
import '../../providers/bookkeeping_rule_provider.dart';
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
        title: const Text('记账规则'), // 先写死，后续国际化
      ),
      body: Consumer<BookkeepingRuleProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.rules.isEmpty) return const CommonLoadingView();
          if (provider.error != null && provider.rules.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(provider.error!, style: TextStyle(color: cs.error)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('重试')),
            ]));
          }
          if (provider.rules.isEmpty) return CommonEmptyView(message: '暂无记账规则');

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
                            Text('优先级: ${rule.priority}', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Switch(
                        value: rule.isActive,
                        onChanged: (v) async {
                          final result = await provider.updateRule(rule.id, isActive: v);
                          if (!result.ok && mounted) {
                            ToastUtil.showError(result.message ?? '操作失败');
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
                          child: Text(
                            _conditionSummary(rule),
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow_outlined, size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _actionSummary(rule),
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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

  /// 生成条件摘要文本
  String _conditionSummary(BookkeepingRuleVO rule) {
    final parts = <String>[];
    for (final c in rule.conditions) {
      if (c.isLeaf) {
        final op = c.type == 'field_in' ? '∈' : '=';
        parts.add('${c.field} $op ${c.value}');
      } else {
        // 非叶子节点：显示逻辑运算符和子条件数量
        final op = c.logicOperator ?? 'AND';
        parts.add('(${c.conditions?.length ?? 0} 项 $op)');
      }
    }
    return '条件: ${parts.join(' AND ')}';
  }

  /// 生成操作摘要文本
  String _actionSummary(BookkeepingRuleVO rule) {
    final parts = rule.actions.map((a) => '设 ${a.field} = ${a.value}');
    return '操作: ${parts.join(', ')}';
  }
}
