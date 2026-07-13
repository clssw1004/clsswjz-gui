import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../enums/account_type.dart';
import '../../models/vo/statistic_vo.dart';
import '../../providers/statistics_provider.dart';
import '../../utils/color_util.dart';

/// 分类统计饼图组件
class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    final statisticsProvider = Provider.of<StatisticsProvider>(context);

    final selectedGroup = statisticsProvider.selectedGroup;
    if (selectedGroup == null || selectedGroup.categoryGroupList.isEmpty) {
      return const SizedBox();
    }

    final sortedItems = statisticsProvider.sortedCategoryList;
    final total = statisticsProvider.totalAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.2,
          child: _buildSfCircularChart(context, sortedItems, total),
        ),
        const SizedBox(height: 16),
        // 图例列表
        ...sortedItems.take(8).map((item) => _buildLegendItem(
              context,
              item,
              total,
            )),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    CategoryStatisticVO item,
    double total,
  ) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? (item.amount.abs() / total) * 100 : 0.0;
    final isIncome = context.read<StatisticsProvider>().selectedTab == AccountItemType.income.code;
    final color = isIncome ? ColorUtil.income : ColorUtil.expense;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.6 + (percentage / 100) * 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.categoryName.isEmpty ? '未分类' : item.categoryName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.amount.abs().toStringAsFixed(2),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 44,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSfCircularChart(
    BuildContext context,
    List<CategoryStatisticVO> items,
    double total,
  ) {
    final theme = Theme.of(context);
    final isIncome = context.read<StatisticsProvider>().selectedTab == AccountItemType.income.code;
    final baseColor = isIncome ? ColorUtil.income : ColorUtil.expense;

    final colors = _generateColorPalette(
      count: items.length,
      baseColor: baseColor,
    );

    final chartData = items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final percentage = total > 0 ? (item.amount.abs() / total) * 100 : 0.0;
      return ChartData(
        x: item.categoryName.isEmpty ? '未分类' : item.categoryName,
        y: item.amount.abs(),
        percentage: percentage,
        color: colors[index % colors.length],
      );
    }).toList();

    return SfCircularChart(
      margin: EdgeInsets.zero,
      legend: const Legend(isVisible: false),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x',
        color: theme.colorScheme.surface,
        textStyle: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 12,
        ),
      ),
      series: <CircularSeries>[
        DoughnutSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          pointColorMapper: (ChartData data, _) => data.color,
          dataLabelMapper: (ChartData data, _) =>
              data.percentage >= 5 ? '${data.percentage.toStringAsFixed(1)}%' : '',
          animationDuration: 800,
          innerRadius: '55%',
          explode: true,
          explodeOffset: '3%',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
            textStyle: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          enableTooltip: true,
        ),
      ],
    );
  }

  List<Color> _generateColorPalette({
    required int count,
    required Color baseColor,
  }) {
    if (count <= 0) return [];

    final HSLColor hsl = HSLColor.fromColor(baseColor);
    final List<Color> palette = [];

    for (int i = 0; i < count; i++) {
      final hueShift = ((i * 25 + 10) % 360).toDouble();
      final lightness = (hsl.lightness + (i % 3 - 1) * 0.08).clamp(0.25, 0.75);
      final saturation = (hsl.saturation * (0.6 + (i % 3) * 0.2)).clamp(0.3, 0.8);

      palette.add(
        HSLColor.fromAHSL(1.0, hueShift, saturation, lightness).toColor(),
      );
    }

    return palette;
  }
}

/// 图表数据模型
class ChartData {
  ChartData({
    required this.x,
    required this.y,
    required this.percentage,
    required this.color,
  });

  final String x;
  final double y;
  final double percentage;
  final Color color;
}
