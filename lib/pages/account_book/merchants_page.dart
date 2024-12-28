import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../database/database.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_list_page.dart';

class MerchantsPage extends StatelessWidget {
  const MerchantsPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userId = AppConfigManager.instance.userId!;
    
    return CommonListPage<AccountShop>(
      config: CommonListConfig(
        title: l10n.merchant,
        getName: (item) => item.name,
        loadData: () => ServiceManager.accountShopService.getShopsByAccountBook(accountBook.id),
        createItem: (name, code, _) => ServiceManager.accountShopService.createShop(
          name: name,
          code: code,
          accountBookId: accountBook.id,
          createdBy: userId,
          updatedBy: userId,
        ),
        updateItem: (item, {required String name, String? type}) => 
          ServiceManager.accountShopService.updateShop(
            item.copyWith(
              name: name,
              updatedBy: userId,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          ),
        deleteItem: (item) => ServiceManager.accountShopService.deleteShop(item.id),
      ),
    );
  }
} 