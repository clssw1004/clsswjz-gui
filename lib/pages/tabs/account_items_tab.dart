import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/user_config_manager.dart';
import '../../providers/account_items_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/account_book_selector.dart';
import '../../widgets/account_item_list.dart';
import '../../widgets/common/common_app_bar.dart';

class AccountItemsTab extends StatelessWidget {
  const AccountItemsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountItemsProvider(),
      child: const _AccountItemsTabView(),
    );
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
    if (provider.selectedBook == null) {
      final result = await Navigator.pushNamed(
        context,
        AppRoutes.accountBookForm,
      );
      if (result == true) {
        provider.refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountItemsProvider>();

    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: false,
        title: AccountBookSelector(
          userId: UserConfigManager.currentUserId,
          selectedBook: provider.selectedBook,
          onSelected: provider.setSelectedBook,
        ),
      ),
      body: provider.selectedBook == null
          ? const SizedBox.shrink()
          : AccountItemList(
              accountBook: provider.selectedBook!,
              initialItems: provider.items,
              onItemTap: (item) async {
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.accountItemForm,
                  arguments: [
                    provider.selectedBook!,
                    item,
                  ],
                );
                if (result == true) {
                  provider.refresh();
                }
              },
            ),
    );
  }
}
