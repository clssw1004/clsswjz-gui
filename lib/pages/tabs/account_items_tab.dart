import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../enums/account_type.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/user_config_manager.dart';
import '../../providers/account_books_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/color_util.dart';
import '../../widgets/account_book_selector.dart';
import '../../widgets/account_item_list_tile.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../models/vo/account_item_vo.dart';
import '../../models/vo/user_book_vo.dart';

/// 日期收支统计数据
class DailyStatistics {
  final String date;
  final double income;
  final double expense;

  DailyStatistics(this.date, this.income, this.expense);
}

/// 账目列表标签页
class AccountItemsTab extends StatefulWidget {
  const AccountItemsTab({super.key});

  @override
  State<AccountItemsTab> createState() => _AccountItemsTabState();
}

class _AccountItemsTabState extends State<AccountItemsTab> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountBooksProvider>().loadBooks(UserConfigManager.currentUserId);
    });
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      final syncProvider = context.read<SyncProvider>();
      final bookProvider = context.read<AccountBooksProvider>();
      // 先进行同步
      try {
        await syncProvider.syncData();
      } catch (e) {
        // 同步失败继续刷新列表
      }
      // 同步完成后刷新列表
      await bookProvider.loadItems();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<AccountBooksProvider>();
    if (provider.books.isEmpty && !provider.loadingBooks) {
      provider.loadBooks(UserConfigManager.currentUserId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: false,
        title: Consumer<AccountBooksProvider>(
          builder: (context, provider, child) {
            return AccountBookSelector(
              userId: UserConfigManager.currentUserId,
              books: provider.books,
              selectedBook: provider.selectedBook,
              onSelected: (book) {
                provider.setSelectedBook(book);
              },
            );
          },
        ),
      ),
      body: Consumer2<AccountBooksProvider, SyncProvider>(
        builder: (context, bookProvider, syncProvider, child) {
          final accountBook = bookProvider.selectedBook;
          return Stack(
            children: [
              Column(
                children: [
                  // 账目列表
                  Expanded(
                    child: accountBook == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(L10nManager.l10n.noAccountBooks),
                                const SizedBox(height: 16),
                                FilledButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      AppRoutes.accountBookForm,
                                    );
                                    if (result == true) {
                                      await bookProvider.init(UserConfigManager.currentUserId);
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: Text(L10nManager.l10n.addNew(L10nManager.l10n.accountBook)),
                                ),
                              ],
                            ),
                          )
                        : CustomRefreshIndicator(
                            onRefresh: _handleRefresh,
                            builder: (context, child, controller) => child,
                            child: _AccountItemList(
                              accountBook: accountBook,
                              initialItems: bookProvider.items,
                              loading: bookProvider.loadingItems,
                              onItemTap: (item) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.accountItemEdit,
                                  arguments: [accountBook, item],
                                ).then((updated) {
                                  if (updated == true) {
                                    bookProvider.loadItems();
                                  }
                                });
                              },
                            ),
                          ),
                  ),
                ],
              ),
              // 同步进度条
              if (syncProvider.syncing && syncProvider.currentStep != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ProgressIndicatorBar(
                    value: syncProvider.progress,
                    label: syncProvider.currentStep!,
                    height: 24,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AccountBooksProvider>(
        builder: (context, provider, child) {
          final accountBook = provider.selectedBook;
          if (accountBook == null) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.accountItemAdd,
                arguments: [accountBook],
              ).then((added) {
                if (added == true) {
                  provider.loadItems();
                }
              });
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

/// 账目列表
class _AccountItemList extends StatefulWidget {
  /// 账本
  final UserBookVO accountBook;

  /// 初始账目列表
  final List<AccountItemVO>? initialItems;

  /// 是否加载中
  final bool loading;

  /// 点击账目回调
  final void Function(AccountItemVO item)? onItemTap;

  const _AccountItemList({
    required this.accountBook,
    this.initialItems,
    this.loading = false,
    this.onItemTap,
  });

  @override
  State<_AccountItemList> createState() => _AccountItemListState();
}

class _AccountItemListState extends State<_AccountItemList> {
  /// 账目列表
  List<AccountItemVO>? _items;

  /// 获取处理后的列表项（包含日期分隔）
  List<dynamic> _getItemsWithDateHeaders() {
    if (_items == null || _items!.isEmpty) return [];

    final result = <dynamic>[];
    String? currentDate;
    double currentIncome = 0;
    double currentExpense = 0;
    final itemsByDate = <String, List<AccountItemVO>>{};

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

      for (final item in dailyItems) {
        if (AccountItemType.fromCode(item.type) == AccountItemType.income) {
          currentIncome += item.amount;
        } else if (AccountItemType.fromCode(item.type) == AccountItemType.expense) {
          currentExpense += item.amount;
        }
      }

      result.add(DailyStatistics(date, currentExpense, currentIncome));
      result.addAll(dailyItems);
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems;
  }

  @override
  void didUpdateWidget(_AccountItemList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialItems != widget.initialItems) {
      _items = widget.initialItems;
    }
  }

  /// 构建日期分隔标题
  Widget _buildDateHeader(DailyStatistics stats, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            stats.date,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${stats.income.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorUtil.INCOME,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '-${stats.expense.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: ColorUtil.EXPENSE,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
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
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemsWithHeaders.length,
      itemBuilder: (context, index) {
        final item = itemsWithHeaders[index];

        if (item is DailyStatistics) {
          return _buildDateHeader(item, theme);
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: widget.onItemTap == null ? null : () => widget.onItemTap!(item),
              child: AccountItemListTile(
                item: item,
                currencySymbol: widget.accountBook.currencySymbol.symbol,
              ),
            ),
            if (index < itemsWithHeaders.length - 1 && itemsWithHeaders[index + 1] is! DailyStatistics) const Divider(height: 1),
          ],
        );
      },
    );
  }
}
