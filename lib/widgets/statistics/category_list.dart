import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../models/vo/statistic_vo.dart';
import '../../providers/statistics_provider.dart';

/// 分类统计列表组件
class CategoryList extends StatefulWidget {
  /// 默认展示的分类数量
  final int defaultDisplayCount;

  const CategoryList({
    super.key,
    this.defaultDisplayCount = 5,
  });

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  bool _showAll = false;

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
    
    // 根据_showAll状态决定显示的项目数量
    final displayItems = _showAll 
        ? sortedItems 
        : sortedItems.take(widget.defaultDisplayCount).toList();
    
    // 是否需要显示"更多"按钮
    final showMoreButton = sortedItems.length > widget.defaultDisplayCount;
    
    return Column(
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
        ...displayItems.map(
          (item) => _buildCategoryItem(context, item, total),
        ),
        // 显示"更多"按钮
        if (showMoreButton)
          _buildShowMoreButton(context),
      ],
    );
  }
  
  Widget _buildShowMoreButton(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10nManager.l10n;
    
    return InkWell(
      onTap: () {
        setState(() {
          _showAll = !_showAll;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withAlpha(128),
              width: 0.5,
            ),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _showAll ? l10n.showLess : l10n.showMore,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                _showAll ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
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
                child: Row(
                  children: [
                    Text(
                      item.categoryName.isEmpty ? '未分类' : item.categoryName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.count > 0) ...[
                      const SizedBox(width: 6),
                      Text('(${item.count})',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ],
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