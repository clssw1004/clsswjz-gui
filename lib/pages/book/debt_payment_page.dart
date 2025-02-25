import 'package:clsswjz/drivers/driver_factory.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';
import '../../enums/account_type.dart';
import '../../enums/business_type.dart';
import '../../enums/debt_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_debt_vo.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/book/amount_input.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_badge.dart';

class DebtPaymentPage extends StatefulWidget {
  final BookMetaVO book;
  final UserDebtVO debt;
  final String categoryCode;
  final String title;

  const DebtPaymentPage({
    super.key,
    required this.title,
    required this.book,
    required this.debt,
    required this.categoryCode,
  });

  @override
  State<DebtPaymentPage> createState() => _DebtPaymentPageState();
}

class _DebtPaymentPageState extends State<DebtPaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '0.00');
  final _remarkController = TextEditingController();
  String? _fundId;
  bool _saving = false;
  late String _selectedDate;
  late String _selectedTime;

  List<AccountFund> get _accounts => widget.book.funds ?? [];

  @override
  void initState() {
    super.initState();
    // 初始化日期和时间为当前时间
    final now = DateTime.now();
    _selectedDate = DateFormat('yyyy-MM-dd').format(now);
    _selectedTime = DateFormat('HH:mm').format(now);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
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

  /// 选择时间
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      initialTime: TimeOfDay.fromDateTime(
        DateTime.parse('2024-01-01 $_selectedTime:00'),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = '${picked.hour.toString().padLeft(2, '0')}:'
            '${picked.minute.toString().padLeft(2, '0')}';
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
          categoryCode: widget.categoryCode,
          type: AccountItemType.transfer,
          description: _remarkController.text,
          fundId: _fundId,
          accountDate: '$_selectedDate $_selectedTime:00',
          source: BusinessType.debt.code,
          sourceId: widget.debt.id);
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
        title: Text(widget.title),
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
            AmountInput(
              controller: _amountController,
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: spacing.formItemSpacing),

            // 账户选择
            CommonSelectFormField<AccountFund>(
              items: _accounts,
              hint: L10nManager.l10n.pleaseSelect(L10nManager.l10n.account),
              value: _fundId,
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
                    _fundId = account.id;
                  });
                } else {
                  setState(() {
                    _fundId = null;
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
            // 备注
            CommonTextFormField(
              controller: _remarkController,
              labelText: L10nManager.l10n.remark,
              prefixIcon: const Icon(Icons.note_outlined),
              maxLines: 3,
            ),
            SizedBox(height: spacing.formItemSpacing),

            // 日期和时间选择
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.start,
                children: [
                  // 日期选择徽章
                  CommonBadge(
                    icon: Icons.calendar_today_outlined,
                    text: _selectedDate,
                    onTap: _selectDate,
                    borderColor: colorScheme.outline.withAlpha(51),
                  ),
                  // 时间选择徽章
                  CommonBadge(
                    icon: Icons.access_time_outlined,
                    text: _selectedTime,
                    onTap: _selectTime,
                    borderColor: colorScheme.outline.withAlpha(51),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
