import 'package:flutter/material.dart';
import '../../models/vo/statistic_vo.dart';
import '../common/common_card_container.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';
import 'package:intl/intl.dart';

/// 统计卡片展示模式
enum StatisticCardMode {
  /// 总计模式
  total,

  /// 最近一天模式
  lastDay,
}

/// 账本统计卡片组件
class BookStatisticCard extends StatelessWidget {
  /// 统计数据
  final BookStatisticVO? statisticInfo;

  /// 点击事件
  final VoidCallback? onTap;

  /// 外边距
  final EdgeInsetsGeometry margin;

  /// 展示模式
  final StatisticCardMode mode;

  const BookStatisticCard({
    super.key,
    this.statisticInfo,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    this.mode = StatisticCardMode.total,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

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

    final info = statisticInfo ?? const BookStatisticVO();

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
    
    // 格式化日期为 yyyy-MM-dd
    String lastDateStr = '';
    if (info.lastDate != null && info.lastDate!.isNotEmpty) {
      try {
        final date = DateTime.parse(info.lastDate!);
        lastDateStr = DateFormat('yyyy-MM-dd').format(date);
      } catch (e) {
        // 日期解析错误，使用原始字符串
        lastDateStr = info.lastDate!;
      }
    }

    // 判断是否有最近一天的数据
    final hasLastDayData = info.lastDayIncome != 0 || info.lastDayExpense != 0;
    
    // 根据模式决定显示内容
    final showTotal = mode == StatisticCardMode.total || !hasLastDayData;

    // 定义主色调
    final Color primaryColor = showTotal ? colorScheme.primary : colorScheme.tertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏 - 使用纯色背景
        if (lastDateStr.isNotEmpty)
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
                  showTotal ? Icons.date_range : Icons.today,
                  size: 16,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  showTotal ? "至 $lastDateStr" : lastDateStr,
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
            borderRadius: lastDateStr.isNotEmpty
                ? BorderRadius.only(
                    bottomLeft: cardRadius.bottomLeft,
                    bottomRight: cardRadius.bottomRight,
                  )
                : cardRadius,
          ),
          child: Column(
            children: [
              // 金额统计行
              Row(
                key: ValueKey<String>(showTotal ? 'total' : 'lastDay'),
                children: [
                  Expanded(
                    child: _buildStatisticItem(
                      context,
                      L10nManager.l10n.income,
                      showTotal ? info.totalIncome : info.lastDayIncome,
                      colorScheme.primary,
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
                      L10nManager.l10n.expense,
                      showTotal ? info.totalExpense : info.lastDayExpense,
                      colorScheme.error,
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
                      L10nManager.l10n.balance,
                      showTotal ? info.totalBalance : info.lastDayBalance,
                      colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              
              // 底部装饰线
              Container(
                margin: const EdgeInsets.only(top: 16),
                height: 2,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withAlpha(80),
                      colorScheme.tertiary.withAlpha(80),
                      colorScheme.error.withAlpha(80),
                    ],
                    stops: const [0.0, 0.5, 1.0],
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
    final colorScheme = theme.colorScheme;
    
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
        const SizedBox(height: 10),
        
        // 金额
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0, end: amount),
          builder: (context, value, child) {
            return Text(
              _formatAmount(value),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            );
          },
        ),
      ],
    );
  }
}
