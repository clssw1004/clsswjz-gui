import 'package:flutter/material.dart';
import '../../models/vo/statistic_vo.dart';
import '../../utils/color_util.dart';
import '../common/common_card_container.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';
import 'package:intl/intl.dart';

/// 账本统计卡片组件
class BookStatisticCard extends StatelessWidget {
  /// 统计数据
  final BookStatisticVO? statisticInfo;

  final String? title;

  /// 点击事件
  final VoidCallback? onTap;

  /// 外边距
  final EdgeInsetsGeometry margin;

  /// 是否显示结余
  final bool showBalance;

  const BookStatisticCard({
    super.key,
    this.statisticInfo,
    this.title,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.showBalance = true,
  });

  @override
  Widget build(BuildContext context) {
    return CommonCardContainer(
      margin: margin,
      onTap: onTap,
      padding: EdgeInsets.zero, // 移除内边距，由内部元素控制
      child: _buildContent(context),
    );
  }

  /// 构建内容
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final l10n = L10nManager.l10n;

    final info = statisticInfo;

    // 获取卡片圆角
    final BorderRadius cardRadius;
    if (theme.cardTheme.shape != null &&
        theme.cardTheme.shape is RoundedRectangleBorder) {
      final shape = theme.cardTheme.shape as RoundedRectangleBorder;
      if (shape.borderRadius is BorderRadius) {
        cardRadius = shape.borderRadius as BorderRadius;
      } else {
        cardRadius = BorderRadius.circular(12);
      }
    } else {
      cardRadius = BorderRadius.circular(12);
    }

    // 定义主色调
    final Color primaryColor = colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏 - 使用纯色背景
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.formItemSpacing,
            vertical: spacing.formItemSpacing / 2,
          ),
          decoration: BoxDecoration(
            color: primaryColor.withAlpha(20),
            borderRadius: BorderRadius.only(
              topLeft: cardRadius.topLeft,
              topRight: cardRadius.topRight,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                size: 16,
                color: primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title ?? "",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),

        // 统计数据容器
        Container(
          padding: EdgeInsets.all(spacing.formItemSpacing),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.only(
              bottomLeft: cardRadius.bottomLeft,
              bottomRight: cardRadius.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // 金额统计行
              Row(
                key: ValueKey<String>(info?.date ?? ''),
                children: [
                  // 支出（放在第一位）
                  Expanded(
                    child: _buildStatisticItem(
                      context,
                      l10n.expense,
                      info?.expense ?? 0,
                      ColorUtil.EXPENSE,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: colorScheme.outlineVariant.withAlpha(30),
                  ),
                  Expanded(
                    child: _buildStatisticItem(
                      context,
                      l10n.income,
                      info?.income ?? 0,
                      ColorUtil.INCOME,
                    ),
                  ),
                  // 根据 showBalance 参数决定是否显示结余部分
                  if (showBalance) ...[
                    Container(
                      width: 1,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: colorScheme.outlineVariant.withAlpha(30),
                    ),
                    Expanded(
                      child: _buildStatisticItem(
                        context,
                        l10n.balance,
                        info?.balance ?? 0,
                        colorScheme.tertiary,
                      ),
                    ),
                  ],
                ],
              ),

              // 底部装饰线
              Container(
                margin: const EdgeInsets.only(top: 16),
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: showBalance
                        ? [
                            ColorUtil.EXPENSE.withAlpha(80),
                            ColorUtil.INCOME.withAlpha(80),
                            colorScheme.tertiary.withAlpha(80),
                          ]
                        : [
                            ColorUtil.EXPENSE.withAlpha(80),
                            ColorUtil.INCOME.withAlpha(80),
                          ],
                    stops:
                        showBalance ? const [0.0, 0.5, 1.0] : const [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 格式化金额，处理大数字
  String _formatAmount(double amount) {
    // 使用千位分隔符格式化数字，保留两位小数
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(amount);
  }

  /// 构建统计项
  Widget _buildStatisticItem(
    BuildContext context,
    String label,
    double amount,
    Color color, {
    bool isSmaller = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontSize: isSmaller ? 12 : null,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        const SizedBox(height: 8),

        // 金额
        Text(
          _formatAmount(amount),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            fontSize: isSmaller ? 14 : 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
