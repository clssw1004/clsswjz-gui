import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../models/vo/account_item_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/account_item_form_provider.dart';
import '../../utils/color_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../theme/theme_spacing.dart';
import '../../enums/symbol_type.dart';
import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/account_type.dart';
import '../../enums/business_type.dart';
import '../../manager/app_config_manager.dart';
import '../../utils/attachment.util.dart';
import '../../utils/file_util.dart';
import '../../widgets/amount_input.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/common_badge.dart';
import '../../widgets/common/common_attachment_field.dart';

class AccountItemEditPage extends StatelessWidget {
  final UserBookVO accountBook;
  final AccountItemVO item;

  const AccountItemEditPage({
    super.key,
    required this.accountBook,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;

    return ChangeNotifierProvider(
      create: (context) => AccountItemFormProvider(accountBook, item),
      child: Consumer<AccountItemFormProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: CommonAppBar(
              title: Text(l10n.editTo(l10n.tabAccountItems)),
            ),
            body: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: spacing.formPadding,
                      child: _AccountItemForm(
                        provider: provider,
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _AccountItemForm extends StatefulWidget {
  final AccountItemFormProvider provider;

  const _AccountItemForm({
    required this.provider,
  });

  @override
  State<_AccountItemForm> createState() => _AccountItemFormState();
}

class _AccountItemFormState extends State<_AccountItemForm> {
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
    _selectedDate = widget.provider.item.accountDateOnly;
    _selectedTime = widget.provider.item.accountTimeOnly.substring(0, 5); // 只显示HH:mm

    // 加载附件
    widget.provider.loadAttachments();
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
      });
      await widget.provider.updateDateTimeAndSave(_selectedDate, _selectedTime);
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
      });
      await widget.provider.updateDateTimeAndSave(_selectedDate, '$_selectedTime:00');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = widget.provider;
    final item = provider.item;
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    // 获取当前账目类型
    final currentType = AccountItemType.fromCode(item.type) ?? AccountItemType.expense;

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
              ButtonSegment<AccountItemType>(
                value: AccountItemType.transfer,
                label: Text(l10n.transfer),
                icon: const Icon(Icons.swap_horiz_outlined),
              ),
            ],
            selected: {currentType},
            onSelectionChanged: (Set<AccountItemType> selected) async {
              if (selected.isNotEmpty) {
                await provider.updateTypeAndSave(selected.first.code);
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  switch (currentType) {
                    case AccountItemType.expense:
                      return ColorUtil.EXPENSE.withAlpha(64);
                    case AccountItemType.income:
                      return ColorUtil.INCOME.withAlpha(64);
                    case AccountItemType.transfer:
                      return ColorUtil.TRANSFER.withAlpha(64);
                  }
                }
                return null;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  switch (currentType) {
                    case AccountItemType.expense:
                      return ColorUtil.EXPENSE;
                    case AccountItemType.income:
                      return ColorUtil.INCOME;
                    case AccountItemType.transfer:
                      return ColorUtil.TRANSFER;
                  }
                }
                return null;
              }),
            ),
          ),
          SizedBox(height: spacing.formItemSpacing),

          // 金额输入
          Focus(
            onFocusChange: (hasFocus) async {
              if (!hasFocus) {
                await provider.partUpdate();
              }
            },
            child: AmountInput(
              type: item.type,
              controller: _amountController,
              onChanged: (value) async {
                await provider.updateAmountAndSave(value);
              },
            ),
          ),
          SizedBox(height: spacing.formItemSpacing),

          // 分类选择
          CommonSelectFormField<AccountCategory>(
            items: provider.categories.where((category) => category.categoryType == item.type).toList().cast<AccountCategory>(),
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
              final result = await DriverFactory.driver.createCategory(
                AppConfigManager.instance.userId!,
                provider.accountBook.id,
                name: value,
                categoryType: item.type,
              );
              if (result.ok) {
                await provider.loadCategories();
                return provider.categories.cast<AccountCategory>().firstWhere((category) => category.name == value);
              }
              return null;
            },
            onChanged: (value) async {
              final category = value as AccountCategory?;
              if (category != null) {
                await provider.updateCategoryAndSave(category.code, category.name);
              } else {
                await provider.updateCategoryAndSave(null, null);
              }
            },
            validator: (value) {
              if (value == null) {
                return l10n.required;
              }
              return null;
            },
          ),
          SizedBox(height: spacing.formItemSpacing),

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
            onChanged: (value) async {
              final fund = value as AccountFund?;
              if (fund != null) {
                await provider.updateFundAndSave(fund.id, fund.name);
              } else {
                await provider.updateFundAndSave(null, null);
              }
            },
            validator: (value) {
              if (value == null) {
                return l10n.required;
              }
              return null;
            },
          ),
          SizedBox(height: spacing.formItemSpacing),

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
              final result = await DriverFactory.driver.createShop(
                AppConfigManager.instance.userId!,
                provider.accountBook.id,
                name: value,
              );
              if (result.data != null) {
                await provider.loadShops();
                return provider.shops.cast<AccountShop>().firstWhere((shop) => shop.code == value);
              }
              return null;
            },
            onChanged: (value) async {
              final shop = value as AccountShop?;
              if (shop != null) {
                await provider.updateShopAndSave(shop.code, shop.name);
              } else {
                await provider.updateShopAndSave(null, null);
              }
            },
          ),
          SizedBox(height: spacing.formItemSpacing),

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
                    final result = await DriverFactory.driver.createSymbol(
                      AppConfigManager.instance.userId!,
                      provider.accountBook.id,
                      name: value,
                      symbolType: SymbolType.tag,
                    );
                    if (result.data != null) {
                      await provider.loadTags();
                      return provider.tags.cast<AccountSymbol>().firstWhere((tag) => tag.code == value);
                    }
                    return null;
                  },
                  onChanged: (value) async {
                    final tag = value as AccountSymbol?;
                    if (tag != null) {
                      await provider.updateTagAndSave(tag.code, tag.name);
                    } else {
                      await provider.updateTagAndSave(null, null);
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
                    final result = await DriverFactory.driver.createSymbol(
                      AppConfigManager.instance.userId!,
                      provider.accountBook.id,
                      name: value,
                      symbolType: SymbolType.project,
                    );
                    if (result.data != null) {
                      await provider.loadProjects();
                      return provider.projects.cast<AccountSymbol>().firstWhere((project) => project.code == value);
                    }
                    return null;
                  },
                  onChanged: (value) async {
                    final project = value as AccountSymbol?;
                    if (project != null) {
                      await provider.updateProjectAndSave(project.code, project.name);
                    } else {
                      await provider.updateProjectAndSave(null, null);
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
          SizedBox(height: spacing.formItemSpacing),

          // 描述输入
          Focus(
            onFocusChange: (hasFocus) async {
              if (!hasFocus) {
                await provider.partUpdate();
              }
            },
            child: CommonTextFormField(
              initialValue: _descriptionController.text,
              labelText: l10n.description,
              hintText: l10n.pleaseInput(l10n.description),
              prefixIcon: const Icon(Icons.description_outlined),
              onChanged: provider.updateDescription,
              keyboardType: TextInputType.multiline,
            ),
          ),

          // 附件上传
          SizedBox(height: spacing.formItemSpacing),
          CommonAttachmentField(
            attachments: provider.attachments,
            label: l10n.attachments,
            onUpload: (files) async {
              final userId = provider.item.updatedBy;
              final attachments = files
                  .map((file) => AttachmentUtil.generateVoFromFile(
                        BusinessType.item,
                        provider.item.id,
                        file,
                        userId,
                      ))
                  .toList();

              await provider.updateAttachmentsAndSave([...provider.attachments, ...attachments]);
            },
            onDelete: (attachment) async {
              await provider.updateAttachmentsAndSave(
                provider.attachments.where((a) => a.id != attachment.id).toList(),
              );
            },
            onTap: (attachment) async {
              final result = await FileUtil.openFile(attachment);
              if (!result.ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message ?? '打开文件失败'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
          ),
          SizedBox(height: spacing.formItemSpacing),
        ],
      ),
    );
  }
}
