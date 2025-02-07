import 'package:flutter/material.dart';
import '../../models/vo/user_item_vo.dart';
import '../../utils/color_util.dart';
import '../../enums/account_type.dart';

/// 简略版账目列表项
class ItemTileSimple extends StatelessWidget {
  /// 账目数据
  final UserItemVO item;

  /// 货币符号
  final String currencySymbol;

  /// 在列表中的索引
  final int index;

  /// 是否显示日期分割线
  final bool showDateHeader;

  /// 日期
  final String? date;

  const ItemTileSimple({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.index,
    this.showDateHeader = false,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 解析时间
    final time = DateTime.parse(item.accountDate);
    final timeString = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';

    // 获取金额颜色
    final amountColor = ColorUtil.getAmountColor(item.type);
    
    // 判断是否为支出
    final isExpense = AccountItemType.fromCode(item.type) == AccountItemType.expense;

    // 构建标签
    Widget buildTag() {
      if (item.tagName == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          item.tagName!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontSize: 10,
          ),
        ),
      );
    }

    // 构建账目内容
    Widget buildItemContent({required bool isLeft}) {
      return Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 时间
            Text(
              timeString,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            // 分类名称和项目名称
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isLeft) ...[
                  if (item.projectName != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.projectName!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    item.categoryName ?? '',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Text(
                    item.categoryName ?? '',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.projectName != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.projectName!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
            const SizedBox(height: 2),
            // 金额
            Text(
              '${isExpense ? '' : '+'}${item.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (item.description?.isNotEmpty == true || item.tagName != null) ...[
              const SizedBox(height: 4),
              // 标签和备注
              DefaultTextStyle(
                style: theme.textTheme.bodySmall!.copyWith(
                  color: colorScheme.outline,
                  height: 1.2,
                ),
                child: Column(
                  crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (item.tagName != null)
                      buildTag(),
                    if (item.description?.isNotEmpty == true)
                      Text(
                        item.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧内容（支出）
            if (isExpense)
              buildItemContent(isLeft: true)
            else
              const SizedBox(width: 140),
            
            // 时间点
            Container(
              width: 40,
              child: Stack(
                children: [
                  // 时间点
                  Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(32),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withAlpha(128),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 右侧内容（非支出）
            if (!isExpense)
              buildItemContent(isLeft: false)
            else
              const SizedBox(width: 140),
          ],
        ),
      ),
    );
  }
}
