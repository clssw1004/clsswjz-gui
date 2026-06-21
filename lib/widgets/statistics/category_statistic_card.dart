import 'package:clsswjz_gui/widgets/statistics/category_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/statistics_provider.dart';
import '../common/common_card_container.dart';
import 'category_list.dart';

/// 分类统计卡片
class CategoryStatisticCard extends StatefulWidget {
  const CategoryStatisticCard({super.key});

  @override
  State<CategoryStatisticCard> createState() => _CategoryStatisticCardState();
}

class _CategoryStatisticCardState extends State<CategoryStatisticCard> {
  bool showChart = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10nManager.l10n;
    final statisticsProvider = Provider.of<StatisticsProvider>(context);
    final hasData = statisticsProvider.selectedGroup != null &&
        statisticsProvider.selectedGroup!.categoryGroupList.isNotEmpty;

    return CommonCardContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
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
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildViewToggle(
                        icon: Icons.pie_chart_rounded,
                        isSelected: showChart,
                        onTap: () => setState(() => showChart = true),
                      ),
                      const SizedBox(width: 2),
                      _buildViewToggle(
                        icon: Icons.list_alt_rounded,
                        isSelected: !showChart,
                        onTap: () => setState(() => showChart = false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: hasData
                  ? (showChart
                      ? const CategoryPieChart(key: ValueKey('chart'))
                      : const CategoryList(key: ValueKey('list')))
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.pie_chart_outline,
                              size: 40,
                              color: theme.colorScheme.outline.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.noData,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
