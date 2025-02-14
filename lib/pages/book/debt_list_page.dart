import 'package:clsswjz/drivers/driver_factory.dart';
import 'package:clsswjz/enums/business_type.dart';
import 'package:clsswjz/models/vo/book_meta.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../manager/app_config_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/user_debt_vo.dart';
import '../../providers/debt_list_provider.dart';
import '../../providers/sync_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../manager/l10n_manager.dart';
import '../../enums/debt_type.dart';
import '../../utils/color_util.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_card_container.dart';
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
                        if (context.mounted) {
                          final itemResult = await DriverFactory.driver
                              .listItemsByBook(AppConfigManager.instance.userId,
                                  widget.bookMeta.id,
                                  filter: ItemFilterDTO(
                                      source: BusinessType.debt.code,
                                      sourceIds: [debt.id]));
                          Navigator.pushNamed(
                            context,
                            AppRoutes.debtEdit,
                            arguments: [
                              widget.bookMeta,
                              debt,
                              itemResult.ok ? itemResult.data : [],
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

    return CommonCardContainer(
      margin: spacing.listItemMargin,
      padding: spacing.listItemPadding,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部信息栏
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 借入/借出标识
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      debtType == DebtType.lend
                          ? Icons.arrow_circle_up_outlined
                          : Icons.arrow_circle_down_outlined,
                      size: 16,
                      color: amountColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      debtType == DebtType.lend
                          ? L10nManager.l10n.lend
                          : L10nManager.l10n.borrow,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 债务人和日期
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 债务人
                    Text(
                      debt.debtor,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 日期
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
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
              Hero(
                tag: 'debt_amount_${debt.id}',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: amountColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: amountColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    debt.amount.toString(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
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
