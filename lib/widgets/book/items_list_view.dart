import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../enums/account_type.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/color_util.dart';
import 'item_tile_advance.dart';
import '../../providers/items_provider.dart';

class ItemsListView extends StatefulWidget {
  final UserBookVO accountBook;
  final void Function(UserItemVO item)? onItemTap;
  final Future<bool> Function(UserItemVO item)? onDelete;

  const ItemsListView({
    super.key,
    required this.accountBook,
    this.onItemTap,
    this.onDelete,
  });

  @override
  State<ItemsListView> createState() => _ItemsListViewState();
}

class DailyStatistics {
  final String date;
  final double income;
  final double expense;
  DailyStatistics(this.date, this.income, this.expense);
}

class _ItemsListViewState extends State<ItemsListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final provider = context.read<ItemsProvider>();
    if (provider.loadingMore || !provider.hasMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final provider = context.read<ItemsProvider>();
    await provider.loadMore();
  }

  Widget _buildLoadingState() {
    return Center(child: Text(L10nManager.l10n.loading));
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: theme.spacing.listPadding,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              SizedBox(height: theme.spacing.listItemSpacing * 2),
              Text(
                L10nManager.l10n.noAccountItems,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<dynamic> _getItemsWithDateHeaders(List<UserItemVO> items, {bool includeStats = false}) {
    if (items.isEmpty) return [];
    final result = <dynamic>[];
    double currentIncome = 0;
    double currentExpense = 0;
    final itemsByDate = <String, List<UserItemVO>>{};
    for (final item in items) {
      final itemDate = item.accountDateOnly;
      itemsByDate.putIfAbsent(itemDate, () => []).add(item);
    }
    final sortedDates = itemsByDate.keys.toList()..sort((a, b) => b.compareTo(a));
    for (final date in sortedDates) {
      final dailyItems = itemsByDate[date]!;
      currentIncome = 0;
      currentExpense = 0;
      if (includeStats) {
        for (final item in dailyItems) {
          final itemType = AccountItemType.fromCode(item.type);
          if (itemType == AccountItemType.income) {
            currentIncome += item.amount;
          } else if (itemType == AccountItemType.expense) {
            currentExpense += item.amount;
          }
        }
      }
      result.add(DailyStatistics(date, currentIncome, currentExpense));
      result.addAll(dailyItems);
    }
    return result;
  }

  Widget _buildDateHeader(DailyStatistics stats, ThemeData theme) {
    final spacing = theme.spacing;
    return Container(
      margin: EdgeInsets.only(bottom: spacing.listItemSpacing),
      padding: EdgeInsets.fromLTRB(
        spacing.listItemPadding.left,
        spacing.listItemSpacing,
        spacing.listItemPadding.right,
        spacing.listItemSpacing,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(255),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(32),
            width: 1,
          ),
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stats.date,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: spacing.listItemSpacing / 2),
              Container(
                width: 32,
                height: 2,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(128),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (stats.income > 0)
                Text(
                  '+${stats.income.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ColorUtil.INCOME,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
              if (stats.expense < 0) ...[
                SizedBox(width: spacing.listItemSpacing),
                Text(
                  stats.expense.toStringAsFixed(2),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ColorUtil.EXPENSE,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(UserItemVO item, int index, List<dynamic> itemsWithHeaders) {
    int itemIndex = 0;
    for (int i = 0; i < index; i++) {
      if (itemsWithHeaders[i] is UserItemVO) {
        itemIndex++;
      }
    }
    return InkWell(
      onTap: widget.onItemTap == null ? null : () => widget.onItemTap!(item),
      child: ItemTileAdvance(
        item: item,
        currencySymbol: widget.accountBook.currencySymbol.symbol,
        index: itemIndex,
        onDelete: widget.onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<ItemsProvider>();
    final items = provider.items;
    final isLoading = provider.loading && items.isEmpty;

    if (isLoading) return _buildLoadingState();
    if (items.isEmpty) return _buildEmptyState(theme);

    final itemsWithHeaders = _getItemsWithDateHeaders(items, includeStats: true);

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: itemsWithHeaders.length + 1,
      itemBuilder: (context, index) {
        if (index == itemsWithHeaders.length) {
          if (!provider.hasMore) {
            return Container(
              padding: theme.spacing.loadMorePadding,
              child: Center(
                child: Text(
                  L10nManager.l10n.noMore,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            );
          }
          return Container(
            padding: theme.spacing.loadMorePadding,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: theme.spacing.listItemSpacing),
                  Text(
                    L10nManager.l10n.loading,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        final item = itemsWithHeaders[index];
        if (item is DailyStatistics) {
          return _buildDateHeader(item, theme);
        }
        return _buildAccountItem(item, index, itemsWithHeaders);
      },
    );
  }
}


