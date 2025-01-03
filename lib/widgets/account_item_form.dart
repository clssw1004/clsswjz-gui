import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../constants/constant.dart';
import '../database/database.dart';
import '../enums/account_type.dart';
import '../manager/app_config_manager.dart';
import '../manager/service_manager.dart';
import '../providers/account_item_form_provider.dart';
import 'amount_input.dart';
import 'common/common_select_form_field.dart';
import 'common/common_text_form_field.dart';
import 'common/common_badge.dart';

class AccountItemForm extends StatefulWidget {
  final AccountItemFormProvider provider;
  final VoidCallback? onSaved;

  const AccountItemForm({
    super.key,
    required this.provider,
    this.onSaved,
  });

  @override
  State<AccountItemForm> createState() => _AccountItemFormState();
}

class _AccountItemFormState extends State<AccountItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late String _selectedDate;
  late String _selectedTime;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.provider.item.amount.toString();
    _descriptionController.text = widget.provider.item.description ?? '';

    // 初始化日期和时间
    if (widget.provider.item.id.isEmpty) {
      // 新建账目，使用当前时间
      final now = DateTime.now();
      _selectedDate = DateFormat('yyyy-MM-dd').format(now);
      _selectedTime = DateFormat('HH:mm').format(now);
      widget.provider.item.updateDateTime(_selectedDate, '$_selectedTime:00');
    } else {
      // 编辑账目，使用已有时间
      _selectedDate = widget.provider.item.accountDateOnly;
      _selectedTime =
          widget.provider.item.accountTimeOnly.substring(0, 5); // 只显示HH:mm
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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
        widget.provider.item.updateDateTime(_selectedDate, _selectedTime);
      });
    }
  }

  /// 选择时间
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateFormat('HH:mm').parse(_selectedTime),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = '${picked.hour.toString().padLeft(2, '0')}:'
            '${picked.minute.toString().padLeft(2, '0')}';
        widget.provider.item.updateDateTime(_selectedDate, '$_selectedTime:00');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = widget.provider;
    final item = provider.item;
    final colorScheme = theme.colorScheme;

    // 获取当前账目类型
    final currentType =
        AccountItemType.fromCode(item.type) ?? AccountItemType.expense;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 账目类型选择
          SegmentedButton<AccountItemType>(
            segments: [
              ButtonSegment<AccountItemType>(
                value: AccountItemType.expense,
                label: Text(l10n.expense),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              ButtonSegment<AccountItemType>(
                value: AccountItemType.income,
                label: Text(l10n.income),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
            selected: {currentType},
            onSelectionChanged: (Set<AccountItemType> selected) {
              if (selected.isNotEmpty) {
                provider.updateType(selected.first.code);
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return currentType == AccountItemType.expense
                      ? colorScheme.errorContainer
                      : colorScheme.primaryContainer;
                }
                return null;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return currentType == AccountItemType.expense
                      ? colorScheme.onErrorContainer
                      : colorScheme.onPrimaryContainer;
                }
                return null;
              }),
            ),
          ),
          const SizedBox(height: 16),

          // 金额输入
          AmountInput(
            type: item.type,
            controller: _amountController,
            onChanged: (value) => provider.updateAmount(value),
          ),

          // 分类选择
          CommonSelectFormField<AccountCategory>(
            items: provider.categories
                .where((category) => category.categoryType == item.type)
                .toList()
                .cast<AccountCategory>(),
            value: item.categoryCode,
            displayMode: DisplayMode.expand,
            displayField: (item) => item.name,
            keyField: (item) => item.code,
            icon: Icons.category_outlined,
            label: l10n.category,
            required: true,
            expandCount: 8,
            expandRows: 3,
            onCreateItem: (value) async {
              final service = ServiceManager.accountCategoryService;
              final userId = AppConfigManager.instance.userId!;
              final result = await service.createCategory(
                name: value,
                code: value,
                accountBookId: provider.accountBook.id,
                categoryType: item.type,
                createdBy: userId,
              );
              if (result.data != null) {
                await provider.loadCategories();
                return provider.categories
                    .cast<AccountCategory>()
                    .firstWhere((category) => category.code == value);
              }
              return null;
            },
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

          // 商户选择
          CommonSelectFormField<AccountShop>(
            items: provider.shops.cast<AccountShop>(),
            value: item.shopCode == 'NO_SHOP' ? null : item.shopCode,
            displayMode: DisplayMode.iconText,
            displayField: (item) => item.name,
            keyField: (item) => item.code,
            icon: Icons.store_outlined,
            label: l10n.merchant,
            onCreateItem: (value) async {
              final service = ServiceManager.accountShopService;
              final userId = AppConfigManager.instance.userId!;
              final result = await service.createShop(
                name: value,
                code: value,
                accountBookId: provider.accountBook.id,
                createdBy: userId,
                updatedBy: userId,
              );
              if (result.data != null) {
                await provider.loadShops();
                return provider.shops
                    .cast<AccountShop>()
                    .firstWhere((shop) => shop.code == value);
              }
              return null;
            },
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
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
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
                  onCreateItem: (value) async {
                    final service = ServiceManager.accountSymbolService;
                    final userId = AppConfigManager.instance.userId!;
                    final result = await service.createSymbol(
                      name: value,
                      code: value,
                      accountBookId: provider.accountBook.id,
                      symbolType: SYMBOL_TYPE_TAG,
                      createdBy: userId,
                      updatedBy: userId,
                    );
                    if (result.data != null) {
                      await provider.loadTags();
                      return provider.tags
                          .cast<AccountSymbol>()
                          .firstWhere((tag) => tag.code == value);
                    }
                    return null;
                  },
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
                  onCreateItem: (value) async {
                    final service = ServiceManager.accountSymbolService;
                    final userId = AppConfigManager.instance.userId!;
                    final result = await service.createSymbol(
                      name: value,
                      code: value,
                      accountBookId: provider.accountBook.id,
                      symbolType: SYMBOL_TYPE_PROJECT,
                      createdBy: userId,
                      updatedBy: userId,
                    );
                    if (result.data != null) {
                      await provider.loadProjects();
                      return provider.projects
                          .cast<AccountSymbol>()
                          .firstWhere((project) => project.code == value);
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final project = value as AccountSymbol?;
                    if (project != null) {
                      provider.updateProject(project.code, project.name);
                    } else {
                      provider.updateProject(null, null);
                    }
                  },
                ),
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

          // 描述输入
          CommonTextFormField(
            initialValue: _descriptionController.text,
            labelText: l10n.description,
            hintText: l10n.pleaseInput(l10n.description),
            prefixIcon: const Icon(Icons.description_outlined),
            onChanged: provider.updateDescription,
            keyboardType: TextInputType.multiline,
          ),

          // 保存按钮
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: provider.saving
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (await provider.save()) {
                          if (context.mounted) {
                            if (widget.onSaved != null) {
                              widget.onSaved!();
                            } else {
                              Navigator.of(context).pop(true);
                            }
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
              icon: provider.saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(l10n.save),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
