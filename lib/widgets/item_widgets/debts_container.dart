import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_debt_vo.dart';
import '../common/common_card_container.dart';
import '../common/common_loading_view.dart';
import '../../routes/app_routes.dart';
import '../../enums/debt_clear_state.dart';
import '../../enums/debt_type.dart';
import '../../utils/color_util.dart';
import '../../theme/theme_spacing.dart';

class DebtsContainer extends StatelessWidget {
  final BookMetaVO? bookMeta;
  final List<UserDebtVO> debts;
  final bool loading;
  final Function(UserDebtVO)? onItemTap;
  final VoidCallback? onRefresh;

  const DebtsContainer({
    super.key,
    required this.bookMeta,
    required this.debts,
    this.loading = false,
    this.onItemTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    void navigateToDebtList() {
      Navigator.of(context).pushNamed(
        AppRoutes.debtList,
        arguments: bookMeta,
      );
    }

    return CommonCardContainer(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题行
          InkWell(
            onTap: bookMeta?.permission.canViewItem == true ? navigateToDebtList : null,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.contentPadding.left, 0, spacing.listItemSpacing, 0,
              ),
              child: SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Text(
                      L10nManager.l10n.debt,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: bookMeta?.permission.canViewItem == true ? navigateToDebtList : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(L10nManager.l10n.more),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: theme.textTheme.labelLarge?.color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withAlpha(50),
          ),
          // 内容区域
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CommonLoadingView(),
            )
          else if (debts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  L10nManager.l10n.noData,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withAlpha(180),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: spacing.listItemSpacing / 2,
                bottom: spacing.listItemSpacing / 2,
              ),
              itemCount: debts.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: spacing.contentPadding.left + 36,
                endIndent: spacing.contentPadding.left,
                color: colorScheme.outlineVariant.withAlpha(30),
              ),
              itemBuilder: (context, index) {
                final debt = debts[index];
                return _DebtItem(
                  debt: debt,
                  onTap: onItemTap != null ? () => onItemTap!(debt) : null,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DebtItem extends StatelessWidget {
  final UserDebtVO debt;
  final VoidCallback? onTap;

  const _DebtItem({
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
    final formatter = NumberFormat('#,##0.00');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.contentPadding.left,
          vertical: spacing.formItemSpacing / 2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主行
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 类型图标
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: amountColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isLending
                        ? Icons.arrow_circle_up_outlined
                        : Icons.arrow_circle_down_outlined,
                    size: 16,
                    color: amountColor,
                  ),
                ),
                const SizedBox(width: 10),
                // 标签 + 债务人
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: amountColor.withAlpha(15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isLending
                                  ? L10nManager.l10n.lend
                                  : L10nManager.l10n.borrow,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: amountColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              debt.debtor,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 金额
                if (isSettled)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: 14, color: DebtClearState.cleared.color),
                      const SizedBox(width: 3),
                      Text(
                        L10nManager.l10n.debtStatusCleared,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: DebtClearState.cleared.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatter.format(debt.remainAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        isLending
                            ? L10nManager.l10n.remainingReceivable
                            : L10nManager.l10n.remainingPayable,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withAlpha(180),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // 进度条 / 结清等高校验
            const SizedBox(height: 10),
            if (!isSettled)
              Row(
                children: [
                  SizedBox(width: 38), // 对齐图标
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
                    formatter.format(debt.totalAmount),
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
    );
  }
}
