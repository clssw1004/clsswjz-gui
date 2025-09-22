import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_debt_vo.dart';
import '../common/common_card_container.dart';
import '../../routes/app_routes.dart';
import '../../enums/debt_type.dart';
import '../../utils/color_util.dart';

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

    // 定义导航到债务列表的函数
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
          // 标题行 - 添加InkWell使整个标题栏可点击
          InkWell(
            onTap: bookMeta?.permission.canViewItem == true ? navigateToDebtList : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
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
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withAlpha(50),
          ),
          // 内容区域
          if (loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (debts.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: debts.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant.withAlpha(40),
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
    final debtType = DebtType.fromCode(debt.debtType);
    final amountColor = ColorUtil.getDebtAmountColor(debtType);
    final isLending = debtType == DebtType.lend;
    
    // 创建格式化工具
    final formatter = NumberFormat('#,##0.00');
    
    // 债务标签图标
    final debtIcon = isLending 
        ? Icons.arrow_circle_up_outlined
        : Icons.arrow_circle_down_outlined;

    return Card(
      elevation: 1,
      shadowColor: colorScheme.shadow.withAlpha(30),
      surfaceTintColor: colorScheme.surfaceTint,
      color: colorScheme.surface,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withAlpha(40),
          width: 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 上部分：债务人和待收/待还金额（突出显示）
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 债务类型图标
                  Icon(
                    debtIcon,
                    color: amountColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  // 债务类型标签
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: amountColor.withAlpha(24),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLending
                          ? L10nManager.l10n.lend
                          : L10nManager.l10n.borrow,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 债务人
                  Expanded(
                    child: Text(
                      debt.debtor,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 待收/待还金额（突出显示）
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isLending
                            ? L10nManager.l10n.remainingReceivable
                            : L10nManager.l10n.remainingPayable,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: amountColor.withAlpha(200),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatter.format(debt.remainAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              // 底部：总金额信息 - 右对齐显示（弱化显示）
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 28),
                child: Row(
                  children: [
                    // 进度指示
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: debt.remainAmount / debt.totalAmount,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          color: amountColor.withAlpha(150),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 总金额（弱化显示）
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          L10nManager.l10n.amount,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatter.format(debt.totalAmount),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
