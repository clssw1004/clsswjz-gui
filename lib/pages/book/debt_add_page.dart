import 'package:clsswjz/drivers/driver_factory.dart';
import 'package:clsswjz/manager/app_config_manager.dart';
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

class DebtAddPage extends StatefulWidget {
  final BookMetaVO book;
  final String? debtor;

  const DebtAddPage({
    super.key,
    required this.book,
    this.debtor,
  });

  @override
  State<DebtAddPage> createState() => _DebtAddPageState();
}

class _DebtAddPageState extends State<DebtAddPage> {
  final _formKey = GlobalKey<FormState>();
  final _debtorController = TextEditingController();
  final _amountController = TextEditingController(text: '0.00');
  final _debtDateController = TextEditingController();
  final _expectedClearDateController = TextEditingController();
  DebtType _debtType = DebtType.lend;
  String? _selectedAccountId;
  bool _saving = false;
  late String _debtDate;
  String? _expectedClearDate;

  List<AccountFund> get _accounts => widget.book.funds ?? [];

  @override
  void initState() {
    super.initState();
    // 初始化日期为当前日期
    _debtDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _debtDateController.text = _debtDate;
    // 如果传入了债务人，则初始化债务人文本控制器
    if (widget.debtor != null) {
      _debtorController.text = widget.debtor!;
    }
  }

  @override
  void dispose() {
    _debtorController.dispose();
    _amountController.dispose();
    _debtDateController.dispose();
    _expectedClearDateController.dispose();
    super.dispose();
  }

  /// 选择日期
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateFormat('yyyy-MM-dd').parse(_debtDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _debtDate = DateFormat('yyyy-MM-dd').format(picked);
        _debtDateController.text = _debtDate;
      });
    }
  }

  /// 选择预计结清日期
  Future<void> _selectExpectedClearDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedClearDate != null
          ? DateFormat('yyyy-MM-dd').parse(_expectedClearDate!)
          : DateFormat('yyyy-MM-dd').parse(_debtDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _expectedClearDate = DateFormat('yyyy-MM-dd').format(picked);
        _expectedClearDateController.text = _expectedClearDate ?? '';
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
      await DriverFactory.driver.createDebt(
        AppConfigManager.instance.userId,
        widget.book.id,
        debtor: _debtorController.text,
        debtType: _debtType,
        amount: double.parse(_amountController.text),
        fundId: _selectedAccountId!,
        debtDate: _debtDate,
        expectedClearDate: _expectedClearDate,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.addNew(L10nManager.l10n.debt)),
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
            // 债务类型选择
            CommonSegmentedButton<DebtType>(
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
              onSelectionChanged: (Set<DebtType> selected) {
                setState(() {
                  _debtType = selected.first;
                });
              },
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
            // 债务人
            CommonTextFormField(
              controller: _debtorController,
              labelText: L10nManager.l10n.debtor,
              hintText: L10nManager.l10n.debtorHint,
              prefixIcon: const Icon(Icons.person_outline),
              required: true,
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
                controller: _debtDateController,
                labelText: L10nManager.l10n.debtDate,
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                readOnly: true,
                enabled: false,
              ),
            ),
            SizedBox(height: spacing.formItemSpacing),
            InkWell(
              onTap: _selectExpectedClearDate,
              child: CommonTextFormField(
                controller: _expectedClearDateController,
                labelText: L10nManager.l10n.expectedClearDate,
                prefixIcon: const Icon(Icons.event_available_outlined),
                readOnly: true,
                enabled: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
