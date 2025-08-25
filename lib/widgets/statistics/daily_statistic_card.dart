import 'package:flutter/material.dart';
import '../../models/vo/statistic_vo.dart';
import '../../manager/l10n_manager.dart';
import '../common/common_card_container.dart';
import 'daily_statistic_chart.dart';

/// 每日收支统计卡片
class DailyStatisticCard extends StatefulWidget {
  /// 每日统计数据
  final List<DailyStatisticVO> dailyStats;
  
  /// 加载状态
  final bool loading;

  const DailyStatisticCard({
    super.key,
    required this.dailyStats,
    this.loading = false,
  });

  @override
  State<DailyStatisticCard> createState() => _DailyStatisticCardState();
}

class _DailyStatisticCardState extends State<DailyStatisticCard> {
  /// 是否显示收入（true显示收入，false显示支出）
  bool _showIncome = false; // 默认显示支出

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CommonCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.bar_chart_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  L10nManager.l10n.dailyIncomeExpense,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // 切换按钮 - 居中显示
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 支出按钮
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showIncome = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: !_showIncome 
                          ? colorScheme.error.withAlpha(180)
                          : colorScheme.surfaceContainerHighest.withAlpha(80),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: !_showIncome 
                            ? colorScheme.error.withAlpha(150)
                            : colorScheme.outline.withAlpha(80),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      L10nManager.l10n.expense,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: !_showIncome 
                            ? colorScheme.onError 
                            : colorScheme.onSurfaceVariant,
                        fontWeight: !_showIncome 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 收入按钮
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showIncome = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _showIncome 
                          ? colorScheme.primary.withAlpha(180)
                          : colorScheme.surfaceContainerHighest.withAlpha(80),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _showIncome 
                            ? colorScheme.primary.withAlpha(150)
                            : colorScheme.outline.withAlpha(80),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      L10nManager.l10n.income,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _showIncome 
                            ? colorScheme.onPrimary 
                            : colorScheme.onSurfaceVariant,
                        fontWeight: _showIncome 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 图表
          DailyStatisticChart(
            dailyStats: widget.dailyStats,
            loading: widget.loading,
            height: 200,
            useLogarithmicYAxis: true,
            showIncome: _showIncome,
          ),
          
          // 图例
          if (!widget.loading && widget.dailyStats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 收入图例
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        L10nManager.l10n.income,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // 支出图例
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        L10nManager.l10n.expense,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
