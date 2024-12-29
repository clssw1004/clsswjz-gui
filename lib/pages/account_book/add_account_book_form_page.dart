import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:clsswjz/manager/service_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants/account_book_icons.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/common_select_form_field.dart';

class AddAccountBookFormPage extends StatefulWidget {
  const AddAccountBookFormPage({super.key});

  @override
  State<AddAccountBookFormPage> createState() => _AddAccountBookFormPageState();
}

class _AddAccountBookFormPageState extends State<AddAccountBookFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _currency = 'CNY';
  IconData _icon = accountBookIcons[0];
  bool _isLoading = false;

  void _selectIcon() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectIcon),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: accountBookIcons.length,
              itemBuilder: (context, index) {
                final icon = accountBookIcons[index];
                return _buildIconItem(icon);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                MaterialLocalizations.of(context).cancelButtonLabel,
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconItem(IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = icon == _icon;

    return InkWell(
      onTap: () {
        setState(() => _icon = icon);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Icon(
          icon,
          color: selected ? colorScheme.primary : colorScheme.onSurface,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      final result = await ServiceManager.accountBookService.createAccountBook(
        name: _name,
        description: _description,
        userId: AppConfigManager.instance.userId!,
        currencySymbol: _currency,
        icon: _icon.codePoint.toString(),
      );

      if (mounted) {
        if (result.ok) {
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .saveFailed(result.message ?? '')),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.saveFailed(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(l10n.addNew(l10n.accountBook)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CommonTextFormField(
              labelText: '${l10n.accountBook}${l10n.name}',
              prefixIcon: InkWell(
                onTap: _selectIcon,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 48,
                  height: 48,
                  child: Icon(
                    _icon,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              required: true,
              onSaved: (value) => _name = value ?? '',
            ),
            const SizedBox(height: 16),
            CommonTextFormField(
              labelText: '${l10n.accountBook}${l10n.description}',
              prefixIcon: Icons.description,
              onChanged: (value) => _description = value,
              onSaved: (value) => _description = value ?? '',
            ),
            const SizedBox(height: 16),
            CommonSelectFormField<String>(
              items: const ['CNY', 'USD', 'EUR', 'GBP', 'JPY'],
              value: _currency,
              displayMode: DisplayMode.iconText,
              displayField: (item) => item,
              keyField: (item) => item,
              label: l10n.currency,
              icon: Icons.currency_exchange,
              required: true,
              onChanged: (value) => setState(() => _currency = value),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
