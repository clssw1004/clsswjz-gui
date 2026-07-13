import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../enums/account_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/recurring_config_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../providers/books_provider.dart';
import '../../providers/recurring_config_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/recurring_config_service.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/color_util.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/common_loading_view.dart';

class RecurringConfigDetailPage extends StatefulWidget {
  final RecurringConfigVO config;
  const RecurringConfigDetailPage({super.key, required this.config});
  @override State<RecurringConfigDetailPage> createState() => _RecurringConfigDetailPageState();
}

class _RecurringConfigDetailPageState extends State<RecurringConfigDetailPage> {
  List<AccountItem>? _generatedItems;
  bool _loadingItems = false;

  @override
  void initState() {
    super.initState();
    _loadGeneratedItems();
  }

  Future<void> _loadGeneratedItems() async {
    setState(() => _loadingItems = true);
    try {
      final items = await RecurringConfigService.getGeneratedItems(widget.config.id);
      if (mounted) setState(() { _generatedItems = items; _loadingItems = false; });
    } catch (_) { if (mounted) setState(() => _loadingItems = false); }
  }

  Widget _sectionDivider(IconData icon, String title) {
    final cs = Theme.of(context).colorScheme;
    return Row(children: [
      Icon(icon, size: 16, color: cs.primary),
      const SizedBox(width: 6),
      Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary)),
      const SizedBox(width: 12), Expanded(child: Container(height: 1, color: cs.primary.withAlpha(20))),
    ]);
  }

  Widget _infoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 72, child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
      ]),
    );
  }

  Widget _detailRow(ColorScheme cs, IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 15, color: cs.onSurfaceVariant),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.spacing;
    final c = widget.config;
    final ac = c.isIncome ? ColorUtil.income : ColorUtil.expense;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.recurringConfigDetail),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => _handleAction(v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('编辑')),
              const PopupMenuItem(value: 'generate', child: Text('立即生成')),
              const PopupMenuItem(value: 'delete', child: Text('删除')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: spacing.contentPadding,
        children: [
          // ── 顶部 Hero ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ac.withAlpha(15), cs.surface],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withAlpha(50)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ac.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.isIncome ? Icons.arrow_downward : Icons.arrow_upward, size: 14, color: ac),
                          const SizedBox(width: 4),
                          Text(c.isIncome ? '收入' : '支出', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ac)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(c.frequencyDesc, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('¥', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: ac)),
                    const SizedBox(width: 4),
                    Text(c.amount.toStringAsFixed(2), style: TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: ac, height: 1.1)),
                    const Spacer(),
                    if (c.categoryName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withAlpha(80),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(c.categoryName!, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // 账户/商户/备注信息
                _detailRow(cs, Icons.account_balance_wallet_outlined, c.fundName ?? c.fundId),
                if (c.shopName != null) const SizedBox(height: 6),
                if (c.shopName != null) _detailRow(cs, Icons.store_outlined, c.shopName!),
                if (c.description != null && c.description!.isNotEmpty) const SizedBox(height: 6),
                if (c.description != null && c.description!.isNotEmpty) _detailRow(cs, Icons.description_outlined, c.description!),
              ],
            ),
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // ── 频率 ──
          _sectionDivider(Icons.repeat, L10nManager.l10n.recurringConfigFrequency),
          const SizedBox(height: 12),
          CommonCardContainer(
            padding: spacing.contentPadding,
            child: Column(children: [
              _infoRow('频率', c.frequencyDesc),
              _infoRow('开始日期', c.startDate),
              _infoRow('结束方式', c.endConditionDesc),
            ]),
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // ── 生成统计 ──
          _sectionDivider(Icons.analytics_outlined, '生成统计'),
          const SizedBox(height: 12),
          CommonCardContainer(
            padding: spacing.contentPadding,
            child: Column(children: [
              _infoRow('已生成', '${c.generatedCount}次'),
              if (c.lastGeneratedAt != null) _infoRow('上次生成', c.lastGeneratedAt!.substring(0, 10)),
              if (c.isActive)
                _infoRow('下次生成', c.nextGenerateDateDesc ?? '待计算')
              else
                _infoRow('状态', L10nManager.l10n.recurringConfigDisabled),
            ]),
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // ── 开关 ──
          CommonCardContainer(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              title: Text(c.isActive ? L10nManager.l10n.recurringConfigEnabled : L10nManager.l10n.recurringConfigDisabled,
                style: TextStyle(fontWeight: FontWeight.w600, color: c.isActive ? cs.primary : cs.onSurfaceVariant)),
              subtitle: Text(c.isActive ? L10nManager.l10n.recurringConfigAutoOn : L10nManager.l10n.recurringConfigAutoOff),
              value: c.isActive,
              onChanged: (v) async {
                await context.read<RecurringConfigProvider>().toggleActive(c.id, v);
                if (context.mounted) Navigator.pop(context, true);
              },
            ),
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // ── 生成的账目 ──
          _sectionDivider(Icons.receipt_outlined, L10nManager.l10n.recurringConfigGeneratedRecords),
          const SizedBox(height: 12),
          if (_loadingItems)
            const CommonLoadingView()
          else if (_generatedItems == null || _generatedItems!.isEmpty)
            CommonCardContainer(
              padding: const EdgeInsets.all(32),
              child: Center(child: Column(children: [
                Icon(Icons.receipt_long_outlined, size: 40, color: cs.onSurfaceVariant.withAlpha(60)),
                const SizedBox(height: 8),
                Text(L10nManager.l10n.recurringConfigNoRecords, style: TextStyle(color: cs.onSurfaceVariant)),
              ])),
            )
          else
            ..._generatedItems!.map((item) => Padding(
              padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  final book = context.read<BooksProvider>().selectedBook;
                  if (book != null) {
                    Navigator.pushNamed(context, AppRoutes.itemEdit, arguments: [book, UserItemVO.fromAccountItem(item: item)]);
                  }
                },
                child: CommonCardContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: (item.type == AccountItemType.income.code ? ColorUtil.income : ColorUtil.expense).withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.type == AccountItemType.income.code ? Icons.arrow_downward : Icons.arrow_upward,
                        color: item.type == AccountItemType.income.code ? ColorUtil.income : ColorUtil.expense,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('¥${item.amount.toStringAsFixed(2)}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text(item.accountDate, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (item.type == AccountItemType.income.code ? ColorUtil.income : ColorUtil.expense).withAlpha(15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item.type == AccountItemType.income.code ? '收入' : '支出', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                      color: item.type == AccountItemType.income.code ? ColorUtil.income : ColorUtil.expense)),
                  ),
                ]),
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _handleAction(String action) async {
    final provider = context.read<RecurringConfigProvider>();
    switch (action) {
      case 'edit':
        if (await Navigator.pushNamed(context, AppRoutes.recurringConfigForm,
            arguments: {'config': widget.config, 'bookId': widget.config.accountBookId}) == true && mounted) {
          Navigator.pop(context, true);
        }
      case 'generate':
        final r = await provider.generateNow(widget.config.id);
        if (mounted) {
          if (r == 'generated') { ToastUtil.showSuccess('生成成功'); } else if (r == 'skip') { ToastUtil.showInfo('已存在，跳过'); } else { ToastUtil.showError(r); }
          _loadGeneratedItems();
        }
      case 'delete':
        if (await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: Text(L10nManager.l10n.recurringConfigConfirmDelete),
          content: Text(L10nManager.l10n.recurringConfigDeleteConfirmMsg),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(L10nManager.l10n.cancel)),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(L10nManager.l10n.delete(''))),
          ],
        )) == true) {
          await provider.deleteConfig(widget.config.id);
          if (mounted) Navigator.pop(context, true);
        }
    }
  }
}
