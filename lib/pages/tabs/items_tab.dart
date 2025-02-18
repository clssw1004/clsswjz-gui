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

class _ItemsTabState extends State<ItemsTab>
    with SingleTickerProviderStateMixin {
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
    );
  }
}
