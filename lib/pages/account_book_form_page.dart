import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/common/common_app_bar.dart';
import '../widgets/common/common_text_form_field.dart';
import '../widgets/common/common_select_form_field.dart';

class AccountBookFormPage extends StatefulWidget {
  const AccountBookFormPage({super.key});

  @override
  State<AccountBookFormPage> createState() => _AccountBookFormPageState();
}

class _AccountBookFormPageState extends State<AccountBookFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _currency = 'CNY';
  IconData _icon = Icons.account_balance_wallet;
  bool _isLoading = false;

  void _selectIcon() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectIcon),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                Icons.account_balance_wallet,
                Icons.savings,
                Icons.credit_card,
                Icons.monetization_on,
                Icons.currency_exchange,
                Icons.account_balance,
                Icons.payments,
                Icons.receipt_long,
              ].map((icon) => _buildIconItem(icon)).toList(),
            ),
          ),
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

    setState(() => _isLoading = true);
    try {
      // TODO: 实现创建账本逻辑
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      setState(() => _isLoading = false);
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: _selectIcon,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Icon(
                      _icon,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CommonTextFormField(
                    labelText: '${l10n.accountBook}${l10n.name}',
                    prefixIcon: const Icon(Icons.edit),
                    required: true,
                    onChanged: (value) => _name = value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CommonTextFormField(
              labelText: '${l10n.accountBook}${l10n.description}',
              prefixIcon: const Icon(Icons.description),
              onChanged: (value) => _description = value,
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