import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/vo/account_item_vo.dart';
import '../providers/account_item_form_provider.dart';
import '../widgets/amount_input.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_select_form_field.dart';
import '../widgets/common_text_form_field.dart';
import '../database/database.dart';

/// 账目详情表单页面
class AccountItemFormPage extends StatelessWidget {
  /// 账目数据
  final AccountItemVO item;

  const AccountItemFormPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountItemFormProvider(item),
      child: const _AccountItemFormView(),
    );
  }
}

class _AccountItemFormView extends StatefulWidget {
  const _AccountItemFormView();

  @override
  State<_AccountItemFormView> createState() => _AccountItemFormViewState();
}

class _AccountItemFormViewState extends State<_AccountItemFormView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<AccountItemFormProvider>();
    _amountController.text = provider.item.amount.toString();
    _descriptionController.text = provider.item.description ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<AccountItemFormProvider>();
    final item = provider.item;

    if (provider.loading) {
      return Scaffold(
        appBar: CommonAppBar(
          title: Text(item.type == 'EXPENSE' ? l10n.expense : l10n.income),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(item.type == 'EXPENSE' ? l10n.expense : l10n.income),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: provider.saving
                ? null
                : () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      if (await provider.save()) {
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      } else if (context.mounted && provider.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(provider.error!),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 金额输入
            AmountInput(
              type: item.type,
              controller: _amountController,
              onChanged: (value) => provider.updateAmount(value),
            ),
            const SizedBox(height: 16),

            // 分类选择
            CommonSelectFormField<AccountCategory>(
              items: provider.categories.cast<AccountCategory>(),
              value: item.categoryCode,
              displayMode: DisplayMode.expand,
              displayField: (item) => item.name,
              keyField: (item) => item.code,
              icon: Icons.category_outlined,
              label: l10n.category,
              required: true,
              expandCount: 8,
              expandRows: 3,
              onChanged: (value) {
                final category = value as AccountCategory?;
                if (category != null) {
                  provider.updateCategory(category.code, category.name);
                } else {
                  provider.updateCategory(null, null);
                }
              },
              validator: (value) {
                if (value == null) {
                  return l10n.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 账户选择
            CommonSelectFormField<AccountFund>(
              items: provider.funds.cast<AccountFund>(),
              value: item.fundId,
              displayMode: DisplayMode.iconText,
              displayField: (item) => item.name,
              keyField: (item) => item.id,
              icon: Icons.account_balance_wallet_outlined,
              label: l10n.account,
              required: true,
              onChanged: (value) {
                final fund = value as AccountFund?;
                if (fund != null) {
                  provider.updateFund(fund.id, fund.name);
                } else {
                  provider.updateFund(null, null);
                }
              },
              validator: (value) {
                if (value == null) {
                  return l10n.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 商户选择
            CommonSelectFormField<AccountShop>(
              items: provider.shops.cast<AccountShop>(),
              value: item.shopCode == 'NO_SHOP' ? null : item.shopCode,
              displayMode: DisplayMode.iconText,
              displayField: (item) => item.name,
              keyField: (item) => item.code,
              icon: Icons.store_outlined,
              label: l10n.merchant,
              onChanged: (value) {
                final shop = value as AccountShop?;
                if (shop != null) {
                  provider.updateShop(shop.code, shop.name);
                } else {
                  provider.updateShop(null, null);
                }
              },
            ),
            const SizedBox(height: 16),

            // 标签和项目选择
            Wrap(
              spacing: 8,
              children: [
                CommonSelectFormField<AccountSymbol>(
                  items: provider.tags.cast<AccountSymbol>(),
                  value: item.tagCode,
                  label: l10n.tag,
                  displayMode: DisplayMode.badge,
                  displayField: (item) => item.name,
                  keyField: (item) => item.code,
                  icon: Icons.local_offer_outlined,
                  hint: l10n.tag,
                  onChanged: (value) {
                    final tag = value as AccountSymbol?;
                    if (tag != null) {
                      provider.updateTag(tag.code, tag.name);
                    } else {
                      provider.updateTag(null, null);
                    }
                  },
                ),
                CommonSelectFormField<AccountSymbol>(
                  items: provider.projects.cast<AccountSymbol>(),
                  value: item.projectCode,
                  label: l10n.project,
                  displayMode: DisplayMode.badge,
                  displayField: (item) => item.name,
                  keyField: (item) => item.code,
                  icon: Icons.folder_outlined,
                  hint: l10n.project,
                  onChanged: (value) {
                    final project = value as AccountSymbol?;
                    if (project != null) {
                      provider.updateProject(project.code, project.name);
                    } else {
                      provider.updateProject(null, null);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 描述输入
            CommonTextFormField(
              initialValue: _descriptionController.text,
              labelText: '描述',
              hintText: '请输入描述',
              prefixIcon: const Icon(Icons.description_outlined),
              onChanged: provider.updateDescription,
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
      ),
    );
  }
}
