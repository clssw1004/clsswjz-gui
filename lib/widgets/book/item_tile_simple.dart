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
    
    // 判断是否为左侧显示（奇数索引显示在右侧）
    final isLeft = index % 2 == 0;

    // 构建标签
    Widget buildTag() {
      if (item.tagName == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withOpacity(0.6),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: colorScheme.secondary.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Text(
          item.tagName!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      );
    }

    // 构建账目内容
    Widget buildItemContent({required bool isLeft}) {
      // 构建信息标签
      Widget buildInfoTag(String text, IconData icon) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Text(
                text,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isLeft ? 0 : 4,
          right: isLeft ? 4 : 0,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(16) : Radius.zero,
            right: !isLeft ? const Radius.circular(16) : Radius.zero,
          ),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 标签和时间
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                mainAxisAlignment: isLeft ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceBetween,
                children: [
                  if (isLeft) ...[
                    buildTag(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        timeString,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        timeString,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    buildTag(),
                  ],
                ],
              ),
            ),
            // 金额
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Row(
                mainAxisAlignment: isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Text(
                    '${AccountItemType.fromCode(item.type) == AccountItemType.income ? '+' : ''}${currencySymbol}${item.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      fontSize: 18,
                      height: 1.1,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            // 分类名称和项目名称
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isLeft) ...[
                    if (item.projectName != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item.projectName!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.categoryName ?? '',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.shopName != null) ...[
                            const SizedBox(width: 6),
                            buildInfoTag(item.shopName!, Icons.store_outlined),
                          ],
                        ],
                      ),
                    ),
                  ] else ...[
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (item.shopName != null) ...[
                            buildInfoTag(item.shopName!, Icons.store_outlined),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              item.categoryName ?? '',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.projectName != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          item.projectName!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            // 账户信息
            if (item.fundName != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                child: Row(
                  mainAxisAlignment: isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    buildInfoTag(item.fundName!, Icons.account_balance_wallet_outlined),
                  ],
                ),
              ),
            // 备注信息
            if (item.description?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Row(
                  mainAxisAlignment: isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        item.description!,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10,
                          height: 1.2,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: isLeft ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                  ],
                ),
              )
            else if (item.fundName != null || item.shopName != null || item.tagName != null)
              const SizedBox(height: 8),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          // 时间线
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Center(
                        child: Container(
                          width: 1,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                colorScheme.primary.withOpacity(0.1),
                                colorScheme.primary.withOpacity(0.2),
                                colorScheme.primary.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.5),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.1),
                                blurRadius: 2,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 内容
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧内容
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: isLeft
                      ? buildItemContent(isLeft: true)
                      : const SizedBox.shrink(),
                ),
              ),
              
              // 时间线占位
              const SizedBox(width: 16),
              
              // 右侧内容
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: !isLeft
                      ? buildItemContent(isLeft: false)
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

