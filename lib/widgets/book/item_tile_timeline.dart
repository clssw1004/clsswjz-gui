import 'package:flutter/material.dart';
import '../../models/vo/user_item_vo.dart';
import '../../utils/color_util.dart';
import '../../enums/account_type.dart';
import '../../theme/theme_spacing.dart';
import '../common/common_card_container.dart';

/// 时间线账目卡片
class ItemTileTimeline extends StatelessWidget {
  final UserItemVO item;
  final String currencySymbol;
  final int index;
  final bool isFirst;

  /// 点击回调
  final VoidCallback? onTap;

  const ItemTileTimeline({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.index,
    this.isFirst = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    final time = DateTime.parse(item.accountDate);
    final timeString = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
    final amountColor = ColorUtil.getAmountColor(item.type);
    final isExpense =
        AccountItemType.fromCode(item.type) == AccountItemType.expense;

    return Padding(
      padding: EdgeInsets.only(left: 20, right: spacing.listItemMargin.horizontal / 2),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧时间线列
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  if (!isFirst)
                    Container(
                      width: 3,
                      height: 8,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    )
                  else
                    const SizedBox(height: 4),
                  // 实心圆点
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: amountColor.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // 下方连接线
                  Expanded(
                    child: Container(
                      width: 3,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // 右侧内容卡片
            Expanded(
              child: CommonCardContainer(
                onTap: onTap,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 头部：时间 + 金额
                    _buildHeader(timeString, amountColor, isExpense, colorScheme, theme),
                    const SizedBox(height: 10),
                    // 分类 + 标签
                    _buildCategoryAndTags(colorScheme, theme),
                    // 备注（单行简洁展示）
                    if (item.description?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          item.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    String timeString,
    Color amountColor,
    bool isExpense,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Row(
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
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '${isExpense ? '' : '+'}${item.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAndTags(ColorScheme colorScheme, ThemeData theme) {
    final chips = <Widget>[];
    // 分类名
    chips.add(
      Flexible(
        child: Text(
          item.categoryName ?? '',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    // 标签作为独立 chips
    for (var i = 0; i < item.tags.length && i < 3; i++) {
      chips.add(const SizedBox(width: 6));
      chips.add(_buildTagChip(item.tags[i].name, colorScheme, theme));
    }
    if (item.tags.length > 3) {
      chips.add(const SizedBox(width: 6));
      chips.add(_buildTagChip('+${item.tags.length - 3}', colorScheme, theme));
    }

    return Wrap(
      spacing: 0,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: chips,
    );
  }

  Widget _buildTagChip(String label, ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

}
