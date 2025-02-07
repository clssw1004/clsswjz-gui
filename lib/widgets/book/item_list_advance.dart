import 'package:flutter/material.dart';
import '../../enums/account_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../utils/color_util.dart';
import '../../theme/theme_spacing.dart';
import 'item_tile_advance.dart';

/// 账目列表基类
abstract class BaseItemList extends StatefulWidget {
  /// 账本
  final UserBookVO accountBook;

  /// 初始账目列表
  final List<UserItemVO>? initialItems;

  /// 是否加载中
  final bool loading;

  /// 点击账目回调
  final void Function(UserItemVO item)? onItemTap;

  /// 加载更多回调
  final Future<void> Function()? onLoadMore;

  /// 是否还有更多数据
  final bool hasMore;

  const BaseItemList({
    super.key,
    required this.accountBook,
    this.initialItems,
    this.loading = false,
    this.onItemTap,
    this.onLoadMore,
    this.hasMore = true,
  });
}

/// 高级模式账目列表
class ItemListAdvance extends BaseItemList {
  /// 删除账目回调
  final Future<bool> Function(UserItemVO item)? onDelete;

  const ItemListAdvance({
    super.key,
    required super.accountBook,
    super.initialItems,
    super.loading = false,
    super.onItemTap,
    super.onLoadMore,
    super.hasMore = true,
    this.onDelete,
  });

  @override
  State<ItemListAdvance> createState() => _AdvanceItemListState();
}

/// 日期收支统计数据
class DailyStatistics {
  final String date;
  final double income;
  final double expense;

  DailyStatistics(this.date, this.income, this.expense);
}

/// 基类状态
abstract class _BaseItemListState<T extends BaseItemList> extends State<T> {
  /// 账目列表
  List<UserItemVO>? _items;

  /// 是否正在加载更多
  bool _loadingMore = false;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动监听
  void _onScroll() {
    if (!widget.hasMore || _loadingMore || widget.onLoadMore == null) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  /// 加载更多数据
  Future<void> _loadMore() async {
    if (_loadingMore || !widget.hasMore) return;

    setState(() => _loadingMore = true);

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItems != widget.initialItems) {
      _items = widget.initialItems;
    }
  }

  /// 构建加载更多指示器
  Widget _buildLoadMoreIndicator(ThemeData theme) {
    if (!widget.hasMore) {
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

  /// 构建空状态
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

  /// 构建加载状态
  Widget _buildLoadingState() {
    return Center(child: Text(L10nManager.l10n.loading));
  }

  /// 获取处理后的列表项（包含日期分隔）
  List<dynamic> _getItemsWithDateHeaders({bool includeStats = false}) {
    if (_items == null || _items!.isEmpty) return [];

    final result = <dynamic>[];
    double currentIncome = 0;
    double currentExpense = 0;
    final itemsByDate = <String, List<UserItemVO>>{};

    // 按日期分组并计算统计
    for (final item in _items!) {
      final itemDate = item.accountDateOnly;
      itemsByDate.putIfAbsent(itemDate, () => []).add(item);
    }

    // 按日期降序排序
    final sortedDates = itemsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      final dailyItems = itemsByDate[date]!;
      currentIncome = 0;
      currentExpense = 0;

      // 计算统计数据
      if (includeStats) {
        for (final item in dailyItems) {
          if (AccountItemType.fromCode(item.type) == AccountItemType.income) {
            currentIncome += item.amount;
          } else if (AccountItemType.fromCode(item.type) ==
              AccountItemType.expense) {
            currentExpense += item.amount;
          }
        }
      }

      result.add(DailyStatistics(date, currentIncome, currentExpense));
      result.addAll(dailyItems);
    }

    return result;
  }
}

/// 高级模式状态
class _AdvanceItemListState extends _BaseItemListState<ItemListAdvance> {
  /// 构建日期分隔标题
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

  /// 构建账目列表项
  Widget _buildAccountItem(
      UserItemVO item, int index, List<dynamic> itemsWithHeaders) {
    // 计算实际的账目索引（排除日期分隔）
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

    if (widget.loading && (_items == null || _items!.isEmpty)) {
      return _buildLoadingState();
    }

    if (_items == null || _items!.isEmpty) {
      return _buildEmptyState(theme);
    }

    final itemsWithHeaders = _getItemsWithDateHeaders(includeStats: true);

    return ListView.builder(
      controller: _scrollController,
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: itemsWithHeaders.length + 1,
      itemBuilder: (context, index) {
        if (index == itemsWithHeaders.length) {
          return _buildLoadMoreIndicator(theme);
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