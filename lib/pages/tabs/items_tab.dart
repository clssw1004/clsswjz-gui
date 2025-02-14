import 'package:clsswjz/providers/item_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/book/book_selector.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/book/items_container.dart';
import '../../widgets/book/debts_container.dart';
import '../../providers/debt_list_provider.dart';

/// 账目列表标签页
class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> with SingleTickerProviderStateMixin {
  late final AnimationController _fabController;
  bool _isFabExpanded = false;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadBooks(AppConfigManager.instance.userId);
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  Widget _buildFabItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
    Animation<double> animation,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ScaleTransition(
      scale: animation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          heroTag: label,
          elevation: 2,
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ItemListProvider>();
      provider.loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: Consumer3<BooksProvider, ItemListProvider, SyncProvider>(
        builder:
            (context, bookProvider, itemListProvider, syncProvider, child) {
          final accountBook = bookProvider.selectedBook;
          return Stack(
            children: [
              Column(
                children: [
                  ItemsContainer(
                    accountBook: accountBook,
                    items: itemListProvider.items.take(3).toList(),
                    loading: itemListProvider.loading,
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
                  DebtsContainer(
                    bookMeta: bookProvider.selectedBook,
                    loading: itemListProvider.loading,
                  ),
                ],
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<BooksProvider>(
        builder: (context, provider, child) {
          final accountBook = provider.selectedBook;
          if (accountBook == null) return const SizedBox.shrink();

          final fabScale = CurvedAnimation(
            parent: _fabController,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isFabExpanded) ...[                
                _buildFabItem(
                  context,
                  Icons.account_balance_wallet_outlined,
                  L10nManager.l10n.addNew(L10nManager.l10n.debt),
                  () {
                    _toggleFab();
                    Navigator.pushNamed(
                      context,
                      AppRoutes.debtAdd,
                      arguments: [accountBook],
                    ).then((added) {
                      if (added == true) {
                        context.read<ItemListProvider>().loadItems();
                        context.read<DebtListProvider>().loadDebts();
                      }
                    });
                  },
                  fabScale,
                ),
                _buildFabItem(
                  context,
                  Icons.add_circle_outline,
                  L10nManager.l10n.addNew(L10nManager.l10n.tabAccountItems),
                  () {
                    _toggleFab();
                    Navigator.pushNamed(
                      context,
                      AppRoutes.itemAdd,
                      arguments: [accountBook],
                    ).then((added) {
                      if (added == true) {
                        context.read<ItemListProvider>().loadItems();
                      }
                    });
                  },
                  fabScale,
                ),
              ],
              FloatingActionButton(
                onPressed: _toggleFab,
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isFabExpanded ? 0.125 : 0,
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
