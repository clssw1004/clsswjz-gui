import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../drivers/driver_factory.dart';
import '../../utils/color_util.dart';
import '../../utils/toast_util.dart';
import '../../models/vo/recurring_config_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/books_provider.dart';
import '../../providers/recurring_config_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_bottom_sheet.dart';
import '../../widgets/common/common_empty_view.dart';
import '../../widgets/common/common_loading_view.dart';

class RecurringConfigListPage extends StatefulWidget {
  const RecurringConfigListPage({super.key});
  @override State<RecurringConfigListPage> createState() => _RecurringConfigListPageState();
}

class _RecurringConfigListPageState extends State<RecurringConfigListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() async {
    if (!mounted) return;
    final provider = context.read<RecurringConfigProvider>();
    final bookId = context.read<BooksProvider>().selectedBook?.id;
    if (bookId == null) return;
    await provider.loadConfigs(bookId);
    if (!mounted) return;
    await provider.checkDueGenerations(bookId: bookId);
    if (!mounted) return;
    await provider.loadConfigs(bookId);
  }

  String? get _currentBookId => context.read<BooksProvider>().selectedBook?.id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.recurringConfigList),
        actions: [
          IconButton(icon: const Icon(Icons.content_copy), tooltip: L10nManager.l10n.recurringConfigCopy, onPressed: _showCopyDialog),
        ],
      ),
      body: Consumer<RecurringConfigProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.configs.isEmpty) return const CommonLoadingView();
          if (provider.error != null && provider.configs.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(provider.error!, style: TextStyle(color: cs.error)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: Text(L10nManager.l10n.retry)),
            ]));
          }
          if (provider.configs.isEmpty) return CommonEmptyView(message: L10nManager.l10n.emptyRecurringConfigs);

          return RefreshIndicator(
            onRefresh: () async { final id = _currentBookId; if (id != null) await provider.loadConfigs(id); },
            child: ListView.builder(
              padding: spacing.listPadding,
              itemCount: provider.configs.length,
              itemBuilder: (_, i) => _buildCard(provider.configs[i], provider),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final bookId = _currentBookId;
          if (bookId == null) return;
          if (await Navigator.pushNamed(context, AppRoutes.recurringConfigForm, arguments: {'bookId': bookId}) == true) {
            context.read<RecurringConfigProvider>().loadConfigs(bookId);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCard(RecurringConfigVO config, RecurringConfigProvider provider) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final amountColor = config.isIncome ? ColorUtil.INCOME : ColorUtil.EXPENSE;

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pushNamed(context, AppRoutes.recurringConfigDetail, arguments: config)
              .then((_) { final id = _currentBookId; if (id != null) provider.loadConfigs(id); }),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withAlpha(60)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 头部：类型指示条 + 金额 ──
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: cs.outlineVariant.withAlpha(40))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4, height: 32,
                        decoration: BoxDecoration(
                          color: amountColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(config.categoryName ?? config.categoryCode, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600))),
                      const SizedBox(width: 8),
                      Text(
                        '${config.isIncome ? '+' : '-'}¥${config.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(color: amountColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // ── 中间：频率 + 账户 ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      _buildTag(cs, Icons.repeat, config.frequencyDesc),
                      const SizedBox(width: 8),
                      if (config.fundName != null) _buildTag(cs, Icons.account_balance_wallet_outlined, config.fundName!),
                    ],
                  ),
                ),
                // ── 底部：日期 + 开关 ──
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withAlpha(30),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      if (config.isActive) ...[
                        Icon(Icons.schedule, size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(config.nextGenerateDateDesc ?? '待计算',
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 12),
                        Icon(Icons.check_circle_outline, size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(L10nManager.l10n.recurringConfigGeneratedCount(config.generatedCount),
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ] else
                        Text(L10nManager.l10n.recurringConfigDisabled,
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      const Spacer(),
                      SizedBox(
                        height: 28,
                        child: Switch.adaptive(
                          value: config.isActive,
                          onChanged: (v) => provider.toggleActive(config.id, v, bookId: _currentBookId),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) => _handleMenuAction(config, provider, v),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'edit', child: Text('编辑')),
                          const PopupMenuItem(value: 'generate', child: Text('立即生成')),
                          const PopupMenuItem(value: 'delete', child: Text('删除')),
                        ],
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

  Widget _buildTag(ColorScheme cs, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  // ── 操作 ──

  void _handleMenuAction(RecurringConfigVO config, RecurringConfigProvider provider, String action) async {
    switch (action) {
      case 'edit':
        if (await Navigator.pushNamed(context, AppRoutes.recurringConfigForm,
            arguments: {'config': config, 'bookId': _currentBookId}) == true) {
          final id = _currentBookId; if (id != null) provider.loadConfigs(id);
        }
      case 'generate':
        final r = await provider.generateNow(config.id);
        if (context.mounted) {
          if (r == 'generated') { ToastUtil.showSuccess('生成成功'); }
          else if (r == 'skip') { ToastUtil.showInfo('已存在，跳过'); }
          else { ToastUtil.showError(r); }
        }
        final id = _currentBookId; if (id != null) provider.loadConfigs(id);
      case 'delete':
        if (await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: Text(L10nManager.l10n.recurringConfigConfirmDelete),
          content: Text(L10nManager.l10n.recurringConfigDeleteConfirmMsg),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(L10nManager.l10n.cancel)),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(L10nManager.l10n.delete(''))),
          ],
        )) == true) {
          await provider.deleteConfig(config.id, bookId: _currentBookId);
        }
    }
  }

  void _showCopyDialog() {
    final books = context.read<BooksProvider>().books.where((b) => b.id != _currentBookId).toList();
    showModalBottomSheet(context: context, builder: (ctx) => CommonBottomSheet(
      title: L10nManager.l10n.recurringConfigCopy,
      child: books.isEmpty
          ? const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: CommonEmptyView(message: '该账本暂无固定收支配置'))
          : Column(mainAxisSize: MainAxisSize.min, children: books.map((book) => ListTile(
              leading: Icon(book.icon != null ? Icons.book : Icons.book_outlined),
              title: Text(book.name),
              onTap: () { Navigator.pop(ctx); _doCopy(book); },
            )).toList()),
    ));
  }

  void _doCopy(UserBookVO sourceBook) async {
    final provider = context.read<RecurringConfigProvider>();
    final result = await DriverFactory.driver.listRecurringConfigsWithNames(AppConfigManager.instance.userId, sourceBook.id);
    if (!result.ok || result.data == null || result.data!.isEmpty) {
      if (context.mounted) ToastUtil.showWarning(L10nManager.l10n.recurringConfigCopySourceEmpty);
      return;
    }
    final sourceConfigs = result.data!;
    final selectedIds = <String>{};
    bool deactivateOrigin = false;
    if (!context.mounted) return;

    showModalBottomSheet(context: context, isScrollControlled: true, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => CommonBottomSheet(
        title: L10nManager.l10n.recurringConfigCopySelect,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(child: ListView.builder(shrinkWrap: true, itemCount: sourceConfigs.length, itemBuilder: (ctx, i) {
            final c = sourceConfigs[i];
            return CheckboxListTile(
              title: Text('${c.isIncome ? L10nManager.l10n.income : L10nManager.l10n.expense} ¥${c.amount.toStringAsFixed(2)}'),
              subtitle: Text('${c.categoryName ?? c.categoryCode} · ${c.frequencyDesc}'),
              value: selectedIds.contains(c.id),
              onChanged: (v) => setSheet(() { if (v == true) selectedIds.add(c.id); else selectedIds.remove(c.id); }),
            );
          })),
          CheckboxListTile(
            title: Text(L10nManager.l10n.recurringConfigDeactivateOrigin),
            value: deactivateOrigin,
            onChanged: (v) => setSheet(() => deactivateOrigin = v ?? false),
          ),
          Padding(padding: const EdgeInsets.all(16), child: ElevatedButton(
            onPressed: selectedIds.isEmpty ? null : () async {
              Navigator.pop(ctx);
              final target = _currentBookId;
              if (target == null) return;
              final cr = await provider.copyFromBook(sourceBook.id, target, selectedIds.toList(), deactivateOrigin: deactivateOrigin);
              if (context.mounted) {
                await provider.loadConfigs(target);
                ToastUtil.showSuccess(
                  cr.failCount > 0
                      ? L10nManager.l10n.recurringConfigCopyPartial(cr.successCount, cr.failCount)
                      : L10nManager.l10n.recurringConfigCopySuccess(cr.successCount)
                );
              }
            },
            child: Text(L10nManager.l10n.recurringConfigCopyConfirm(selectedIds.length.toString())),
          )),
        ]),
      ),
    ));
  }
}
