import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/item_list_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';

class StatisticsTab extends StatefulWidget {
  const StatisticsTab({super.key});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = L10nManager.l10n;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(l10n.tabStatistics),
        showBackButton: false,
        centerTitle: false,
      ),
      body: Consumer2<BooksProvider, ItemListProvider>(
        builder: (context, booksProvider, itemListProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 总收支概览卡片
              CommonCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本月收支概览',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '收入',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '¥1,234.56',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '支出',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '¥567.89',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 收支趋势图
              CommonCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '收支趋势',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}日',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            // 收入曲线
                            LineChartBarData(
                              spots: [
                                const FlSpot(1, 100),
                                const FlSpot(5, 150),
                                const FlSpot(10, 200),
                                const FlSpot(15, 75),
                                const FlSpot(20, 300),
                                const FlSpot(25, 250),
                                const FlSpot(30, 280),
                              ],
                              isCurved: true,
                              color: colorScheme.primary,
                              barWidth: 2,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                            // 支出曲线
                            LineChartBarData(
                              spots: [
                                const FlSpot(1, 50),
                                const FlSpot(5, 100),
                                const FlSpot(10, 80),
                                const FlSpot(15, 150),
                                const FlSpot(20, 90),
                                const FlSpot(25, 180),
                                const FlSpot(30, 120),
                              ],
                              isCurved: true,
                              color: colorScheme.error,
                              barWidth: 2,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: colorScheme.error.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 收支分类占比
              CommonCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '支出分类占比',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: 35,
                              title: '餐饮',
                              color: colorScheme.primary,
                              radius: 80,
                              titleStyle: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            PieChartSectionData(
                              value: 25,
                              title: '购物',
                              color: colorScheme.secondary,
                              radius: 80,
                              titleStyle: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSecondary,
                              ),
                            ),
                            PieChartSectionData(
                              value: 20,
                              title: '交通',
                              color: colorScheme.tertiary,
                              radius: 80,
                              titleStyle: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onTertiary,
                              ),
                            ),
                            PieChartSectionData(
                              value: 20,
                              title: '其他',
                              color: colorScheme.surfaceVariant,
                              radius: 80,
                              titleStyle: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 月度收支对比
              CommonCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '月度收支对比',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: BarChart(
                        BarChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt() + 1}月',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: 100,
                                  color: colorScheme.primary,
                                  width: 12,
                                ),
                                BarChartRodData(
                                  toY: 80,
                                  color: colorScheme.error,
                                  width: 12,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: 150,
                                  color: colorScheme.primary,
                                  width: 12,
                                ),
                                BarChartRodData(
                                  toY: 100,
                                  color: colorScheme.error,
                                  width: 12,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(
                                  toY: 200,
                                  color: colorScheme.primary,
                                  width: 12,
                                ),
                                BarChartRodData(
                                  toY: 150,
                                  color: colorScheme.error,
                                  width: 12,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 3,
                              barRods: [
                                BarChartRodData(
                                  toY: 180,
                                  color: colorScheme.primary,
                                  width: 12,
                                ),
                                BarChartRodData(
                                  toY: 130,
                                  color: colorScheme.error,
                                  width: 12,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 4,
                              barRods: [
                                BarChartRodData(
                                  toY: 220,
                                  color: colorScheme.primary,
                                  width: 12,
                                ),
                                BarChartRodData(
                                  toY: 170,
                                  color: colorScheme.error,
                                  width: 12,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 5,
                              barRods: [
                                BarChartRodData(
                                  toY: 190,
                                  color: colorScheme.primary,
                                  width: 12,
                                ),
                                BarChartRodData(
                                  toY: 140,
                                  color: colorScheme.error,
                                  width: 12,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 