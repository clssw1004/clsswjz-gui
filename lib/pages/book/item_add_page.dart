import 'package:clsswjz/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../manager/l10n_manager.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../providers/account_item_provider.dart';
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
import '../../utils/color_util.dart';

class ItemAddPage extends StatelessWidget {
  final UserBookVO accountBook;
  final UserItemVO? item;

  const ItemAddPage({
    super.key,
    required this.accountBook,
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;

    return ChangeNotifierProvider(
      create: (context) => AccountItemFormProvider(accountBook, item),
      child: Consumer<AccountItemFormProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: CommonAppBar(
              title: Text(provider.isNew
                  ? L10nManager.l10n.addNew(L10nManager.l10n.tabAccountItems)
                  : L10nManager.l10n.editTo(L10nManager.l10n.tabAccountItems)),
            ),
            body: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Padding(
                      padding: spacing.formPadding,
                      child: _AccountItemForm(
                        provider: provider,
                        onSaved: () => Navigator.of(context).pop(true),
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
  final VoidCallback? onSaved;

  const _AccountItemForm({
    required this.provider,
    this.onSaved,
  });

  @override
  State<_AccountItemForm> createState() => _AccountItemFormState();
}

class _AccountItemFormState extends State<_AccountItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocusNode = FocusNode();
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
    } else {
      // 编辑账目，使用已有时间
      _selectedDate = widget.provider.item.accountDateOnly;
      _selectedTime = widget.provider.item.accountTimeOnly.substring(0, 5); // 只显示HH:mm

      // 加载附件
      widget.provider.loadAttachments();
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
                label: Text(L10nManager.l10n.expense),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              ButtonSegment<AccountItemType>(
                value: AccountItemType.income,
                label: Text(L10nManager.l10n.income),
                icon: const Icon(Icons.add_circle_outline),
              ),
              ButtonSegment<AccountItemType>(
                value: AccountItemType.transfer,
                label: Text(L10nManager.l10n.transfer),
                icon: const Icon(Icons.swap_horizontal_circle_outlined),
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
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                provider.partUpdate();
              }
            },
            child: AmountInput(
              type: item.type,
              controller: _amountController,
              focusNode: _amountFocusNode,
              onChanged: (value) {
                provider.updateAmount(value);
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
            label: L10nManager.l10n.category,
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
                return L10nManager.l10n.required;
              }
              return null;
            },
          ),
          SizedBox(height: spacing.formItemSpacing),

          // 账户选择
          CommonSelectFormField<UserFundVO>(
            items: provider.funds.cast<UserFundVO>(),
            value: item.fundId,
            displayMode: DisplayMode.iconText,
            displayField: (item) => item.name,
            keyField: (item) => item.id,
            icon: Icons.account_balance_wallet_outlined,
            label: L10nManager.l10n.account,
            required: true,
            onChanged: (value) {
              final fund = value as UserFundVO?;
              if (fund != null) {
                provider.updateFund(fund.id, fund.name);
              } else {
                provider.updateFund(null, null);
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

          // 商户选择
          CommonSelectFormField<AccountShop>(
            items: provider.shops.cast<AccountShop>(),
            value: item.shopCode == 'NO_SHOP' ? null : item.shopCode,
            displayMode: DisplayMode.iconText,
            displayField: (item) => item.name,
            keyField: (item) => item.code,
            icon: Icons.store_outlined,
            label: L10nManager.l10n.merchant,
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
            onChanged: (value) {
              final shop = value as AccountShop?;
              if (shop != null) {
                provider.updateShop(shop.code, shop.name);
              } else {
                provider.updateShop(null, null);
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
                  label: L10nManager.l10n.tag,
                  displayMode: DisplayMode.badge,
                  displayField: (item) => item.name,
                  keyField: (item) => item.code,
                  icon: Icons.local_offer_outlined,
                  hint: L10nManager.l10n.tag,
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
                  label: L10nManager.l10n.project,
                  displayMode: DisplayMode.badge,
                  displayField: (item) => item.name,
                  keyField: (item) => item.code,
                  icon: Icons.folder_outlined,
                  hint: L10nManager.l10n.project,
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
          SizedBox(height: spacing.formItemSpacing),

          // 描述输入
          CommonTextFormField(
            initialValue: _descriptionController.text,
            labelText: L10nManager.l10n.description,
            hintText: L10nManager.l10n.pleaseInput(L10nManager.l10n.description),
            prefixIcon: const Icon(Icons.description_outlined),
            onChanged: provider.updateDescription,
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 9,
          ),

          // 附件上传
          SizedBox(height: spacing.formItemSpacing),
          CommonAttachmentField(
            attachments: provider.attachments,
            label: L10nManager.l10n.attachments,
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

              // 只更新provider中的附件列表，不保存到数据库
              provider.updateAttachments([...provider.attachments, ...attachments]);
            },
            onDelete: (attachment) async {
              // 只从provider中移除附件，不从数据库中删除
              provider.updateAttachments(
                provider.attachments.where((a) => a.id != attachment.id).toList(),
              );
            },
            onTap: (attachment) async {
              final result = await FileUtil.openFile(attachment);
              if (!result.ok && mounted) {
                ToastUtil.showError(result.message ?? '打开文件失败');
              }
            },
          ),

          // 保存按钮
          SizedBox(height: spacing.formGroupSpacing),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: provider.saving
                  ? null
                  : () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        if (await provider.create()) {
                          if (context.mounted) {
                            if (widget.onSaved != null) {
                              widget.onSaved!();
                            }
                          }
                        } else if (context.mounted && provider.error != null) {
                          ToastUtil.showError(provider.error!);
                        }
                      }
                    },
              icon: provider.saving
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
                minimumSize: const Size.fromHeight(48),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
