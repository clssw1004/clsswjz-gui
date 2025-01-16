import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_simple_crud_list.dart';

class MerchantsPage extends StatelessWidget {
  const MerchantsPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  Widget build(BuildContext context) {
    final userId = AppConfigManager.instance.userId!;

    return CommonSimpleCrudList<AccountShop>(
      config: CommonSimpleCrudListConfig(
        title: L10nManager.l10n.merchant,
        getName: (item) => item.name,
        loadData: () => DriverFactory.driver.listShopsByBook(userId, accountBook.id),
        createItem: (name, _) => DriverFactory.driver.createShop(userId, accountBook.id, name: name),
        updateItem: (item, {required String name, String? type}) => DriverFactory.driver.updateShop(
          userId,
          accountBook.id,
          item.id,
          name: name,
        ),
        deleteItem: (item) => DriverFactory.driver.deleteShop(
          userId,
          accountBook.id,
          item.id,
        ),
      ),
    );
  }
}
