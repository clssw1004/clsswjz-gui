import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../enums/account_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/item_list_provider.dart';
import '../../utils/color_util.dart';
import '../../theme/theme_spacing.dart';
import 'item_tile_advance.dart';

/// 高级模式账目列表
class ItemListAdvance extends StatefulWidget {
  /// 账本
  final UserBookVO accountBook;

  /// 点击账目回调
  final void Function(UserItemVO item)? onItemTap;

  /// 删除账目回调
  final Future<bool> Function(UserItemVO item)? onDelete;

  const ItemListAdvance({
    super.key,
    required this.accountBook,
    this.onItemTap,
    this.onDelete,
  });

  @override
  State<ItemListAdvance> createState() => _ItemListAdvanceState();
}

/// 日期收支统计数据
class DailyStatistics {
  final String date;
  final double income;
  final double expense;

  DailyStatistics(this.date, this.income, this.expense);
}

class _ItemListAdvanceState extends State<ItemListAdvance> {
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

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  /// 加载数据
  Future<void> _loadData() async {
    if (_loading) return;
    setState(() {
      _loading = true;
    });

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
  void didUpdateWidget(ItemListAdvance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountBook.id != widget.accountBook.id) {
      _loadData();
    }
  }

  /// 构建加载更多指示器
  Widget _buildLoadMoreIndicator(ThemeData theme) {
    if (!_hasMore) {
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

    if (context.read<ItemListProvider>().loading &&
        (_items == null || _items!.isEmpty)) {
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
