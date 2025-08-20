import 'package:flutter/material.dart';
import '../../enums/symbol_type.dart';
import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_simple_crud_list.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../routes/app_routes.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  Widget build(BuildContext context) {
    final userId = AppConfigManager.instance.userId;

    return CommonSimpleCrudList<AccountSymbol>(
      config: CommonSimpleCrudListConfig(
        title: L10nManager.l10n.tag,
        getName: (item) => item.name,
        loadData: () => DriverFactory.driver.listSymbolsByBook(
          userId,
          accountBook.id,
          symbolType: SymbolType.tag,
        ),
        createItem: (name, _) => DriverFactory.driver.createSymbol(userId, accountBook.id, name: name, symbolType: SymbolType.tag),
        updateItem: (item, {required String name, String? type}) => DriverFactory.driver.updateSymbol(
          userId,
          accountBook.id,
          item.id,
          name: name,
        ),
        deleteItem: (item) => DriverFactory.driver.deleteSymbol(
          userId,
          accountBook.id,
          item.id,
        ),
        onItemTap: (item) {
          final filter = ItemFilterDTO(tagCodes: [item.code]);
          Navigator.of(context).pushNamed(
            AppRoutes.items,
            arguments: [accountBook, filter, item.name],
          );
        },
      ),
    );
  }
}
