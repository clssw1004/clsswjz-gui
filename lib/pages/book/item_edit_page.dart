import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../providers/item_form_provider.dart';
import '../../utils/color_util.dart';
import '../../utils/navigation_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../theme/theme_spacing.dart';
import '../../enums/symbol_type.dart';
import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/account_type.dart';
import '../../enums/business_type.dart';
import '../../manager/app_config_manager.dart';
import '../../utils/attachment.util.dart';
import '../../widgets/book/amount_input.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/multi_select_dialog.dart';
import '../../widgets/common/multi_select_sheet.dart';
import '../../widgets/common/tree_select_form_field.dart';
import '../../widgets/common/common_badge.dart';
import '../../widgets/common/common_attachment_field.dart';

class ItemEditPage extends StatelessWidget {
  final BookMetaVO bookMeta;
  final UserItemVO item;

  const ItemEditPage({
    super.key,
    required this.bookMeta,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;

    return ChangeNotifierProvider(
      create: (context) => ItemFormProvider(bookMeta, item),
      child: Consumer<ItemFormProvider>(
        builder: (context, provider, child) {
          // 判断是否为支出类型
          final isExpense = provider.item.type == AccountItemType.expense.code;

          return Scaffold(
            appBar: CommonAppBar(
              title: Text(
                  L10nManager.l10n.editTo(L10nManager.l10n.tabAccountItems)),
              actions: [
                // 只有支出类型才显示退款按钮
                if (isExpense)
                  IconButton(
                    icon: const Icon(Icons.currency_exchange),
                    tooltip: L10nManager.l10n.refund,
                    onPressed: () => _navigateToRefundPage(context),
                  ),
              ],
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

  // 跳转到退款页面
  void _navigateToRefundPage(BuildContext context) async {
    final result = await NavigationUtil.toItemRefund(context, item);

    // 如果退款成功，返回到上一页
    if (result && context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class _AccountItemForm extends StatefulWidget {
  final ItemFormProvider provider;

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
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.provider.item.amount.toString();
    _descriptionController.text = widget.provider.item.description ?? '';

    // 初始化日期和时间
    _selectedDate = widget.provider.item.accountDateOnly;
    _selectedTime = widget.provider.item.accountTimeOnly;

    // 加载附件
    widget.provider.loadAttachments();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// 防抖处理
  void _debounce(VoidCallback callback) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), callback);
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
      await widget.provider
          .updateDateTimeAndSave(_selectedDate, '$_selectedTime:00');
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
    final currentType =
        AccountItemType.fromCode(item.type) ?? AccountItemType.expense;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // === 账本 ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.book_outlined, size: 20, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    provider.currentBook?.name ?? L10nManager.l10n.noAccountBooks,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // === 金额 ===
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
            onSelectionChanged: (Set<AccountItemType> selected) async {
              if (selected.isNotEmpty) {
                final newType = selected.first;
                final currentAmount =
                    double.tryParse(_amountController.text) ?? 0;
                if (currentAmount != 0) {
                  if (currentType == AccountItemType.expense &&
                      newType == AccountItemType.income) {
                    _amountController.text = currentAmount.abs().toString();
                  } else if (currentType == AccountItemType.income &&
                      newType == AccountItemType.expense) {
                    _amountController.text = (-currentAmount.abs()).toString();
                  }
                }
                await provider.updateTypeAndSave(newType);
                await provider
                    .updateAmountAndSave(double.parse(_amountController.text));
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
          AmountInput(
            controller: _amountController,
            color: ColorUtil.getAmountColor(item.type),
            onChanged: (value) {
              _debounce(() => provider.updateAmountAndSave(value));
            },
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // === 分类（常用铺开展示，更多展示树形） ===
          CommonSelectFormField<AccountCategory>(
            items: provider.categories
                .cast<AccountCategory>()
                .where((c) => c.categoryType == item.type)
                .toList(),
            value: item.categoryCode,
            displayMode: DisplayMode.expand,
            displayField: (i) => i.name,
            keyField: (i) => i.code,
            icon: Icons.category_outlined,
            label: L10nManager.l10n.category,
            required: true,
            expandCount: 8,
            expandRows: 3,
            treeRoots: TreeBuilder.buildTree(
              provider.categories
                  .cast<AccountCategory>()
                  .where((c) => c.categoryType == item.type)
                  .toList(),
              getId: (AccountCategory c) => c.id,
              getParentId: (AccountCategory c) => c.parentId,
            ),
            onCreateItem: (value) async {
              final result = await DriverFactory.driver.createCategory(
                AppConfigManager.instance.userId,
                provider.bookMeta.id,
                name: value,
                categoryType: item.type,
              );
              if (result.ok) {
                await provider.loadCategories(provider.bookMeta.id, item.type);
                return provider.categories
                    .cast<AccountCategory>()
                    .firstWhere((c) => c.name == value);
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
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // === 账户与标签 ===
          CommonSelectFormField<UserFundVO>(
            items: provider.funds.cast<UserFundVO>(),
            value: item.fundId,
            displayMode: DisplayMode.iconText,
            displayField: (item) => item.name,
            allowCreate: false,
            keyField: (item) => item.id,
            icon: Icons.account_balance_wallet_outlined,
            label: L10nManager.l10n.account,
            required: true,
            onChanged: (value) async {
              final fund = value as UserFundVO?;
              if (fund != null) {
                await provider.updateFundAndSave(fund.id, fund.name);
              } else {
                await provider.updateFundAndSave(null, null);
              }
            },
            validator: (value) {
              if (value == null) return L10nManager.l10n.required;
              return null;
            },
          ),
          SizedBox(height: spacing.formItemSpacing),
          // === 商户（树形） ===
          TreeSelectFormField<AccountShop>(
            roots: TreeBuilder.buildTree(provider.shops.cast<AccountShop>(),
                getId: (c) => c.id, getParentId: (c) => c.parentId),
            value: item.shopCode != null && item.shopCode != 'NO_SHOP'
                ? provider.shops.cast<AccountShop>().where(
                    (c) => c.code == item.shopCode).firstOrNull
                : null,
            displayField: (c) => c.name,
            idField: (c) => c.code,
            label: L10nManager.l10n.merchant,
            allowCreate: true,
            onCreateItem: (value) async {
              final result = await DriverFactory.driver.createShop(
                AppConfigManager.instance.userId,
                provider.item.accountBookId,
                name: value,
              );
              if (result.ok && result.data != null) {
                await provider.loadShops(provider.item.accountBookId);
                return provider.shops.cast<AccountShop>().firstWhere(
                  (s) => s.name == value,
                );
              }
              return null;
            },
            onChanged: (value) async {
              if (value != null) {
                await provider.updateShopAndSave(value.code, value.name);
              } else {
                await provider.updateShopAndSave(null, null);
              }
            },
          ),
          SizedBox(height: spacing.formItemSpacing),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: [
                ...item.tags.map((tag) => Chip(
                  avatar: Icon(Icons.local_offer_outlined, size: 16),
                  label: Text(tag.name),
                  onDeleted: () {
                    final newTags = List<AccountSymbol>.from(item.tags)
                      ..removeWhere((t) => t.code == tag.code);
                    provider.updateTagsAndSave(newTags);
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )),
                ActionChip(
                  avatar: Icon(Icons.add, size: 16),
                  label: Text(L10nManager.l10n.tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    final options = provider.tags.cast<AccountSymbol>().map((t) =>
                      MultiSelectOption(key: t.code, name: t.name)).toList();
                    final selectedIds = item.tags.map((t) => t.code).toList();
                    final result = await MultiSelectSheet.show(
                      context,
                      title: L10nManager.l10n.tag,
                      options: options,
                      selectedIds: selectedIds,
                    );
                    if (result != null && context.mounted) {
                      final selectedTags = provider.tags.cast<AccountSymbol>()
                          .where((t) => result.contains(t.code))
                          .toList();
                      provider.updateTagsAndSave(selectedTags);
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
                      AppConfigManager.instance.userId,
                      provider.bookMeta.id,
                      name: value,
                      symbolType: SymbolType.project,
                    );
                    if (result.data != null) {
                      await provider.loadProjects();
                      return provider.projects
                          .cast<AccountSymbol>()
                          .firstWhere((project) => project.name == value);
                    }
                    return null;
                  },
                  onChanged: (value) async {
                    final project = value as AccountSymbol?;
                    if (project != null) {
                      await provider.updateProjectAndSave(
                          project.code, project.name);
                    } else {
                      await provider.updateProjectAndSave(null, null);
                    }
                  },
                ),
                CommonBadge(
                  icon: Icons.calendar_today_outlined,
                  text: _selectedDate,
                  onTap: _selectDate,
                  borderColor: colorScheme.outline.withAlpha(51),
                ),
                CommonBadge(
                  icon: Icons.access_time_outlined,
                  text: _selectedTime,
                  onTap: _selectTime,
                  borderColor: colorScheme.outline.withAlpha(51),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // === 备注 ===
          CommonTextFormField(
            initialValue: _descriptionController.text,
            labelText: L10nManager.l10n.description,
            hintText:
                L10nManager.l10n.pleaseInput(L10nManager.l10n.description),
            prefixIcon: const Icon(Icons.description_outlined),
            onChanged: (value) {
              _debounce(() => provider.updateDescriptionAndSave(value));
            },
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 9,
          ),
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
              await provider.updateAttachmentsAndSave(
                  [...provider.attachments, ...attachments]);
            },
            onDelete: (attachment) async {
              await provider.updateAttachmentsAndSave(
                provider.attachments
                    .where((a) => a.id != attachment.id)
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
