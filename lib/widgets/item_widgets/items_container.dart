import 'package:clsswjz_gui/enums/account_type.dart';
import 'package:flutter/material.dart';
import '../../models/vo/user_item_vo.dart';
import '../../utils/color_util.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';
import '../common/common_card_container.dart';
import '../common/common_loading_view.dart';
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
    this.margin,
  });

  final EdgeInsetsGeometry? margin;

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
    final spacing = theme.spacing;
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
      margin: margin ?? spacing.listItemMargin,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题行 - 添加InkWell使整个标题栏可点击
          InkWell(
            onTap: accountBook == null ? null : navigateToItemsList,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.contentPadding.left,
                spacing.formItemSpacing / 2,
                spacing.listItemSpacing,
                spacing.formItemSpacing / 2,
              ),
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
                            color: ColorUtil.expense,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            expense.toStringAsFixed(2),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: ColorUtil.expense,
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
                            color: ColorUtil.income,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            income.toStringAsFixed(2),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: ColorUtil.income,
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
              child: CommonLoadingView(),
            )
          else if (items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.formGroupSpacing),
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
              padding: EdgeInsets.symmetric(vertical: spacing.listItemSpacing / 2),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: spacing.contentPadding.left,
                endIndent: spacing.contentPadding.left,
                color: colorScheme.outlineVariant.withAlpha(40),
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                final amountColor = ColorUtil.getAmountColor(item.type);

                return InkWell(
                  onTap: () => onItemTap?.call(item),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.contentPadding.left,
                      vertical: spacing.formItemSpacing / 2,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 左侧渐变装饰条
                        Container(
                          width: 4,
                          height: 46,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                amountColor,
                                amountColor.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 主内容区
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 第一行：分类名称 + 标签 + 金额
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item.categoryName ?? '',
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (item.tags.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          for (var i = 0; i < item.tags.length && i < 3; i++)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              margin: const EdgeInsets.only(right: 4),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.tags[i].name,
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: colorScheme.primary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                          if (item.tags.length > 3)
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colorScheme.primary.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '+${item.tags.length - 3}',
                                                style: theme.textTheme.labelSmall?.copyWith(
                                                  color: colorScheme.primary,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item.amount.toStringAsFixed(2),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: amountColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // 第二行：时间、商户、备注
                              Row(
                                children: [
                                  Icon(Icons.schedule_outlined, size: 13, color: secondColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.accountTimeOnly.toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: secondColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (item.shopName?.isNotEmpty == true) ...[
                                    const SizedBox(width: 10),
                                    Icon(Icons.store_outlined, size: 13, color: secondColor),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        item.shopName!,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: secondColor,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                  if (item.description?.isNotEmpty == true) ...[
                                    if (item.shopName?.isNotEmpty == true) ...[
                                      const SizedBox(width: 6),
                                      Text('·', style: TextStyle(color: secondColor, fontSize: 12)),
                                      const SizedBox(width: 6),
                                    ] else ...[
                                      const SizedBox(width: 10),
                                    ],
                                    Icon(Icons.notes_rounded, size: 13, color: secondColor),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        item.description!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: secondColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
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
