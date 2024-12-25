import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/account_items_provider.dart';
import '../../widgets/account_book_selector.dart';
import '../../widgets/account_item_list.dart';
import '../../widgets/common_app_bar.dart';

class AccountItemsTab extends StatelessWidget {
  const AccountItemsTab({super.key});
  // TODO: 这里暂时写死用户ID，后续需要从用户系统获取
  static const _userId = 'iy6dnir1k359j47yna16d538q88zqppn';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountItemsProvider(),
      child: const _AccountItemsTabView(),
    );
  }
}

class _AccountItemsTabView extends StatelessWidget {
  const _AccountItemsTabView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountItemsProvider>();

    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: false,
        title: AccountBookSelector(
          userId: AccountItemsTab._userId,
          selectedBook: provider.selectedBook,
          onSelected: provider.setSelectedBook,
        ),
      ),
      body: provider.selectedBook == null
          ? const SizedBox.shrink()
          : AccountItemList(
              accountBook: provider.selectedBook!,
              initialItems: provider.items,
              onItemTap: (item) {
                // TODO: 处理账目点击
                debugPrint('Tapped item: ${item.id}');
              },
            ),
    );
  }
}
