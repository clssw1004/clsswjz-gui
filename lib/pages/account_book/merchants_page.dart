import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_simple_crud_list.dart';
import '../../utils/date_util.dart';

class MerchantsPage extends StatelessWidget {
  const MerchantsPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = AppConfigManager.instance.userId!;

    return CommonSimpleCrudList<AccountShop>(
      config: CommonSimpleCrudListConfig(
        title: l10n.merchant,
        getName: (item) => item.name,
        loadData: () => ServiceManager.accountShopService
            .getShopsByAccountBook(accountBook.id),
        createItem: (name, _) => DriverFactory.driver
            .createBookShop(userId, accountBook.id, name: name),
        updateItem: (item, {required String name, String? type}) =>
            DriverFactory.driver.updateBookShop(
          userId,
          accountBook.id,
          item.id,
          name: name,
        ),
        deleteItem: (item) => DriverFactory.driver.deleteBookShop(
          userId,
          accountBook.id,
          item.id,
        ),
      ),
    );
  }
}
