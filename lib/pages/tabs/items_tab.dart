import 'package:clsswjz/providers/item_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/user_config_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/book/book_selector.dart';
import '../../widgets/book/item_list.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../enums/account_item_view_mode.dart';

/// 账目列表标签页
class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  bool _isRefreshing = false;
  AccountItemViewMode _viewMode = AppConfigManager.instance.accountItemViewMode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadBooks(UserConfigManager.currentUserId);
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
    final provider = context.read<ItemListProvider>();
    provider.loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: false,
        title: Consumer<BooksProvider>(
          builder: (context, provider, child) {
            final key = ValueKey('${provider.selectedBook?.id ?? ''}_${provider.books.length}');
            return BookSelector(
              key: key,
              userId: UserConfigManager.currentUserId,
              books: provider.books,
              selectedBook: provider.selectedBook,
              onSelected: (book) {
                provider.setSelectedBook(book);
              },
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == AccountItemViewMode.detail ? AccountItemViewMode.simple : AccountItemViewMode.detail;
                AppConfigManager.instance.setAccountItemViewMode(_viewMode);
              });
            },
            icon: Icon(
              _viewMode == AccountItemViewMode.detail ? Icons.view_list_outlined : Icons.view_headline_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: _viewMode == AccountItemViewMode.detail ? L10nManager.l10n.simpleView : L10nManager.l10n.detailView,
          ),
        ],
      ),
      body: Consumer3<BooksProvider, ItemListProvider, SyncProvider>(
        builder: (context, bookProvider, itemListProvider, syncProvider, child) {
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
                            child: ItemList(
                              accountBook: accountBook,
                              initialItems: itemListProvider.items,
                              loading: itemListProvider.loading,
                              hasMore: itemListProvider.hasMore,
                              useSimpleView: _viewMode == AccountItemViewMode.simple,
                              onLoadMore: () => itemListProvider.loadMore(),
                              onItemTap: (item) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.itemEdit,
                                  arguments: [accountBook, item],
                                ).then((updated) {
                                  if (updated == true) {
                                    itemListProvider.loadItems();
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
