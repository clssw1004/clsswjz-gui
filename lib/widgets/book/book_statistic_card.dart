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
                size: 18,
                color: primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                title ?? "",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
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
                      icon: Icons.arrow_circle_down_outlined,
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
                      icon: Icons.arrow_circle_up_outlined,
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
                        icon: Icons.horizontal_rule,
                      ),
                    ),
                  ],
                ],
              ),

              // 底部装饰线
              Container(
                margin: EdgeInsets.only(top: spacing.formItemSpacing),
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
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标签（带图标）
        Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.listItemSpacing + 2,
              vertical: spacing.listItemSpacing / 2,
            ),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: color),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontSize: isSmaller ? 12 : null,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 金额 - 自动缩放防止大数字省略号
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _formatAmount(amount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: isSmaller ? 14 : 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
