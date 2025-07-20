import 'package:clsswjz_gui/widgets/statistics/category_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/statistics_provider.dart';
import 'category_list.dart';

/// 分类统计卡片：可切换扇形图/分类列表
class CategoryStatisticCard extends StatefulWidget {
  const CategoryStatisticCard({super.key});

  @override
  State<CategoryStatisticCard> createState() => _CategoryStatisticCardState();
}

class _CategoryStatisticCardState extends State<CategoryStatisticCard> {
  bool showChart = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10nManager.l10n;
    final statisticsProvider = Provider.of<StatisticsProvider>(context);
    final hasData = statisticsProvider.selectedGroup != null && statisticsProvider.selectedGroup!.categoryGroupList.isNotEmpty;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.categoryDistribution,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                ToggleButtons(
                  isSelected: [showChart, !showChart],
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: theme.colorScheme.onPrimary,
                  fillColor: theme.colorScheme.primary,
                  color: theme.colorScheme.primary,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: (index) {
                    setState(() {
                      showChart = index == 0;
                    });
                  },
                  children: [
                    Tooltip(
                      message: l10n.categoryDistribution,
                      child: const Icon(Icons.pie_chart_outline),
                    ),
                    Tooltip(
                      message: l10n.category,
                      child: const Icon(Icons.list_alt_outlined),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: hasData
                  ? (showChart
                      ? const CategoryPieChart()
                      : const CategoryList(key: ValueKey('list')))
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text(l10n.noData, style: theme.textTheme.bodyMedium)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
} 