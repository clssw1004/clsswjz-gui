import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../manager/user_config_manager.dart';
import '../../providers/account_books_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/account_book_selector.dart';
import '../../widgets/account_item_list_tile.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../models/vo/account_item_vo.dart';
import '../../models/vo/user_book_vo.dart';

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
      setState(() => _isRefreshing = false);
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
    final l10n = AppLocalizations.of(context)!;

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
          return Column(
            children: [
              // 账目列表
              Expanded(
                child: accountBook == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(l10n.noAccountBooks),
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
                              label: Text(l10n.addNew(l10n.accountBook)),
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
                              bookProvider.loadItems();
                            });
                          },
                        ),
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
              ).then((created) {
                if (created == true) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (widget.loading && (_items == null || _items!.isEmpty)) {
      return Center(child: Text(l10n.loading));
    }

    if (_items == null || _items!.isEmpty) {
      return Center(
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
              l10n.noAccountItems,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _items!.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _items![index];
        return InkWell(
          onTap: widget.onItemTap == null ? null : () => widget.onItemTap!(item),
          child: AccountItemListTile(
            item: item,
            currencySymbol: widget.accountBook.currencySymbol.symbol,
          ),
        );
      },
    );
  }
}
