import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_debt_vo.dart';
import '../../providers/debt_list_provider.dart';
import '../../providers/sync_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../manager/l10n_manager.dart';
import '../../enums/debt_clear_state.dart';
import '../../enums/debt_type.dart';
import '../../utils/color_util.dart';
import '../../theme/theme_spacing.dart';
import '../../routes/app_routes.dart';

class DebtListPage extends StatefulWidget {
  final BookMetaVO bookMeta;

  const DebtListPage({
    super.key,
    required this.bookMeta,
  });

  @override
  State<DebtListPage> createState() => _DebtListPageState();
}

class _DebtListPageState extends State<DebtListPage> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      final syncProvider = context.read<SyncProvider>();
      await syncProvider.syncData();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.debt),
      ),
      body: Consumer2<DebtListProvider, SyncProvider>(
        builder: (context, debtListProvider, syncProvider, child) {
          final spacing = Theme.of(context).spacing;
          return Stack(
            children: [
              CustomRefreshIndicator(
                onRefresh: _handleRefresh,
                builder: (context, child, controller) => child,
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
                  itemCount: debtListProvider.debts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == debtListProvider.debts.length) {
                      if (debtListProvider.loadingMore) {
                        return Center(
                          child: Padding(
                            padding: spacing.formPadding,
                            child: const CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (debtListProvider.hasMore) {
                        debtListProvider.loadMore();
                      }
                      return const SizedBox.shrink();
                    }

                    final debt = debtListProvider.debts[index];
                    return _DebtTile(
                      debt: debt,
                      onTap: () async {
                        if (context.mounted) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.debtEdit,
                            arguments: [
                              widget.bookMeta,
                              debt,
                            ],
                          ).then((updated) {
                            if (updated == true) {
                              context.read<DebtListProvider>().loadDebts();
                            }
                          });
                        }
                      },
                    );
                  },
                ),
              ),
              if (syncProvider.syncing && syncProvider.currentStep != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ProgressIndicatorBar(
                    value: syncProvider.progress,
                    label: syncProvider.currentStep!,
                    height: 24,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/debt/add',
            arguments: [widget.bookMeta],
          ).then((added) {
            if (added == true) {
              context.read<DebtListProvider>().loadDebts();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final UserDebtVO debt;
  final VoidCallback? onTap;

  const _DebtTile({
    required this.debt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final debtType = DebtType.fromCode(debt.debtType);
    final amountColor = ColorUtil.getDebtAmountColor(debtType);
    final isLending = debtType == DebtType.lend;
    final isSettled = debt.remainAmount <= 0;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.listItemMargin.left,
        vertical: spacing.listItemMargin.top / 2,
      ),
      child: Card(
        elevation: 0,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withAlpha(30),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(spacing.formItemSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 主行：标识 + 债务人 + 金额
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 类型标识胶囊
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: amountColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLending
                                ? Icons.arrow_circle_up_outlined
                                : Icons.arrow_circle_down_outlined,
                            size: 14,
                            color: amountColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            isLending
                                ? L10nManager.l10n.lend
                                : L10nManager.l10n.borrow,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 债务人 + 日期
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.debtor,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: colorScheme.onSurfaceVariant.withAlpha(180),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                debt.debtDate,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant.withAlpha(180),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 金额 / 结清状态
                    if (isSettled)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: DebtClearState.cleared.color.withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: DebtClearState.cleared.color.withAlpha(40),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                size: 14,
                                color: DebtClearState.cleared.color),
                            const SizedBox(width: 4),
                            Text(
                              L10nManager.l10n.debtStatusCleared,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: DebtClearState.cleared.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isLending
                                ? L10nManager.l10n.remainingReceivable
                                : L10nManager.l10n.remainingPayable,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withAlpha(180),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            debt.remainAmount.toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              height: 1.1,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // 进度条 / 结清等高校验
                const SizedBox(height: 12),
                if (!isSettled)
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: (debt.totalAmount - debt.remainAmount) / debt.totalAmount,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            color: colorScheme.primary.withAlpha(150),
                            minHeight: 3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        debt.totalAmount.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withAlpha(150),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(height: 18), // 与进度条行高一致
              ],
            ),
          ),
        ),
      ),
    );
  }
}
