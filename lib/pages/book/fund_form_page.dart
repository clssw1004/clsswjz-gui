import 'package:flutter/material.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/fund_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../theme/theme_spacing.dart';

/// 资金账户表单页面
class FundFormPage extends StatefulWidget {
  /// 资金账户
  final UserFundVO? fund;

  const FundFormPage({super.key, this.fund});

  @override
  State<FundFormPage> createState() => _FundFormPageState();
}

class _FundFormPageState extends State<FundFormPage> {
  /// 表单Key
  final _formKey = GlobalKey<FormState>();

  /// 名称控制器
  final _nameController = TextEditingController();

  /// 备注控制器
  final _remarkController = TextEditingController();

  /// 余额控制器
  final _balanceController = TextEditingController();

  /// 账户类型
  FundType _fundType = FundType.cash;

  /// 是否正在保存
  bool _saving = false;

  /// 是否正在加载账本

  @override
  void initState() {
    super.initState();
    if (widget.fund != null) {
      _nameController.text = widget.fund!.name;
      _remarkController.text = widget.fund!.fundRemark ?? '';
      _balanceController.text = widget.fund!.fundBalance.toString();
      _fundType = widget.fund!.fundType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _remarkController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  /// 保存
  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      final userId = AppConfigManager.instance.userId;
      final result = widget.fund == null
          ? await DriverFactory.driver.createFund(
              userId,
              widget.fund!.accountBookId,
              name: _nameController.text,
              fundType: _fundType,
              fundBalance: double.parse(_balanceController.text),
              fundRemark: _remarkController.text,
            )
          : await DriverFactory.driver.updateFund(
              userId,
              widget.fund!.accountBookId,
              widget.fund!.id,
              name: _nameController.text,
              fundType: _fundType,
              fundBalance: double.parse(_balanceController.text),
              fundRemark: _remarkController.text,
            );
      if (result.ok && mounted) {
        Navigator.of(context).pop(true);
      } else {
        if (mounted) {
          ToastUtil.showError(result.message ?? '保存失败');
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
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(
            widget.fund == null ? L10nManager.l10n.addNew(L10nManager.l10n.tabFunds) : L10nManager.l10n.editTo(L10nManager.l10n.tabFunds)),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
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
            CommonTextFormField(
              initialValue: _nameController.text,
              labelText: L10nManager.l10n.name,
              required: true,
              onChanged: (value) => _nameController.text = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return L10nManager.l10n.required;
                }
                return null;
              },
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonSelectFormField<FundType>(
              items: FundType.values,
              value: _fundType,
              displayMode: DisplayMode.expand,
              displayField: (item) => switch (item) {
                FundType.cash => L10nManager.l10n.fundTypeCash,
                FundType.debitCard => L10nManager.l10n.fundTypeDebitCard,
                FundType.creditCard => L10nManager.l10n.fundTypeCreditCard,
                FundType.prepaidCard => L10nManager.l10n.fundTypePrepaidCard,
                FundType.alipay => L10nManager.l10n.fundTypeAlipay,
                FundType.wechat => L10nManager.l10n.fundTypeWechat,
                FundType.debt => L10nManager.l10n.fundTypeDebt,
                FundType.investment => L10nManager.l10n.fundTypeInvestment,
                FundType.eWallet => L10nManager.l10n.fundTypeEWallet,
                FundType.other => L10nManager.l10n.fundTypeOther,
              },
              keyField: (item) => item,
              icon: Icons.account_balance_outlined,
              label: L10nManager.l10n.type,
              allowCreate: false,
              required: true,
              expandCount: 10,
              expandRows: 4,
              onChanged: (value) {
                setState(() {
                  _fundType = value as FundType;
                });
              },
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonTextFormField(
              initialValue: _balanceController.text,
              labelText: L10nManager.l10n.balance,
              required: true,
              onChanged: (value) => _balanceController.text = value,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return L10nManager.l10n.required;
                }
                if (double.tryParse(value) == null) {
                  return L10nManager.l10n.invalidNumber;
                }
                return null;
              },
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonTextFormField(
              initialValue: _remarkController.text,
              labelText: L10nManager.l10n.remark,
              onChanged: (value) => _remarkController.text = value,
            ),
            SizedBox(height: spacing.formGroupSpacing),
          ],
        ),
      ),
    );
  }
}
