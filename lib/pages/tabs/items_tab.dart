import 'package:clsswjz/providers/item_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/app_config_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/book/book_selector.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/book/items_container.dart';
import '../../widgets/book/debts_container.dart';

/// 账目列表标签页
class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadBooks(AppConfigManager.instance.userId);
    });
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
                    accountBook: accountBook,
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
          return FloatingActionButton(
            onPressed: () {
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
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
