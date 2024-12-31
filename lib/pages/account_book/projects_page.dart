import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants/constant.dart';
import '../../database/database.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_simple_crud_list.dart';
import '../../utils/date_util.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = AppConfigManager.instance.userId!;

    return CommonSimpleCrudList<AccountSymbol>(
      config: CommonSimpleCrudListConfig(
        title: l10n.project,
        getName: (item) => item.name,
        loadData: () => ServiceManager.accountSymbolService.getSymbolsByType(
          accountBook.id,
          SYMBOL_TYPE_PROJECT,
        ),
        createItem: (name, code, _) =>
            ServiceManager.accountSymbolService.createSymbol(
          name: name,
          code: code,
          accountBookId: accountBook.id,
          symbolType: SYMBOL_TYPE_PROJECT,
          createdBy: userId,
          updatedBy: userId,
        ),
        updateItem: (item, {required String name, String? type}) =>
            ServiceManager.accountSymbolService.updateSymbol(
          item.copyWith(
            name: name,
            updatedBy: userId,
            updatedAt: DateUtil.now(),
          ),
        ),
        deleteItem: (item) =>
            ServiceManager.accountSymbolService.deleteSymbol(item.id),
      ),
    );
  }
}
