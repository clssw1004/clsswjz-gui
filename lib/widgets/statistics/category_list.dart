import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/account_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/statistic_vo.dart';
import '../../providers/statistics_provider.dart';
import '../../routes/app_routes.dart';
import '../../providers/books_provider.dart';
import '../../utils/color_util.dart';

/// 分类统计列表组件
class CategoryList extends StatefulWidget {
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
    final statisticsProvider = Provider.of<StatisticsProvider>(context);

    final selectedGroup = statisticsProvider.selectedGroup;
    if (selectedGroup == null || selectedGroup.categoryGroupList.isEmpty) {
      return const SizedBox();
    }

    final sortedItems = statisticsProvider.sortedCategoryList;
    final total = statisticsProvider.totalAmount;
    final isIncome = statisticsProvider.selectedTab == AccountItemType.income.code;
    final color = isIncome ? ColorUtil.INCOME : ColorUtil.EXPENSE;

    final displayItems =
        _showAll ? sortedItems : sortedItems.take(widget.defaultDisplayCount).toList();
    final showMoreButton = sortedItems.length > widget.defaultDisplayCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayItems.map((item) => _buildCategoryItem(
              context: context,
              item: item,
              total: total,
              color: color,
              theme: theme,
              statisticsProvider: statisticsProvider,
            )),
        if (showMoreButton) _buildShowMoreButton(context, theme),
      ],
    );
  }

  Widget _buildShowMoreButton(BuildContext context, ThemeData theme) {
    final l10n = L10nManager.l10n;

    return InkWell(
      onTap: () => setState(() => _showAll = !_showAll),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
              size: 18,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required BuildContext context,
    required CategoryStatisticVO item,
    required double total,
    required Color color,
    required ThemeData theme,
    required StatisticsProvider statisticsProvider,
  }) {
    final percentage = total > 0 ? (item.amount.abs() / total) * 100 : 0.0;

    return InkWell(
      onTap: () {
        final books = Provider.of<BooksProvider>(context, listen: false);
        final bookMeta = books.selectedBook;
        if (bookMeta == null) return;
        final filter = ItemFilterDTO(
          categoryCodes: [item.categoryCode],
          types: [statisticsProvider.selectedTab],
        );
        final start = statisticsProvider.currentStart;
        final end = statisticsProvider.currentEnd;
        if (start != null || end != null) {
          final s = start?.toIso8601String().substring(0, 10);
          final e = end?.toIso8601String().substring(0, 10);
          final withDate = filter.copyWith(startDate: s, endDate: e);
          Navigator.of(context).pushNamed(
            AppRoutes.items,
            arguments: [
              bookMeta,
              withDate,
              item.categoryName.isEmpty ? L10nManager.l10n.category : item.categoryName,
            ],
          );
          return;
        }
        Navigator.of(context).pushNamed(
          AppRoutes.items,
          arguments: [
            bookMeta,
            filter,
            item.categoryName.isEmpty ? L10nManager.l10n.category : item.categoryName,
          ],
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.categoryName.isEmpty ? '未分类' : item.categoryName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  item.amount.abs().toStringAsFixed(2),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
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
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 4,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  color.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
