import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/debt_list_provider.dart';
import '../../providers/sync_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../manager/l10n_manager.dart';
import '../../database/database.dart';
import '../../enums/debt_type.dart';
import '../../utils/color_util.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_card_container.dart';
import '../../manager/service_manager.dart';
import '../../routes/app_routes.dart';

class DebtListPage extends StatefulWidget {
  final UserBookVO accountBook;

  const DebtListPage({
    super.key,
    required this.accountBook,
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
          return Stack(
            children: [
              CustomRefreshIndicator(
                onRefresh: _handleRefresh,
                builder: (context, child, controller) => child,
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: debtListProvider.debts.length + 1,
                  itemBuilder: (context, index) {
                    if (index == debtListProvider.debts.length) {
                      if (debtListProvider.loadingMore) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
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
                        final bookMeta = await ServiceManager.accountBookService.toBookMeta(widget.accountBook);
                        if (context.mounted) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.debtEdit,
                            arguments: [bookMeta, debt],
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
            arguments: [widget.accountBook],
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
  final AccountDebt debt;
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

    return CommonCardContainer(
      margin: spacing.listItemMargin,
      padding: spacing.listItemPadding,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部信息栏
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 债务人和日期
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 债务人和标签
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            debt.debtor,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: amountColor.withAlpha(32),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            debtType == DebtType.lend ? L10nManager.l10n.lend : L10nManager.l10n.borrow,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // 日期
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          debt.debtDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // 金额
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: amountColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  debt.amount.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    height: 1.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 