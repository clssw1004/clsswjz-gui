import 'package:clsswjz/models/vo/book_meta.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/business_type.dart';
import '../../manager/app_config_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/user_book_vo.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_debt_vo.dart';
import '../../widgets/common/common_card_container.dart';
import '../../routes/app_routes.dart';
import '../../enums/debt_type.dart';
import '../../utils/color_util.dart';
import '../../providers/debt_list_provider.dart';

class DebtsContainer extends StatelessWidget {
  final BookMetaVO? bookMeta;
  final bool loading;

  const DebtsContainer({
    super.key,
    required this.bookMeta,
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
                  onPressed: bookMeta?.permission.canViewItem == true
                      ? () {
                          Navigator.of(context).pushNamed(
                            AppRoutes.debtList,
                            arguments: bookMeta,
                          );
                        }
                      : null,
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
                  return _DebtItem(
                    debt: debt,
                    onTap: () async {
                      if (context.mounted) {
                        final itemResult = await DriverFactory.driver
                            .listItemsByBook(
                                AppConfigManager.instance.userId, bookMeta!.id,
                                filter: ItemFilterDTO(
                                    source: BusinessType.debt.code,
                                    sourceIds: [debt.id]));
                        Navigator.pushNamed(
                          context,
                          AppRoutes.debtEdit,
                          arguments: [
                            bookMeta,
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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            // 日期
            Text(
              debt.debtDate,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withAlpha(178),
              ),
            ),
            const SizedBox(width: 12),
            // 借入/借出标识
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ColorUtil.getDebtAmountColor(debtType).withAlpha(32),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                debtType == DebtType.lend
                    ? L10nManager.l10n.lend
                    : L10nManager.l10n.borrow,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ColorUtil.getDebtAmountColor(debtType),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 债务人
            Expanded(
              child: Text(
                debt.debtor,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
