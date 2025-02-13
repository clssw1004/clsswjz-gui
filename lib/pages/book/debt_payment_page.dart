import 'package:clsswjz/drivers/driver_factory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';
import '../../enums/account_type.dart';
import '../../enums/debt_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/book/amount_input.dart';
import '../../theme/theme_spacing.dart';

class DebtPaymentPage extends StatefulWidget {
  final BookMetaVO book;
  final AccountDebt debt;

  const DebtPaymentPage({
    super.key,
    required this.book,
    required this.debt,
  });

  @override
  State<DebtPaymentPage> createState() => _DebtPaymentPageState();
}

class _DebtPaymentPageState extends State<DebtPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '0.00');
  final _remarkController = TextEditingController();
  final _paymentDateController = TextEditingController();
  String? _selectedAccountId;
  bool _saving = false;
  late String _paymentDate;

  List<AccountFund> get _accounts => widget.book.funds ?? [];
  DebtType get _debtType => DebtType.fromCode(widget.debt.debtType);

  @override
  void initState() {
    super.initState();
    // 初始化日期为当前日期
    _paymentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _paymentDateController.text = _paymentDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    _paymentDateController.dispose();
    super.dispose();
  }

  /// 选择日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_paymentDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _paymentDate = DateFormat('yyyy-MM-dd').format(picked);
        _paymentDateController.text = _paymentDate;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      DriverFactory.driver.createItem(
          AppConfigManager.instance.userId, widget.book.id,
          amount: double.parse(_amountController.text),
          categoryCode: _debtType.operationCategory,
          type: AccountItemType.transfer,
          description: _remarkController.text,
          accountDate: '$_paymentDate 00:00:00');
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(_debtType == DebtType.lend
            ? L10nManager.l10n.collection
            : L10nManager.l10n.repayment),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onSurface,
                    ),
                  )
                : const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: spacing.formPadding,
          children: [
            // 金额
            Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  setState(() {});
                }
              },
              child: AmountInput(
                controller: _amountController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            SizedBox(height: spacing.formItemSpacing),

            // 账户选择
            CommonSelectFormField<AccountFund>(
              items: _accounts,
              hint: L10nManager.l10n.pleaseSelect(L10nManager.l10n.account),
              value: _selectedAccountId,
              displayMode: DisplayMode.iconText,
              displayField: (item) => item.name,
              keyField: (item) => item.id,
              icon: Icons.account_balance_wallet_outlined,
              label: L10nManager.l10n.account,
              required: true,
              onChanged: (value) {
                final account = value as AccountFund?;
                if (account != null) {
                  setState(() {
                    _selectedAccountId = account.id;
                  });
                } else {
                  setState(() {
                    _selectedAccountId = null;
                  });
                }
              },
              validator: (value) {
                if (value == null) {
                  return L10nManager.l10n.required;
                }
                return null;
              },
            ),

            SizedBox(height: spacing.formItemSpacing),
            // 日期选择
            InkWell(
              onTap: _selectDate,
              child: CommonTextFormField(
                controller: _paymentDateController,
                labelText: _debtType == DebtType.lend
                    ? L10nManager.l10n.collectionDate
                    : L10nManager.l10n.repaymentDate,
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                readOnly: true,
                enabled: false,
              ),
            ),
            SizedBox(height: spacing.formItemSpacing),
            // 备注
            CommonTextFormField(
              controller: _remarkController,
              labelText: L10nManager.l10n.remark,
              prefixIcon: const Icon(Icons.note_outlined),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
