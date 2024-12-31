import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../database/database.dart';
import '../../enums/account_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_simple_crud_list.dart';
import '../../utils/date_util.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final userId = AppConfigManager.instance.userId!;

    return CommonSimpleCrudList<AccountCategory>(
      key: _listKey,
      config: CommonSimpleCrudListConfig(
        title: l10n.category,
        getName: (item) => item.name,
        loadData: () =>
            ServiceManager.accountCategoryService.getCategoriesByType(
          widget.accountBook.id,
          _selectedType,
        ),
        createItem: (name, code, _) =>
            ServiceManager.accountCategoryService.createCategory(
          name: name,
          code: code,
          accountBookId: widget.accountBook.id,
          categoryType: _selectedType,
          createdBy: userId,
        ),
        updateItem: (item, {required String name, String? type}) =>
            ServiceManager.accountCategoryService.updateCategory(
          item.copyWith(
            name: name,
            updatedBy: userId,
            updatedAt: DateUtil.now(),
          ),
        ),
        deleteItem: (item) =>
            ServiceManager.accountCategoryService.deleteCategory(item.id),
        filterWidget: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment<String>(
                  value: AccountItemType.expense.code,
                  label: Text(l10n.expense),
                ),
                ButtonSegment<String>(
                  value: AccountItemType.income.code,
                  label: Text(l10n.income),
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
