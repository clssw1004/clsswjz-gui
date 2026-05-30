import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/item_list_provider.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';
import 'item_tile_timeline.dart';

/// 时间线账目列表
class ItemListTimeline extends StatefulWidget {
  /// 账本
  final UserBookVO accountBook;

  /// 点击账目回调
  final void Function(UserItemVO item)? onItemTap;

  const ItemListTimeline({
    super.key,
    required this.accountBook,
    this.onItemTap,
  });

  @override
  State<ItemListTimeline> createState() => _ItemListTimelineState();
}

class _ItemListTimelineState extends State<ItemListTimeline> {
  /// 账目列表
  List<UserItemVO>? _items;

  /// 是否正在加载
  bool _loading = false;

  /// 是否还有更多数据
  bool _hasMore = true;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
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
    if (_loading || !_hasMore) return;

    // 当距离底部还有 200 像素时加载更多
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  /// 加载数据
  Future<void> _loadData() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final provider = context.read<ItemListProvider>();
      await provider.loadItems(refresh: true);
      if (mounted) {
        setState(() {
          _items = provider.items;
          _hasMore = provider.hasMore;
          _loading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /// 加载更多数据
  Future<void> _loadMoreData() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    try {
      final provider = context.read<ItemListProvider>();
      await provider.loadMore();
      if (mounted) {
        setState(() {
          _items = provider.items;
          _hasMore = provider.hasMore;
          _loading = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void didUpdateWidget(ItemListTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountBook.id != widget.accountBook.id) {
      _loadData();
    }
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
      result.add(date);
      result.addAll(dailyItems);
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading && (_items == null || _items!.isEmpty)) {
      return _buildLoadingState();
    }

    if (_items == null || _items!.isEmpty) {
      return _buildEmptyState(theme);
    }

    final itemsWithHeaders = _getItemsWithDateHeaders();

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.zero,
      itemCount: itemsWithHeaders.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == itemsWithHeaders.length) {
          return _loading ? _buildLoadMoreIndicator(theme) : const SizedBox.shrink();
        }

        final item = itemsWithHeaders[index];

        if (item is String) {
          return _buildDateHeader(item, theme);
        }

        if (item is UserItemVO) {
          final isFirst = index == 0 || itemsWithHeaders[index - 1] is String;
          return InkWell(
            onTap: widget.onItemTap == null
                ? null
                : () => widget.onItemTap!(item),
            child: ItemTileTimeline(
              item: item,
              currencySymbol: widget.accountBook.currencySymbol.symbol,
              index: index,
              isFirst: isFirst,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// 构建日期头部
  Widget _buildDateHeader(String date, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: theme.spacing.listItemSpacing * 2,
        bottom: theme.spacing.listItemSpacing,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.only(left: 16, right: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.outlineVariant.withAlpha(0),
                    colorScheme.outlineVariant.withAlpha(128),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.listItemSpacing * 1.5,
              vertical: theme.spacing.listItemSpacing / 2,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withAlpha(51),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  date,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.only(left: 8, right: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.outlineVariant.withAlpha(128),
                    colorScheme.outlineVariant.withAlpha(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建加载更多指示器
  Widget _buildLoadMoreIndicator(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
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
                color: colorScheme.primary,
              ),
            ),
            SizedBox(width: theme.spacing.listItemSpacing),
            Text(
              L10nManager.l10n.loading,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    
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
                color: colorScheme.outline,
              ),
              SizedBox(height: theme.spacing.listItemSpacing * 2),
              Text(
                L10nManager.l10n.noAccountItems,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.outline,
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(L10nManager.l10n.loading),
        ],
      ),
    );
  }
}
 