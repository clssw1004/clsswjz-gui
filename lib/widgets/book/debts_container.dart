import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vo/user_book_vo.dart';
import '../../manager/l10n_manager.dart';
import '../../widgets/common/common_card_container.dart';
import '../../routes/app_routes.dart';
import '../../enums/debt_type.dart';
import '../../utils/color_util.dart';
import '../../providers/debt_list_provider.dart';
import '../../database/database.dart';

class DebtsContainer extends StatelessWidget {
  final UserBookVO? accountBook;
  final bool loading;

  const DebtsContainer({
    super.key,
    this.accountBook,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CommonCardContainer(
      margin: const EdgeInsets.all(8),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题行
          Padding(
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
                  onPressed: accountBook == null
                      ? null
                      : () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.debtAdd,
                            arguments: [accountBook],
                          ).then((added) {
                            if (added == true) {
                              context.read<DebtListProvider>().loadDebts();
                            }
                          });
                        },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(L10nManager.l10n.addNew('')),
                      Icon(
                        Icons.add,
                        size: 18,
                        color: theme.textTheme.labelLarge?.color,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: colorScheme.outlineVariant.withOpacity(0.2),
          ),
          // 内容区域
          Consumer<DebtListProvider>(
            builder: (context, provider, child) {
              if (provider.loading) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (provider.debts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      L10nManager.l10n.noData,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.75),
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: provider.debts.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: colorScheme.outlineVariant.withAlpha(40),
                ),
                itemBuilder: (context, index) {
                  final debt = provider.debts[index];
                  return _DebtItem(debt: debt);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DebtItem extends StatelessWidget {
  final AccountDebt debt;

  const _DebtItem({required this.debt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final debtType = DebtType.fromCode(debt.debtType);

    return InkWell(
      onTap: () {
        // TODO: 实现债务详情页面
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            // 债务类型标识
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: ColorUtil.getDebtAmountColor(debtType),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 8),
            // 债务人
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.debtor,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    debt.debtDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 金额
            Text(
              debt.amount.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: ColorUtil.getDebtAmountColor(debtType),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 