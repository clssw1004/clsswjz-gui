import 'package:clsswjz/providers/item_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../providers/books_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/book/book_selector.dart';
import '../../widgets/book/item_filter_sheet.dart';
import '../../widgets/book/item_list_advance.dart';
import '../../widgets/book/item_list_timeline.dart';
import '../../widgets/book/item_list_calendar.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../enums/item_view_mode.dart';

/// 账目列表标签页
class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  bool _isRefreshing = false;
  ItemViewMode _viewMode = AppConfigManager.instance.accountItemViewMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadBooks(AppConfigManager.instance.userId);
    });
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      final syncProvider = context.read<SyncProvider>();
      // 只进行同步操作，刷新由事件总线统一处理
      await syncProvider.syncData();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ItemListProvider>();
      provider.loadItems();
    });
  }

  /// 显示筛选面板
  void _showFilterSheet() {
    final selectedBook = context.read<BooksProvider>().selectedBook;
    final provider = context.read<ItemListProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ItemFilterSheet(
            initialFilter: provider.filter,
            selectedBook: selectedBook,
            onConfirm: (filter) {
              provider.setFilter(filter);
            },
            onClear: () {
              provider.setFilter(const ItemFilterDTO());
            },
          ),
        ),
      ),
    );
  }

  /// 构建视图切换按钮
  Widget _buildViewModeButton(ThemeData theme) {
    return PopupMenuButton<ItemViewMode>(
      icon: Icon(
        _viewMode == ItemViewMode.advance
            ? Icons.view_agenda
            : _viewMode == ItemViewMode.timeline
                ? Icons.timeline
                : Icons.calendar_month,
        color: theme.colorScheme.primary,
      ),
      onSelected: (mode) {
        setState(() {
          _viewMode = mode;
          AppConfigManager.instance.setAccountItemViewMode(mode);
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ItemViewMode.advance,
          child: Row(
            children: [
              Icon(
                Icons.view_agenda,
                color: _viewMode == ItemViewMode.advance
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(L10nManager.l10n.advanceMode),
            ],
          ),
        ),
        PopupMenuItem(
          value: ItemViewMode.timeline,
          child: Row(
            children: [
              Icon(
                Icons.timeline,
                color: _viewMode == ItemViewMode.timeline
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(L10nManager.l10n.timelineMode),
            ],
          ),
        ),
        PopupMenuItem(
          value: ItemViewMode.calendar,
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: _viewMode == ItemViewMode.calendar
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(L10nManager.l10n.calendarMode),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建账目列表
  Widget _buildItemList() {
    final provider = context.read<ItemListProvider>();
    final bookProvider = context.read<BooksProvider>();
    final selectedBook = bookProvider.selectedBook;

    if (selectedBook == null) {
      return const SizedBox.shrink();
    }

    switch (_viewMode) {
      case ItemViewMode.advance:
        return ItemListAdvance(
          accountBook: selectedBook,
          initialItems: provider.items,
          loading: provider.loading,
          onItemTap: (item) {
            Navigator.pushNamed(
              context,
              AppRoutes.itemEdit,
              arguments: [item, selectedBook],
            ).then((updated) {
              if (updated == true) {
                provider.loadItems();
              }
            });
          },
          onLoadMore: provider.loadMore,
          hasMore: provider.hasMore,
        );
      case ItemViewMode.timeline:
        return ItemListTimeline(
          accountBook: selectedBook,
          initialItems: provider.items,
          loading: provider.loading,
          onItemTap: (item) {
            Navigator.pushNamed(
              context,
              AppRoutes.itemEdit,
              arguments: [item, selectedBook],
            ).then((updated) {
              if (updated == true) {
                provider.loadItems();
              }
            });
          },
          onLoadMore: provider.loadMore,
          hasMore: provider.hasMore,
        );
      case ItemViewMode.calendar:
        return ItemListCalendar(
          accountBook: selectedBook,
          initialItems: provider.items,
          loading: provider.loading,
          onItemTap: (item) {
            Navigator.pushNamed(
              context,
              AppRoutes.itemEdit,
              arguments: [item, selectedBook],
            ).then((updated) {
              if (updated == true) {
                provider.loadItems();
              }
            });
          },
          onLoadMore: provider.loadMore,
          hasMore: provider.hasMore,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: false,
        title: Consumer<BooksProvider>(
          builder: (context, provider, child) {
            final key = ValueKey(
                '${provider.selectedBook?.id ?? ''}_${provider.books.length}');
            return BookSelector(
              key: key,
              userId: AppConfigManager.instance.userId,
              books: provider.books,
              selectedBook: provider.selectedBook,
              onSelected: (book) {
                provider.setSelectedBook(book);
              },
            );
          },
        ),
        actions: [
          // 筛选按钮
          IconButton(
            onPressed: _showFilterSheet,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (context.read<ItemListProvider>().filter?.isNotEmpty == true)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: '筛选',
          ),
          // 视图切换按钮
          _buildViewModeButton(theme),
        ],
      ),
      body: Consumer3<BooksProvider, ItemListProvider, SyncProvider>(
        builder:
            (context, bookProvider, itemListProvider, syncProvider, child) {
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
                                      AppRoutes.bookForm,
                                    );
                                    if (result == true) {
                                      await bookProvider.init(
                                          AppConfigManager.instance.userId);
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: Text(L10nManager.l10n
                                      .addNew(L10nManager.l10n.accountBook)),
                                ),
                              ],
                            ),
                          )
                        : CustomRefreshIndicator(
                            onRefresh: _handleRefresh,
                            builder: (context, child, controller) => child,
                            child: _buildItemList(),
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
      floatingActionButton: Consumer2<BooksProvider, ItemListProvider>(
        builder: (context, bookProvider, itemListProvider, child) {
          final accountBook = bookProvider.selectedBook;
          if (accountBook == null) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.itemAdd,
                arguments: [accountBook],
              ).then((added) {
                if (added == true) {
                  itemListProvider.loadItems();
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
