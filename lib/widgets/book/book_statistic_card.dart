import 'package:flutter/material.dart';
import '../../models/vo/statistic_vo.dart';
import '../common/common_card_container.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';
import 'package:intl/intl.dart';

/// 账本统计卡片组件
class BookStatisticCard extends StatelessWidget {
  /// 统计数据
  final BookStatisticVO? statisticInfo;
  
  /// 点击事件
  final VoidCallback? onTap;
  
  /// 外边距
  final EdgeInsetsGeometry margin;

  const BookStatisticCard({
    super.key,
    this.statisticInfo,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return CommonCardContainer(
      margin: margin,
      onTap: onTap,
      padding: EdgeInsets.all(spacing.formItemSpacing),
      child: _buildContent(context),
    );
  }
  
  /// 构建内容
  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    
    final info = statisticInfo ?? const BookStatisticVO(income: 0, expense: 0, balance: 0);
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.listItemSpacing / 2),
      child: Row(
        children: [
          Expanded(
            child: _buildStatisticItem(
              context,
              L10nManager.l10n.income,
              info.income,
              colorScheme.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outlineVariant.withAlpha(77),
          ),
          Expanded(
            child: _buildStatisticItem(
              context,
              L10nManager.l10n.expense,
              info.expense,
              colorScheme.error,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outlineVariant.withAlpha(77),
          ),
          Expanded(
            child: _buildStatisticItem(
              context,
              L10nManager.l10n.balance,
              info.balance,
              colorScheme.tertiary,
            ),
          ),
        ],
      ),
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
    Color color
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatAmount(amount),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: -0.5,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
} 