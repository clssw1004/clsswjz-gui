import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../enums/fund_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_text_form_field.dart';

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
          _relatedBooks = result.data!;
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



  /// 选择账本
  Future<void> _selectBook() async {
    // TODO: 调用账本选择页面
    // final book = await Navigator.push<UserBookVO>(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AccountBookSelectPage(
    //       selectedBooks: _relatedBooks,
    //     ),
    //   ),
    // );
    // if (book != null) {
    //   setState(() {
    //     _relatedBooks.add(book);
    //   });
    // }
  }

  /// 删除关联账本
  Future<void> _removeBook(RelatedAccountBook book) async {
    // TODO: 调用服务删除关联账本
    // if (widget.fund != null) {
    //   final result = await ServiceManager.accountFundService.removeRelatedBook(
    //     widget.fund!.id,
    //     book.id,
    //   );
    //   if (result.ok) {
    //     setState(() {
    //       _relatedBooks.remove(book);
    //     });
    //   }
    // } else {
    setState(() {
      _relatedBooks.remove(book);
    });
    // }
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
              name: _nameController.text,
              fundType: _fundType.code,
              fundRemark: _remarkController.text.isEmpty ? null : _remarkController.text,
              fundBalance: double.parse(_balanceController.text),
              createdBy: userId,
              updatedBy: userId,
            )
          : await ServiceManager.accountFundService.updateFund(
              widget.fund!.toAccountFund().copyWith(
                name: _nameController.text,
                fundType: _fundType.code,
                fundRemark: Value(_remarkController.text.isEmpty ? null : _remarkController.text),
                fundBalance: double.parse(_balanceController.text),
                updatedBy: userId,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );

      if (result.ok) {
        // TODO: 保存关联账本
        // if (_relatedBooks.isNotEmpty) {
        //   await ServiceManager.accountFundService.updateRelatedBooks(
        //     result.data!.id,
        //     _relatedBooks.map((e) => e.id).toList(),
        //   );
        // }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(widget.fund == null ? l10n.addNew(l10n.tabFunds) : l10n.editTo(l10n.tabFunds)),
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
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            CommonTextFormField(
              initialValue: _remarkController.text,
              labelText: l10n.remark,
              onChanged: (value) => _remarkController.text = value,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  l10n.accountBook,
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _selectBook,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addNew(l10n.accountBook)),
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
                itemCount: _relatedBooks.length,
                itemBuilder: (context, index) {
                  final book = _relatedBooks[index];
                  return ListTile(
                    title: Text(book.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _removeBook(book),
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