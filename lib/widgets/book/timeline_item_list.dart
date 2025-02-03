import 'package:flutter/material.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';
import 'item_tile_simple.dart';

/// 时间线账目列表
class TimelineItemList extends StatefulWidget {
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

  const TimelineItemList({
    super.key,
    required this.accountBook,
    this.initialItems,
    this.loading = false,
    this.onItemTap,
    this.onLoadMore,
    this.hasMore = true,
  });

  @override
  State<TimelineItemList> createState() => _TimelineItemListState();
}

class _TimelineItemListState extends State<TimelineItemList> {
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

    // 当距离底部还有 200 像素时开始加载
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
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
  void didUpdateWidget(TimelineItemList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItems != widget.initialItems) {
      _items = widget.initialItems;
      // 重置加载状态
      _loadingMore = false;
    }
    // 当 hasMore 状态改变时，也重置加载状态
    if (oldWidget.hasMore != widget.hasMore) {
      _loadingMore = false;
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
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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

  /// 构建日期头部
  Widget _buildDateHeader(String date, ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: theme.spacing.listItemSpacing * 2,
        bottom: theme.spacing.listItemSpacing,
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.listItemSpacing * 2,
            vertical: theme.spacing.listItemSpacing / 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Text(
            date,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建时间线
  Widget _buildTimeline(ThemeData theme) {
    return Container(
      width: 1.5,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.3),
            theme.colorScheme.primary.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  /// 获取处理后的列表项（包含日期分隔）
  List<dynamic> _getItemsWithDateHeaders() {
    if (_items == null || _items!.isEmpty) return [];

    final result = <dynamic>[];
    final itemsByDate = <String, List<UserItemVO>>{};

    // 按日期分组
    for (final item in _items!) {
      final itemDate = item.accountDateOnly;
      itemsByDate.putIfAbsent(itemDate, () => []).add(item);
    }

    // 按日期降序排序
    final sortedDates = itemsByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      final dailyItems = itemsByDate[date]!;
      // 只有当日期下有账目时才添加日期分割线和账目
      if (dailyItems.isNotEmpty) {
        result.add(date);
        result.addAll(dailyItems);
      }
    }

    return result;
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

    final itemsWithHeaders = _getItemsWithDateHeaders();

    return Stack(
      children: [
        // 时间线背景
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                alignment: Alignment.center,
                child: _buildTimeline(theme),
              ),
            ],
          ),
        ),
        // 列表内容
        ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.listItemPadding.left,
            vertical: theme.spacing.listItemSpacing,
          ),
          itemCount: itemsWithHeaders.length + 1,
          itemBuilder: (context, index) {
            if (index == itemsWithHeaders.length) {
              return _buildLoadMoreIndicator(theme);
            }

            final item = itemsWithHeaders[index];

            if (item is String) {
              // 日期分割线
              return _buildDateHeader(item, theme);
            }

            if (item is UserItemVO) {
              return InkWell(
                onTap: widget.onItemTap == null ? null : () => widget.onItemTap!(item),
                child: ItemTileSimple(
                  item: item,
                  currencySymbol: widget.accountBook.currencySymbol.symbol,
                  index: index,
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
} 