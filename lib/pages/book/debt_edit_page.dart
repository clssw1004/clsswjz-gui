import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';
import '../../enums/debt_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/common_segmented_button.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_badge.dart';
import '../../widgets/book/amount_input.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';
import '../../utils/color_util.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';

class DebtEditPage extends StatefulWidget {
  final BookMetaVO book;
  final AccountDebt debt;

  const DebtEditPage({
    super.key,
    required this.book,
    required this.debt,
  });

  @override
  State<DebtEditPage> createState() => _DebtEditPageState();
}

class _DebtEditPageState extends State<DebtEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _debtorController = TextEditingController();
  final _amountController = TextEditingController();
  late DebtType _debtType;
  String? _selectedAccountId;
  bool _saving = false;
  late String _selectedDate;

  List<AccountFund> get _accounts => widget.book.funds ?? [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _debtType = DebtType.fromCode(widget.debt.debtType);
    _debtorController.text = widget.debt.debtor;
    _amountController.text = widget.debt.amount.toString();
    _selectedAccountId = widget.debt.fundId;
    _selectedDate = widget.debt.debtDate;
  }

  @override
  void dispose() {
    _debtorController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// 选择日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_selectedDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
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
      await DriverFactory.driver.updateDebt(
        AppConfigManager.instance.userId,
        widget.book.id,
        widget.debt.id,
        debtor: _debtorController.text,
        amount: double.parse(_amountController.text),
        fundId: _selectedAccountId!,
        debtDate: _selectedDate,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10nManager.l10n.warning),
        content:
            Text(L10nManager.l10n.deleteConfirmMessage(widget.debt.debtor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L10nManager.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(L10nManager.l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _saving = true;
    });

    try {
      final result = await DriverFactory.driver.deleteDebt(
        AppConfigManager.instance.userId,
        widget.book.id,
        widget.debt.id,
      );
      if (result.ok) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ToastUtil.showError(result.message ??
              L10nManager.l10n.deleteFailed(L10nManager.l10n.debt, ''));
        }
      }
    } finally {
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
        title: Text(L10nManager.l10n.editTo(L10nManager.l10n.debt)),
        actions: [
          IconButton(
            onPressed: _saving ? null : _delete,
            icon: Icon(
              Icons.delete_outline,
              color: colorScheme.error,
            ),
          ),
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
            // 债务类型选择
            AbsorbPointer(
              child: CommonSegmentedButton<DebtType>(
                segments: [
                  ButtonSegment<DebtType>(
                    value: DebtType.lend,
                    label: Text(L10nManager.l10n.lend),
                    icon: const Icon(Icons.arrow_circle_up_outlined),
                  ),
                  ButtonSegment<DebtType>(
                    value: DebtType.borrow,
                    label: Text(L10nManager.l10n.borrow),
                    icon: const Icon(Icons.arrow_circle_down_outlined),
                  ),
                ],
                selected: {_debtType},
                onSelectionChanged: (_) {},
              ),
            ),
            SizedBox(height: spacing.formItemSpacing),
            // 债务人
            CommonTextFormField(
              controller: _debtorController,
              labelText: L10nManager.l10n.debtor,
              hintText: L10nManager.l10n.debtorHint,
              prefixIcon: const Icon(Icons.person_outline),
              required: true,
              maxLength: 50,
              enabled: false,
            ),
            SizedBox(height: spacing.formItemSpacing),
            // 账户选择
            AbsorbPointer(
              child: CommonSelectFormField<AccountFund>(
                items: _accounts,
                value: _selectedAccountId,
                displayMode: DisplayMode.iconText,
                displayField: (item) => item.name,
                keyField: (item) => item.id,
                icon: Icons.account_balance_wallet_outlined,
                label: L10nManager.l10n.account,
                required: true,
                onChanged: (_) {},
                validator: (value) {
                  if (value == null) {
                    return L10nManager.l10n.required;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: spacing.formItemSpacing),
            // 金额
            Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) {
                  setState(() {});
                }
              },
              child: AmountInput(
                controller: _amountController,
                color: ColorUtil.getDebtAmountColor(_debtType),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            SizedBox(height: spacing.formItemSpacing),
            // 日期选择
            Row(
              children: [
                CommonBadge(
                  icon: Icons.calendar_today_outlined,
                  text: _selectedDate,
                  onTap: _selectDate,
                  borderColor: colorScheme.outline.withAlpha(51),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
