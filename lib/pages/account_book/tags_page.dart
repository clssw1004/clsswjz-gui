import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants/constant.dart';
import '../../database/database.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_list_page.dart';

class TagsPage extends StatelessWidget {
  const TagsPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = AppConfigManager.instance.userId!;
    
    return CommonListPage<AccountSymbol>(
      config: CommonListConfig(
        title: l10n.tag,
        getName: (item) => item.name,
        loadData: () => ServiceManager.accountSymbolService.getSymbolsByType(
          accountBook.id,
          SYMBOL_TYPE_TAG,
        ),
        createItem: (name, code, _) => ServiceManager.accountSymbolService.createSymbol(
          name: name,
          code: code,
          accountBookId: accountBook.id,
          symbolType: SYMBOL_TYPE_TAG,
          createdBy: userId,
          updatedBy: userId,
        ),
        updateItem: (item, {required String name, String? type}) => 
          ServiceManager.accountSymbolService.updateSymbol(
            item.copyWith(
              name: name,
              updatedBy: userId,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          ),
        deleteItem: (item) => ServiceManager.accountSymbolService.deleteSymbol(item.id),
      ),
    );
  }
} 