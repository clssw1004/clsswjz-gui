import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/vo/account_item_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/account_item_form_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/account_item_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../theme/theme_spacing.dart';

class AccountItemFormPage extends StatelessWidget {
  final UserBookVO accountBook;
  final AccountItemVO? item;

  const AccountItemFormPage({
    super.key,
    required this.accountBook,
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return ChangeNotifierProvider(
      create: (context) => AccountItemFormProvider(accountBook, item),
      child: Consumer<AccountItemFormProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: CommonAppBar(
              title: Text(provider.isNew
                  ? l10n.addNew(l10n.tabAccountItems)
                  : l10n.editTo(l10n.tabAccountItems)),
            ),
            body: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: spacing.formPadding,
                      child: AccountItemForm(
                        provider: provider,
                        onSaved: () => Navigator.of(context).pop(true),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
