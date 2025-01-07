import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../manager/user_config_manager.dart';
import '../../providers/account_books_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/account_book_selector.dart';
import '../../widgets/account_item_list.dart';
import '../../widgets/common/common_app_bar.dart';

/// 账目列表标签页
class AccountItemsTab extends StatefulWidget {
  const AccountItemsTab({super.key});

  @override
  State<AccountItemsTab> createState() => _AccountItemsTabState();
}

class _AccountItemsTabState extends State<AccountItemsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AccountBooksProvider>()
          .loadBooks(UserConfigManager.currentUserId);
    });
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
      body: Consumer<AccountBooksProvider>(
        builder: (context, provider, child) {
          final accountBook = provider.selectedBook;
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
                                  await provider
                                      .init(UserConfigManager.currentUserId);
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: Text(l10n.addNew(l10n.accountBook)),
                            ),
                          ],
                        ),
                      )
                    : AccountItemList(
                        accountBook: accountBook,
                        initialItems: provider.items,
                        loading: provider.loadingItems,
                        onRefresh: () => provider.loadItems(),
                        onItemTap: (item) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.accountItemForm,
                            arguments: [accountBook, item],
                          ).then((updated) {
                            if (updated == true) {
                              provider.loadItems();
                            }
                          });
                        },
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
                AppRoutes.accountItemForm,
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
