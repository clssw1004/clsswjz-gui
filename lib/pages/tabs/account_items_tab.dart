import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../manager/user_config_manager.dart';
import '../../providers/account_books_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/account_book_selector.dart';
import '../../widgets/account_item_list.dart';

/// 账目列表标签页
class AccountItemsTab extends StatelessWidget {
  const AccountItemsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AccountBooksProvider>(
      builder: (context, provider, child) {
        final accountBook = provider.selectedBook;
        return Column(
          children: [
            // 账本选择器
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  AccountBookSelector(
                    userId: UserConfigManager.currentUserId,
                    books: provider.books,
                    selectedBook: accountBook,
                    loading: provider.loadingBooks,
                    error: provider.error,
                    onSelected: (book) {
                      provider.setSelectedBook(book);
                    },
                  ),
                  const Spacer(),
                  if (accountBook != null)
                    IconButton(
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
                      icon: const Icon(Icons.add),
                      tooltip: l10n.addNew(l10n.accountItem),
                    ),
                ],
              ),
            ),

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
    );
  }
}
