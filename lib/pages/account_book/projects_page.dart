import 'package:flutter/material.dart';
import '../../enums/symbol_type.dart';
import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_simple_crud_list.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  Widget build(BuildContext context) {
    final userId = AppConfigManager.instance.userId!;

    return CommonSimpleCrudList<AccountSymbol>(
      config: CommonSimpleCrudListConfig(
        title: L10nManager.l10n.project,
        getName: (item) => item.name,
        loadData: () => ServiceManager.accountSymbolService.getSymbolsByType(
          accountBook.id,
          SymbolType.project.name,
        ),
        createItem: (name, _) => DriverFactory.driver.createSymbol(
          userId,
          accountBook.id,
          name: name,
          symbolType: SymbolType.project,
        ),
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
      ),
    );
  }
}
