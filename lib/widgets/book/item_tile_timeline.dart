import 'package:flutter/material.dart';
import '../../models/vo/user_item_vo.dart';
import '../../utils/color_util.dart';
import '../../enums/account_type.dart';

/// 时间线账目卡片
class ItemTileTimeline extends StatelessWidget {
  final UserItemVO item;
  final String currencySymbol;
  final int index;
  final bool isFirst;

  const ItemTileTimeline({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.index,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final time = DateTime.parse(item.accountDate);
    final timeString = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    final amountColor = ColorUtil.getAmountColor(item.type);
    final isExpense =
        AccountItemType.fromCode(item.type) == AccountItemType.expense;

    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧时间线列
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  // 上方连接线（非本组首项时显示）
                  if (!isFirst)
                    Container(
                      width: 2,
                      height: 8,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                    )
                  else
                    const SizedBox(height: 4),
                  // 时间线圆点
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: amountColor.withValues(alpha: 0.7),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: amountColor.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  // 下方连接线（延续至下一个圆点）
                  Expanded(
                    child: Container(
                      width: 2,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // 右侧内容卡片
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 头部：时间 + 金额
                      Row(
                        children: [
                          Icon(Icons.schedule_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            timeString,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${isExpense ? '' : '+'}${item.amount.toStringAsFixed(2)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 分类 + 标签 + 项目
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            item.categoryName ?? '',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (item.tags.isNotEmpty)
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              for (var i = 0; i < item.tags.length && i < 3; i++)
                                Padding(
                                  padding: EdgeInsets.only(right: i < 2 && i < item.tags.length - 1 ? 4 : 0),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      i < 3 ? item.tags[i].name : '+${item.tags.length - 3}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              if (item.tags.length > 3)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '+${item.tags.length - 3}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                            ]),
                          if (item.projectName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.folder_outlined, size: 10, color: colorScheme.onSecondaryContainer),
                                  const SizedBox(width: 3),
                                  Text(
                                    item.projectName!,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSecondaryContainer,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      // 备注
                      if (item.description?.isNotEmpty == true) ...[
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Divider(height: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.notes_rounded, size: 13, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.description!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                    fontSize: 12,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
