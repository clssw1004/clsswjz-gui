import 'package:flutter/material.dart';
import '../../manager/app_config_manager.dart';
import '../../models/vo/user_item_vo.dart';
import '../../utils/color_util.dart';
import '../../theme/theme_spacing.dart';
import '../common/common_card_container.dart';

/// 账目列表项
class ItemTileAdvance extends StatelessWidget {
  /// 账目数据
  final UserItemVO item;

  /// 货币符号
  final String currencySymbol;

  /// 在列表中的索引
  final int index;

  const ItemTileAdvance({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    // 解析时间
    final time = DateTime.parse(item.accountDate);
    final timeString = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';

    // 获取金额颜色
    final amountColor = ColorUtil.getAmountColor(item.type);

    return CommonCardContainer(
      margin: spacing.listItemMargin,
      padding: spacing.listItemPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部信息栏
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 分类名称、描述和账户商户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 分类名称和标签
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.categoryName != null)
                          Expanded(
                            child: Text(
                              item.categoryName!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (item.tagName != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorScheme.tertiaryContainer,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.tagName!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.tertiary,
                                fontSize: 10,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    // 描述
                    if (item.description != null && item.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    // 账户和商户信息
                    if (item.fundName != null || item.shopName != null) ...[
                      const SizedBox(height: 6),
                      DefaultTextStyle(
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (item.fundName != null) ...[
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.fundName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (item.fundName != null && item.shopName != null) ...[
                                const SizedBox(width: 12),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              if (item.shopName != null) ...[
                                Icon(
                                  Icons.store_outlined,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.shopName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // 金额
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: amountColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.amount > 0 ? "+" : ""}${item.amount.toStringAsFixed(2)}',
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

          // 底部信息栏
          if (item.projectName != null || item.createdByName != null || timeString.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // 项目
                if (item.projectName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 14,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.projectName!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                // 创建者和时间
                if (item.createdByName != null || timeString.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.createdByName != null && AppConfigManager.instance.userId != item.createdBy) ...[
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.createdByName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeString,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
