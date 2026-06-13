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
import '../../theme/theme_radius.dart';

/// 资金账户表单页面
class FundFormPage extends StatefulWidget {
  final UserFundVO? fund;

  const FundFormPage({super.key, this.fund});

  @override
  State<FundFormPage> createState() => _FundFormPageState();
}

class _FundFormPageState extends State<FundFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _remarkController = TextEditingController();
  final _balanceController = TextEditingController();
  FundType _fundType = FundType.cash;
  bool _saving = false;

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

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

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
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(
          widget.fund == null
              ? L10nManager.l10n.addNew(L10nManager.l10n.tabFunds)
              : L10nManager.l10n.editTo(L10nManager.l10n.tabFunds),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme, colorScheme),
              const SizedBox(height: 16),
              _buildFormCard(theme, colorScheme, radius),
              const SizedBox(height: 20),
              _buildSaveButton(theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _fundType.icon,
              size: 28,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.fund == null
                ? L10nManager.l10n.addNew(L10nManager.l10n.tabFunds)
                : L10nManager.l10n.editTo(L10nManager.l10n.tabFunds),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(ThemeData theme, ColorScheme colorScheme, double radius) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius * 1.5),
        side: BorderSide(color: colorScheme.outline.withAlpha(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Theme(
          data: theme.copyWith(
            visualDensity: VisualDensity.compact,
            extensions: [
              ThemeSpacing(formItemSpacing: 10, formGroupSpacing: 14),
              if (theme.extension<ThemeRadius>() case final tr?) tr,
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonTextFormField(
                initialValue: _nameController.text,
                labelText: L10nManager.l10n.name,
                prefixIcon: Icons.money,
                required: true,
                onChanged: (value) => _nameController.text = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return L10nManager.l10n.required;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
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
                  setState(() => _fundType = value as FundType);
                },
              ),
              const SizedBox(height: 10),
              CommonTextFormField(
                initialValue: _balanceController.text,
                labelText: L10nManager.l10n.balance,
                prefixIcon: Icons.monetization_on_outlined,
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
              const SizedBox(height: 10),
              CommonTextFormField(
                initialValue: _remarkController.text,
                labelText: L10nManager.l10n.remark,
                prefixIcon: Icons.description_outlined,
                onChanged: (value) => _remarkController.text = value,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(L10nManager.l10n.save),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
