import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../enums/account_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/statistic_vo.dart';
import '../../providers/statistics_provider.dart';

/// 分类统计饼图组件
class CategoryPieChart extends StatelessWidget {
  const CategoryPieChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10nManager.l10n;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              statisticsProvider.selectedTab == AccountItemType.income.code
                  ? l10n.income
                  : l10n.expense,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${l10n.total}: ${total.toStringAsFixed(2)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        AspectRatio(
          aspectRatio: 1.3,
          child: _buildSfCircularChart(context, sortedItems, total),
        ),
      ],
    );
  }

  /// 构建 Syncfusion 圆形图表
  Widget _buildSfCircularChart(
    BuildContext context,
    List<CategoryStatisticVO> items,
    double total,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // 获取多彩调色板
    final colors =
        _generateColorPalette(count: items.length, isDarkMode: isDarkMode);

    // 准备饼图数据
    final List<ChartData> chartData = items.asMap().entries.map((entry) {
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
      legend: const Legend(
        isVisible: false, // 隐藏默认图例
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x: point.y',
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
          dataLabelMapper: (ChartData data, _) => data.percentage >= 5
              ? '${data.percentage.toStringAsFixed(1)}%'
              : '',
          animationDuration: 800,
          innerRadius: '40%',
          explode: true,
          explodeOffset: '2%',
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.inside,
            textStyle: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
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

  /// 生成多彩调色板
  List<Color> _generateColorPalette({
    required int count,
    required bool isDarkMode,
  }) {
    // 莫兰迪灰调色系 - 低饱和度配色，高级感强适合商务报告
    final List<Color> morandiColors = [
      const Color(0xFF9B8F8A), // 暖灰
      const Color(0xFFC4B6B2), // 浅陶土
      const Color(0xFFE3D5CA), // 米驼色
      const Color(0xFFA5A58D), // 橄榄绿
      const Color(0xFF6B705C), // 深苔藓
      const Color(0xFFB5838D), // 灰粉色
    ];

    if (count <= 0) return [];
    if (count <= morandiColors.length) {
      // 如果需要的颜色数量不多，直接返回莫兰迪色系的子集
      return morandiColors.sublist(0, count);
    }

    // 如果需要更多颜色，通过调整亮度和色相生成额外的颜色，保持莫兰迪风格
    final List<Color> extendedColors = [...morandiColors];
    final int additionalColorsNeeded = count - morandiColors.length;

    // 为每种基础颜色创建变体
    for (int i = 0; i < additionalColorsNeeded; i++) {
      final baseColor = morandiColors[i % morandiColors.length];
      final HSLColor hslColor = HSLColor.fromColor(baseColor);

      // 调整亮度 - 暗色模式下轻微提亮，亮色模式下轻微变暗
      final double lightnessFactor = isDarkMode ? 0.15 : -0.10;
      final double newLightness =
          (hslColor.lightness + lightnessFactor).clamp(0.2, 0.8);

      // 轻微调整色相，但幅度很小以保持莫兰迪调性
      final double hueShift = (i * 8) % 30; // 最大偏移30度
      final double newHue = (hslColor.hue + hueShift) % 360;

      // 保持低饱和度，这是莫兰迪色系的关键
      final double newSaturation =
          (hslColor.saturation * 0.9).clamp(0.05, 0.35);

      final newColor = HSLColor.fromAHSL(
        1.0,
        newHue,
        newSaturation,
        newLightness,
      ).toColor();

      extendedColors.add(newColor);
    }

    return extendedColors.sublist(0, count);
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
