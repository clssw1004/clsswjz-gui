import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_item_vo.dart';
import '../../providers/item_form_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_app_bar.dart';
import 'modern_item_form.dart';

class ItemAddPageV2 extends StatelessWidget {
  final BookMetaVO bookMeta;
  final UserItemVO? item;

  const ItemAddPageV2({
    super.key,
    required this.bookMeta,
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;

    return ChangeNotifierProvider(
      create: (context) => ItemFormProvider(bookMeta, item),
      child: Consumer<ItemFormProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: CommonAppBar(
              title: Text(provider.isNew
                  ? L10nManager.l10n.addNew(L10nManager.l10n.tabAccountItems)
                  : L10nManager.l10n.editTo(L10nManager.l10n.tabAccountItems)),
            ),
            body: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: spacing.formPadding,
                    child: ModernItemForm(
                      provider: provider,
                      autoFocusAmount: provider.isNew,
                      onSaved: () => Navigator.of(context).pop(true),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
