import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../database/database.dart';
import '../../enums/fund_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/shared_badge.dart';

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

  /// 关联的账本列表
  List<RelatedAccountBook> _relatedBooks = [];

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
      _relatedBooks = widget.fund!.relatedBooks;
    } else {
      ServiceManager.accountFundService.getDefaultRelatedBooks().then((result) {
        if (result.ok) {
          setState(() {
            _relatedBooks = result.data!;
          });
        }
      });
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
      final userId = AppConfigManager.instance.userId!;
      final result = widget.fund == null
          ? await ServiceManager.accountFundService.createFund(
              AccountFund(
                id: '',
                name: _nameController.text,
                fundType: _fundType.code,
                fundBalance: double.parse(_balanceController.text),
                fundRemark: _remarkController.text.isEmpty
                    ? null
                    : _remarkController.text,
                createdBy: userId,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                updatedBy: userId,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
                isDefault: false,
              ),
              _relatedBooks,
              userId)
          : await ServiceManager.accountFundService.updateFund(
              AccountFund(
                createdBy: widget.fund!.createdBy,
                updatedBy: userId,
                id: widget.fund!.id,
                createdAt: widget.fund!.createdAt,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
                name: _nameController.text,
                fundType: _fundType.code,
                fundBalance: double.parse(_balanceController.text),
                isDefault: false,
              ),
              _relatedBooks,
              userId,
            );

      if (result.ok && mounted) {
        Navigator.of(context).pop(true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? '保存失败')),
          );
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

  /// 构建操作按钮
  Widget _buildActionChip({
    required String label,
    required bool selected,
    required ValueChanged<bool> onSelected,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSelected(!selected),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : Colors.transparent,
            border: Border.all(
              color:
                  selected ? colorScheme.primaryContainer : colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(widget.fund == null
            ? l10n.addNew(l10n.tabFunds)
            : l10n.editTo(l10n.tabFunds)),
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
          padding: const EdgeInsets.all(16),
          children: [
            CommonTextFormField(
              initialValue: _nameController.text,
              labelText: l10n.name,
              required: true,
              onChanged: (value) => _nameController.text = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CommonSelectFormField<FundType>(
              items: FundType.values,
              value: _fundType,
              displayMode: DisplayMode.expand,
              displayField: (item) => switch (item) {
                FundType.cash => l10n.fundTypeCash,
                FundType.debitCard => l10n.fundTypeDebitCard,
                FundType.creditCard => l10n.fundTypeCreditCard,
                FundType.prepaidCard => l10n.fundTypePrepaidCard,
                FundType.alipay => l10n.fundTypeAlipay,
                FundType.wechat => l10n.fundTypeWechat,
                FundType.debt => l10n.fundTypeDebt,
                FundType.investment => l10n.fundTypeInvestment,
                FundType.eWallet => l10n.fundTypeEWallet,
                FundType.other => l10n.fundTypeOther,
              },
              keyField: (item) => item,
              icon: Icons.account_balance_outlined,
              label: l10n.type,
              required: true,
              expandCount: 10,
              expandRows: 4,
              onChanged: (value) {
                setState(() {
                  _fundType = value as FundType;
                });
              },
            ),
            CommonTextFormField(
              initialValue: _balanceController.text,
              labelText: l10n.balance,
              required: true,
              onChanged: (value) => _balanceController.text = value,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.required;
                }
                if (double.tryParse(value) == null) {
                  return l10n.invalidNumber;
                }
                return null;
              },
            ),
            CommonTextFormField(
              initialValue: _remarkController.text,
              labelText: l10n.remark,
              onChanged: (value) => _remarkController.text = value,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  l10n.relatedBooks,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            if (_relatedBooks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.noAccountBooks,
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _relatedBooks.length,
                itemBuilder: (context, index) {
                  final book = _relatedBooks[index];
                  final isShared =
                      book.fromId != AppConfigManager.instance.userId;
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 4,
                      right: 4,
                    ),
                    child: CommonCardContainer(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              book.icon != null
                                  ? IconData(int.parse(book.icon!),
                                      fontFamily: 'MaterialIcons')
                                  : Icons.book_outlined,
                              color: colorScheme.onSecondaryContainer,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (book.description?.isNotEmpty ==
                                            true) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            book.description!,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            _buildActionChip(
                                              label: l10n.income,
                                              selected: book.fundIn,
                                              onSelected: (value) {
                                                setState(() {
                                                  _relatedBooks[index] = book
                                                      .copyWith(fundIn: value);
                                                });
                                              },
                                              colorScheme: colorScheme,
                                            ),
                                            const SizedBox(width: 12),
                                            _buildActionChip(
                                              label: l10n.expense,
                                              selected: book.fundOut,
                                              onSelected: (value) {
                                                setState(() {
                                                  _relatedBooks[index] = book
                                                      .copyWith(fundOut: value);
                                                });
                                              },
                                              colorScheme: colorScheme,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (isShared)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: SharedBadge(name: book.fromName),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
