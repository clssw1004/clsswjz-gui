import 'package:flutter/material.dart';
import '../models/vo/account_item_vo.dart';
import '../utils/color_util.dart';

/// 简略版账目列表项
class AccountItemTileSimple extends StatelessWidget {
  /// 账目数据
  final AccountItemVO item;

  /// 货币符号
  final String currencySymbol;

  /// 在列表中的索引
  final int index;

  const AccountItemTileSimple({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.index,
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 时间线
            SizedBox(
              width: 48,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerRight,
                children: [
                  // 竖线
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 5,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.outlineVariant.withAlpha(128),
                            colorScheme.outlineVariant,
                            colorScheme.outlineVariant.withAlpha(128),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 时间点
                  Positioned(
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: amountColor.withAlpha(204),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                  // 时间文本
                  Positioned(
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        timeString,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 内容区域
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 5),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // 分类
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.categoryName ?? '',
                            style: theme.textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 金额
                    Text(
                      '${item.amount > 0 ? '+' : ''}${item.amount.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.5,
                        fontFeatures: const [FontFeature.tabularFigures()],
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
}
