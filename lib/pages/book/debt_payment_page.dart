import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';
import '../../drivers/driver_factory.dart' show DriverFactory;
import '../../enums/account_type.dart';
import '../../enums/business_type.dart';
import '../../enums/debt_type.dart';
import '../../enums/operate_type.dart';
import '../../events/event_bus.dart';
import '../../events/special/event_book.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/dao_manager.dart';
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
    _fundId = widget.debt.fundId;
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
            dialogTheme: DialogTheme(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          ),
          child: child!,
        );
      },
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
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme,
              dialogTheme: DialogTheme(
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            child: child!,
          ),
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
      // 根据categoryCode调整金额的正负号
      // 借出(LEND)或还款(REPAYMENT)时为负数，反之为正数
      double amount = double.parse(_amountController.text);
      if (widget.categoryCode == DebtType.lend.code ||
          widget.categoryCode == DebtType.borrow.operationCategory) {
        amount = -amount.abs(); // 确保为负数
      } else {
        amount = amount.abs(); // 确保为正数
      }

      final result = await DriverFactory.driver.createItem(
          AppConfigManager.instance.userId, widget.book.id,
          amount: amount,
          categoryCode: widget.categoryCode,
          type: AccountItemType.transfer,
          description: _remarkController.text,
          fundId: _fundId,
          accountDate: '$_selectedDate $_selectedTime:00',
          source: BusinessType.debt.code,
          sourceId: widget.debt.id);

      if (result.ok) {
        final debt = await DaoManager.debtDao.findById(widget.debt.id);
        EventBus.instance.emit(DebtChangedEvent(OperateType.create, debt!));
        final item = await DaoManager.itemDao.findById(result.data!);
        EventBus.instance.emit(ItemChangedEvent(OperateType.create, item!));
      }
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
            tooltip: L10nManager.l10n.save,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: spacing.formPadding,
            children: [
              // 金额输入卡片
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing.formItemSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        L10nManager.l10n.amount,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: spacing.listItemSpacing),
                      // 金额
                      AmountInput(
                        controller: _amountController,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: spacing.formItemSpacing),

              // 账户和备注卡片
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing.formItemSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 账户选择
                      CommonSelectFormField<AccountFund>(
                        items: _accounts,
                        hint: L10nManager.l10n
                            .pleaseSelect(L10nManager.l10n.account),
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
                    ],
                  ),
                ),
              ),

              SizedBox(height: spacing.formItemSpacing),

              // 日期和时间卡片
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing.formItemSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoryCode == 'debt_repayment'
                            ? L10nManager.l10n.repaymentDate
                            : L10nManager.l10n.collectionDate,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: spacing.listItemSpacing),
                      // 日期和时间选择
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          spacing: spacing.listItemSpacing,
                          runSpacing: spacing.listItemSpacing,
                          alignment: WrapAlignment.start,
                          children: [
                            // 日期选择徽章
                            CommonBadge(
                              icon: Icons.calendar_today_outlined,
                              text: _selectedDate,
                              onTap: _selectDate,
                              borderColor: colorScheme.outline.withAlpha(51),
                              backgroundColor: colorScheme.surfaceContainerHigh
                                  .withAlpha(50),
                            ),
                            // 时间选择徽章
                            CommonBadge(
                              icon: Icons.access_time_outlined,
                              text: _selectedTime,
                              onTap: _selectTime,
                              borderColor: colorScheme.outline.withAlpha(51),
                              backgroundColor: colorScheme.surfaceContainerHigh
                                  .withAlpha(50),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: spacing.formGroupSpacing),

              // 保存按钮
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(L10nManager.l10n.save),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
