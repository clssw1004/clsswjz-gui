import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../models/vo/statistic_vo.dart';
import '../../providers/statistics_provider.dart';

/// 分类统计列表组件
class CategoryList extends StatelessWidget {
  const CategoryList({
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
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.category,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1),
            ...sortedItems.map(
              (item) => _buildCategoryItem(context, item, total),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryItem(
    BuildContext context,
    CategoryStatisticVO item,
    double total,
  ) {
    final theme = Theme.of(context);
    final statisticsProvider = Provider.of<StatisticsProvider>(context);
    
    final percentage = total > 0 ? (item.amount.abs() / total) * 100 : 0;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  item.categoryName.isEmpty ? '未分类' : item.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  item.amount.abs().toStringAsFixed(2),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: statisticsProvider.selectedTab == 'income'
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1),
      ],
    );
  }
} 