import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../drivers/driver_factory.dart';
import '../../enums/account_type.dart';
import '../../enums/business_type.dart';
import '../../enums/operate_type.dart';
import '../../events/event_bus.dart';
import '../../events/special/event_book.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/dao_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/color_util.dart';
import '../../widgets/book/amount_input.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_badge.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_text_form_field.dart';

class RefundFormPage extends StatefulWidget {
  final BookMetaVO bookMeta;
  final UserItemVO originalItem;

  const RefundFormPage({
    super.key,
    required this.bookMeta,
    required this.originalItem,
  });

  @override
  State<RefundFormPage> createState() => _RefundFormPageState();
}

class _RefundFormPageState extends State<RefundFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocusNode = FocusNode();
  late String _selectedDate;
  late String _selectedTime;
  String? _selectedFundId;
  late List<UserFundVO> _funds = [];

  @override
  void initState() {
    super.initState();

    // 初始化金额为原始账目的金额（正数）
    final originalAmount = widget.originalItem.amount.abs();
    _amountController.text = originalAmount.toString();

    // 初始化描述为"退款: " + 原始描述
    final originalDesc = widget.originalItem.description ?? '';
    final refundDesc = '${L10nManager.l10n.refund}: $originalDesc';
    _descriptionController.text = refundDesc;

    // 初始化账户
    _selectedFundId = widget.originalItem.fundId;

    // 初始化日期和时间为当前时间
    final now = DateTime.now();
    _selectedDate = DateFormat('yyyy-MM-dd').format(now);
    _selectedTime = DateFormat('HH:mm').format(now);

    // 从bookMeta中获取funds列表并转换为UserFundVO
    _initFunds();

    // 延迟一帧后弹出金额输入
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _amountController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _amountController.text.length,
        );
        FocusScope.of(context).requestFocus(_amountFocusNode);
      }
    });
  }

  void _initFunds() {
    if (widget.bookMeta.funds != null) {
      _funds = widget.bookMeta.funds!
          .map((fund) => UserFundVO.fromFundAndBooks(fund))
          .toList();
    }
  }

  /// 保存退款记录
  Future<void> _saveRefund() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // 获取表单数据
        final amount = double.tryParse(_amountController.text) ?? 0.0;
        final description = _descriptionController.text;
        final accountDate = '$_selectedDate $_selectedTime:00';

        // 创建退款记录（收入类型）
        final result = await DriverFactory.driver.createItem(
          AppConfigManager.instance.userId,
          widget.bookMeta.id,
          amount: amount, // 使用表单中输入的金额（正数）
          description: description, // 使用表单中输入的描述
          type: AccountItemType.income, // 退款是收入类型
          categoryCode: widget.originalItem.categoryCode, // 使用原始账目的分类
          accountDate: accountDate, // 使用表单中选择的日期和时间
          fundId: _selectedFundId, // 使用表单中选择的账户
          shopCode: widget.originalItem.shopCode, // 使用原始账目的商家
          tagCode: widget.originalItem.tagCode, // 使用原始账目的标签
          projectCode: widget.originalItem.projectCode, // 使用原始账目的项目
          source: BusinessType.item.code, // 来源类型为账目
          sourceId: widget.originalItem.id, // 来源ID为原始账目ID
        );

        if (result.ok && mounted) {
          final item = await DaoManager.itemDao.findById(result.data!);
          EventBus.instance.emit(ItemChangedEvent(OperateType.create, item!));
          // 保存成功，返回
          Navigator.of(context).pop(true);
        } else {
          // 保存失败，显示错误信息
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(result.message ?? L10nManager.l10n.saveFailed(''))),
            );
          }
        }
      } catch (e) {
        // 发生异常，显示错误信息
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(L10nManager.l10n.saveFailed(e.toString()))),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.refund),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _saveRefund,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: spacing.formPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 金额输入
                AmountInput(
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  color: ColorUtil.INCOME,
                  onChanged: (value) {
                    // 不需要任何操作
                  },
                ),
                SizedBox(height: spacing.formItemSpacing),

                // 账户选择
                CommonSelectFormField<UserFundVO>(
                  items: _funds,
                  value: _selectedFundId,
                  allowCreate: false,
                  displayMode: DisplayMode.iconText,
                  displayField: (item) => item.name,
                  keyField: (item) => item.id,
                  icon: Icons.account_balance_wallet_outlined,
                  label: L10nManager.l10n.account,
                  required: true,
                  onChanged: (value) {
                    final fund = value as UserFundVO?;
                    if (fund != null) {
                      setState(() {
                        _selectedFundId = fund.id;
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

                // 描述输入
                CommonTextFormField(
                  initialValue: _descriptionController.text,
                  labelText: L10nManager.l10n.description,
                  hintText: L10nManager.l10n
                      .pleaseInput(L10nManager.l10n.description),
                  prefixIcon: const Icon(Icons.description_outlined),
                  onChanged: (value) {
                    _descriptionController.text = value;
                  },
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
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
                SizedBox(height: spacing.formItemSpacing),

                // 保存按钮
                SizedBox(height: spacing.formGroupSpacing),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton.icon(
                    onPressed: _saveRefund,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(L10nManager.l10n.save),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
