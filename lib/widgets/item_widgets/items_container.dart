import 'package:clsswjz_gui/enums/account_type.dart';
import 'package:flutter/material.dart';
import '../../models/vo/user_item_vo.dart';
import '../../utils/color_util.dart';
import '../../manager/l10n_manager.dart';
import '../common/common_card_container.dart';
import '../../routes/app_routes.dart';
import '../../models/vo/user_book_vo.dart';

class ItemsContainer extends StatelessWidget {
  final List<UserItemVO> items;
  final Function(UserItemVO)? onItemTap;
  final bool loading;
  final UserBookVO? accountBook;
  final String? lastDate;

  const ItemsContainer({
    super.key,
    required this.items,
    this.onItemTap,
    this.loading = false,
    this.accountBook,
    this.lastDate,
  });

  /// 计算支出和收入总额
  (double expense, double income) _calculateTotals() {
    double expense = 0;
    double income = 0;
    for (var item in items) {
      if (item.type == AccountItemType.expense.code) {
        expense += item.amount;
      } else if (item.type == AccountItemType.income.code) {
        income += item.amount;
      }
    }
    return (expense, income);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final secondColor = colorScheme.onSurfaceVariant.withAlpha(180);

    // 计算总额
    final (expense, income) = _calculateTotals();

    // 定义导航到账目列表的函数
    void navigateToItemsList() {
      Navigator.of(context).pushNamed(
        AppRoutes.itemsList,
        arguments: accountBook,
      );
    }

    return CommonCardContainer(
      margin: const EdgeInsets.all(8),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题行 - 添加InkWell使整个标题栏可点击
          InkWell(
            onTap: accountBook == null ? null : navigateToItemsList,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  // 标题
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        L10nManager.l10n.accountItem,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (lastDate != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          lastDate!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // 统计金额
                  if (!loading && items.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    // 支出金额
                    if (expense < 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_circle_down_outlined,
                            size: 14,
                            color: ColorUtil.EXPENSE,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            expense.toStringAsFixed(2),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: ColorUtil.EXPENSE,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    if (expense < 0 && income > 0)
                      Text(" | ",
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          )),
                    // 收入金额
                    if (income > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_circle_up_outlined,
                            size: 14,
                            color: ColorUtil.INCOME,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            income.toStringAsFixed(2),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: ColorUtil.INCOME,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                  ],
                  const Spacer(),
                  TextButton(
                    onPressed: accountBook == null ? null : navigateToItemsList,
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
            color: colorScheme.outlineVariant.withAlpha(40),
          ),
          // 列表内容
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  L10nManager.l10n.noData,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.outlineVariant.withAlpha(40),
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () => onItemTap?.call(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 第一行：分类名称和金额
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 14,
                              decoration: BoxDecoration(
                                color: ColorUtil.getAmountColor(item.type),
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 分类名称和账户
                                  Row(
                                    children: [
                                      Text(
                                        item.categoryName ?? '',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      if (item.tagName?.isNotEmpty == true) ...[
                                        const SizedBox(width: 8),
                                        Transform.translate(
                                          offset: const Offset(0, -1),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 0,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: colorScheme.primary
                                                    .withAlpha(128),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                            child: Text(
                                              item.tagName!,
                                              style: theme.textTheme.labelSmall
                                                  ?.copyWith(
                                                color: colorScheme.primary,
                                                fontSize: 11,
                                                height: 1.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  // 占位空间
                                  const Spacer(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              item.amount.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: ColorUtil.getAmountColor(item.type),
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // 第二行：时间、商户、备注
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 11),
                            // 时间
                            Text(
                              item.accountTimeOnly.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: secondColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 商户和备注
                            Expanded(
                              child: Row(
                                children: [
                                  if (item.shopName?.isNotEmpty == true) ...[
                                    Text(
                                      item.shopName!,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: secondColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (item.description?.isNotEmpty ==
                                        true) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '·',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: secondColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ],
                                  if (item.description?.isNotEmpty == true)
                                    Expanded(
                                      child: Text(
                                        item.description!,
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: secondColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
