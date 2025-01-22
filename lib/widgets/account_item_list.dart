import 'package:flutter/material.dart';
import '../enums/account_type.dart';
import '../manager/l10n_manager.dart';
import '../models/vo/user_item_vo.dart';
import '../models/vo/user_book_vo.dart';
import '../utils/color_util.dart';
import 'account_item_tile_advance.dart';
import 'account_item_tile_simple.dart';

/// 日期收支统计数据
class DailyStatistics {
  final String date;
  final double income;
  final double expense;

  DailyStatistics(this.date, this.income, this.expense);
}

/// 账目列表
class AccountItemList extends StatefulWidget {
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

  /// 是否使用简约视图
  final bool useSimpleView;

  const AccountItemList({
    super.key,
    required this.accountBook,
    this.initialItems,
    this.loading = false,
    this.onItemTap,
    this.onLoadMore,
    this.hasMore = true,
    this.useSimpleView = false,
  });

  @override
  State<AccountItemList> createState() => _AccountItemListState();
}

class _AccountItemListState extends State<AccountItemList> {
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

  /// 获取处理后的列表项（包含日期分隔）
  List<dynamic> _getItemsWithDateHeaders() {
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
    final sortedDates = itemsByDate.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      final dailyItems = itemsByDate[date]!;
      currentIncome = 0;
      currentExpense = 0;

      // 简约模式下不计算统计数据
      if (!widget.useSimpleView) {
        for (final item in dailyItems) {
          if (AccountItemType.fromCode(item.type) == AccountItemType.income) {
            currentIncome += item.amount;
          } else if (AccountItemType.fromCode(item.type) == AccountItemType.expense) {
            currentExpense += item.amount;
          }
        }
      }

      result.add(DailyStatistics(date, currentIncome, currentExpense));
      result.addAll(dailyItems);
    }

    return result;
  }

  @override
  void didUpdateWidget(AccountItemList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItems != widget.initialItems) {
      _items = widget.initialItems;
    }
  }

  /// 构建日期分隔标题
  Widget _buildDateHeader(DailyStatistics stats, ThemeData theme) {
    if (widget.useSimpleView) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: Text(
          stats.date,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.outline,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
              const SizedBox(height: 4),
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
                const SizedBox(width: 8),
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

  /// 构建加载更多指示器
  Widget _buildLoadMoreIndicator(ThemeData theme) {
    if (!widget.hasMore) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
      padding: const EdgeInsets.symmetric(vertical: 16),
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
            const SizedBox(width: 8),
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

  /// 构建账目列表项
  Widget _buildAccountItem(UserItemVO item, ThemeData theme, int index, List<dynamic> itemsWithHeaders) {
    // 计算实际的账目索引（排除日期分隔）
    int itemIndex = 0;
    for (int i = 0; i < index; i++) {
      if (itemsWithHeaders[i] is UserItemVO) {
        itemIndex++;
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: widget.onItemTap == null ? null : () => widget.onItemTap!(item),
          child: widget.useSimpleView
              ? AccountItemTileSimple(
                  item: item,
                  currencySymbol: widget.accountBook.currencySymbol.symbol,
                  index: itemIndex,
                )
              : AccountItemTileAdvance(
                  item: item,
                  currencySymbol: widget.accountBook.currencySymbol.symbol,
                  index: itemIndex,
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.loading && (_items == null || _items!.isEmpty)) {
      return Center(child: Text(L10nManager.l10n.loading));
    }

    if (_items == null || _items!.isEmpty) {
      return ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
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
                const SizedBox(height: 16),
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

    final itemsWithHeaders = _getItemsWithDateHeaders();

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: itemsWithHeaders.length + 1,
      itemBuilder: (context, index) {
        if (index == itemsWithHeaders.length) {
          return _buildLoadMoreIndicator(theme);
        }

        final item = itemsWithHeaders[index];

        if (item is DailyStatistics) {
          return _buildDateHeader(item, theme);
        }

        return _buildAccountItem(item, theme, index, itemsWithHeaders);
      },
    );
  }
}
