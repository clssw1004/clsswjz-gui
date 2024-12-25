import 'package:flutter/material.dart';

import '../../widgets/account_book_selector.dart';
import '../../widgets/common_app_bar.dart';

class AccountItemsTab extends StatelessWidget {
  const AccountItemsTab({super.key});
  // TODO: 这里暂时写死用户ID，后续需要从用户系统获取
  static const _userId = 'iy6dnir1k359j47yna16d538q88zqppn';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: false,
        title: AccountBookSelector(
          userId: _userId,
          onSelected: (book) {
            // TODO: 处理账本选择
            debugPrint('Selected book: ${book.name}');
          },
        ),
      ),
      body: const Center(
        child: Text('账目列表'),
      ),
    );
  }
}
