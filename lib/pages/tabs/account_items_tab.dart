import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../manager/user_config_manager.dart';
import '../../providers/account_items_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/account_book_selector.dart';
import '../../widgets/account_item_list.dart';
import '../../widgets/common/common_app_bar.dart';
import '../account_book/account_item_form_page.dart';

class AccountItemsTab extends StatelessWidget {
  const AccountItemsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AccountItemsTabView();
  }
}

class _AccountItemsTabView extends StatefulWidget {
  const _AccountItemsTabView();

  @override
  State<_AccountItemsTabView> createState() => _AccountItemsTabViewState();
}

class _AccountItemsTabViewState extends State<_AccountItemsTabView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAccountBooks();
    });
  }

  Future<void> _checkAccountBooks() async {
    final provider = context.read<AccountItemsProvider>();
    await provider.init(UserConfigManager.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AccountItemsProvider>();
    final accountBook = provider.selectedBook;

    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: false,
        title: AccountBookSelector(
          userId: UserConfigManager.currentUserId,
          selectedBook: provider.selectedBook,
          onSelected: provider.setSelectedBook,
        ),
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : accountBook == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
              : Stack(
                  children: [
                    Consumer<AccountItemsProvider>(
                      builder: (context, provider, child) {
                        return AccountItemList(
                          accountBook: accountBook,
                          initialItems: provider.items,
                          onItemTap: (item) async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AccountItemFormPage(
                                  accountBook: accountBook,
                                  item: item,
                                ),
                              ),
                            );
                            if (result == true) {
                              provider.refresh();
                            }
                          },
                        );
                      },
                    ),
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AccountItemFormPage(
                                accountBook: accountBook,
                              ),
                            ),
                          );
                          if (result == true) {
                            provider.refresh();
                          }
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
    );
  }
}
