import 'package:clsswjz/drivers/driver_factory.dart';
import 'package:flutter/material.dart';
import '../../database/database.dart';
import '../../enums/account_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_simple_crud_list.dart';

class AccountCategoriesPage extends StatefulWidget {
  const AccountCategoriesPage({super.key, required this.accountBook});
  final UserBookVO accountBook;

  @override
  State<AccountCategoriesPage> createState() => _AccountCategoriesPageState();
}

class _AccountCategoriesPageState extends State<AccountCategoriesPage> {
  String _selectedType = AccountItemType.expense.code;
  final _listKey = GlobalKey<CommonSimpleCrudListState<AccountCategory>>();

  @override
  Widget build(BuildContext context) {
    final userId = AppConfigManager.instance.userId!;

    return CommonSimpleCrudList<AccountCategory>(
      key: _listKey,
      config: CommonSimpleCrudListConfig(
        title: L10nManager.l10n.category,
        getName: (item) => item.name,
        loadData: () => DriverFactory.driver.listCategoriesByBook(
          userId,
          widget.accountBook.id,
          categoryType: _selectedType,
        ),
        createItem: (name, _) => DriverFactory.driver.createCategory(
          userId,
          widget.accountBook.id,
          name: name,
          categoryType: _selectedType,
        ),
        updateItem: (item, {required String name, String? type}) => DriverFactory.driver.updateCategory(
          userId,
          widget.accountBook.id,
          item.id,
          name: name,
        ),
        deleteItem: (item) => DriverFactory.driver.deleteCategory(
          userId,
          widget.accountBook.id,
          item.id,
        ),
        filterWidget: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: AccountItemType.expense.code,
                  label: Text(L10nManager.l10n.expense),
                ),
                ButtonSegment<String>(
                  value: AccountItemType.income.code,
                  label: Text(L10nManager.l10n.income),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                });
                _listKey.currentState?.refresh();
              },
            ),
          ),
        ),
      ),
    );
  }
}
