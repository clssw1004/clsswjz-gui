import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/user_config_manager.dart';
import '../../providers/account_books_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/account_book_selector.dart';
import '../../widgets/account_item_list.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../enums/account_item_view_mode.dart';

/// 账目列表标签页
class AccountItemsTab extends StatefulWidget {
  const AccountItemsTab({super.key});

  @override
  State<AccountItemsTab> createState() => _AccountItemsTabState();
}

class _AccountItemsTabState extends State<AccountItemsTab> {
  bool _isRefreshing = false;
  AccountItemViewMode _viewMode = AppConfigManager.instance.accountItemViewMode;

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
            final key = ValueKey('${provider.selectedBook?.id ?? ''}_${provider.books.length}');
            return AccountBookSelector(
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
                            child: AccountItemList(
                              accountBook: accountBook,
                              initialItems: bookProvider.items,
                              loading: bookProvider.loadingItems,
                              hasMore: bookProvider.hasMore,
                              useSimpleView: _viewMode == AccountItemViewMode.simple,
                              onLoadMore: () => bookProvider.loadMore(),
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
