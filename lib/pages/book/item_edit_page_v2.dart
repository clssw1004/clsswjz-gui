import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/account_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_item_vo.dart';
import '../../providers/item_form_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/navigation_util.dart';
import '../../widgets/common/common_app_bar.dart';
import 'modern_item_form.dart';

class ItemEditPageV2 extends StatelessWidget {
  final BookMetaVO bookMeta;
  final UserItemVO item;

  const ItemEditPageV2({
    super.key,
    required this.bookMeta,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;

    return ChangeNotifierProvider(
      create: (context) => ItemFormProvider(bookMeta, item),
      child: Consumer<ItemFormProvider>(
        builder: (context, provider, child) {
          final isExpense =
              provider.item.type == AccountItemType.expense.code;

          return Scaffold(
            appBar: CommonAppBar(
              title: Text(
                  L10nManager.l10n.editTo(L10nManager.l10n.tabAccountItems)),
              actions: [
                if (isExpense)
                  IconButton(
                    icon: const Icon(Icons.currency_exchange),
                    tooltip: L10nManager.l10n.refund,
                    onPressed: () => _navigateToRefundPage(context),
                  ),
              ],
            ),
            body: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: spacing.formPadding,
                    child: ModernItemForm(
                      provider: provider,
                      autoSave: true,
                    ),
                  ),
          );
        },
      ),
    );
  }

  void _navigateToRefundPage(BuildContext context) async {
    final result = await NavigationUtil.toItemRefund(context, item);
    if (result && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}
