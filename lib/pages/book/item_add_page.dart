import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../providers/item_form_provider.dart';
import '../../utils/toast_util.dart';
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
import '../../widgets/common/common_badge.dart';
import '../../widgets/common/common_attachment_field.dart';
import '../../utils/color_util.dart';

class ItemAddPage extends StatelessWidget {
  final BookMetaVO bookMeta;
  final UserItemVO? item;

  const ItemAddPage({
    super.key,
    required this.bookMeta,
    this.item,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;

    return ChangeNotifierProvider(
      create: (context) => ItemFormProvider(bookMeta, item),
      child: Consumer<ItemFormProvider>(
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
  final ItemFormProvider provider;
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
      // 预填日期时间或使用当前时间
      final itemDate = widget.provider.item.accountDate;
      if (itemDate.contains(' ')) {
        // 已有预填的日期时间
        _selectedDate = itemDate.split(' ')[0];
        final timePart = itemDate.split(' ')[1];
        _selectedTime = timePart.length >= 5 ? timePart.substring(0, 5) : '00:00';
      } else {
        final now = DateTime.now();
        _selectedDate = DateFormat('yyyy-MM-dd').format(now);
        _selectedTime = DateFormat('HH:mm').format(now);
        widget.provider.item.updateDateTime(_selectedDate, '$_selectedTime:00');
      }

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
      _selectedTime = widget.provider.item.accountTimeOnly; // 只显示HH:mm

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
    final currentType =
        AccountItemType.fromCode(item.type) ?? AccountItemType.expense;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // === 账本 ===
          _buildBookSection(theme, colorScheme, provider, item),

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
            onSelectionChanged: (Set<AccountItemType> selected) {
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
                provider.updateType(newType);
                provider.updateAmount(double.parse(_amountController.text));
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
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus) provider.partUpdate();
            },
            child: AmountInput(
              controller: _amountController,
              focusNode: _amountFocusNode,
              color: ColorUtil.getAmountColor(item.type),
              onChanged: (value) => provider.updateAmount(value),
            ),
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // === 分类 ===
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
            label: L10nManager.l10n.category,
            required: true,
            expandCount: 8,
            expandRows: 3,
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
                    .firstWhere((category) => category.name == value);
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
              if (value == null) return L10nManager.l10n.required;
              return null;
            },
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // === 账户与标签 ===
          CommonSelectFormField<UserFundVO>(
            items: provider.funds.cast<UserFundVO>(),
            value: item.fundId,
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
                provider.updateFund(fund.id, fund.name);
              } else {
                provider.updateFund(null, null);
              }
            },
            validator: (value) {
              if (value == null) return L10nManager.l10n.required;
              return null;
            },
          ),
          SizedBox(height: spacing.formItemSpacing),
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
                AppConfigManager.instance.userId,
                provider.bookMeta.id,
                name: value,
              );
              if (result.data != null) {
                await provider.loadShops(provider.bookMeta.id);
                return provider.shops
                    .cast<AccountShop>()
                    .firstWhere((shop) => shop.name == value);
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
                      AppConfigManager.instance.userId,
                      provider.bookMeta.id,
                      name: value,
                      symbolType: SymbolType.tag,
                    );
                    if (result.data != null) {
                      await provider.loadTags();
                      return provider.tags
                          .cast<AccountSymbol>()
                          .firstWhere((tag) => tag.name == value);
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
                  onChanged: (value) {
                    final project = value as AccountSymbol?;
                    if (project != null) {
                      provider.updateProject(project.code, project.name);
                    } else {
                      provider.updateProject(null, null);
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
            onChanged: provider.updateDescription,
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
              provider
                  .updateAttachments([...provider.attachments, ...attachments]);
            },
            onDelete: (attachment) async {
              provider.updateAttachments(
                provider.attachments
                    .where((a) => a.id != attachment.id)
                    .toList(),
              );
            },
          ),

          // 保存按钮
          SizedBox(height: spacing.formGroupSpacing),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing.formItemSpacing),
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
                padding:
                    EdgeInsets.symmetric(horizontal: spacing.formItemSpacing * 2, vertical: spacing.formItemSpacing),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 账本选择行
  Widget _buildBookSection(ThemeData theme, ColorScheme colorScheme,
      ItemFormProvider provider, UserItemVO item) {
    final isNew = provider.isNew;
    final book = provider.currentBook;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: isNew ? () => _showBookPicker(provider) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          border: isNew
              ? Border.all(color: colorScheme.outlineVariant.withAlpha(80))
              : null,
        ),
        child: Row(
          children: [
            Icon(Icons.book_outlined, size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                book?.name ?? L10nManager.l10n.noAccountBooks,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isNew)
              Icon(Icons.chevron_right,
                  size: 20, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Future<void> _showBookPicker(ItemFormProvider provider) async {
    final books = provider.allBooks;
    if (books.isEmpty) return;

    final book = await showModalBottomSheet<UserBookVO>(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _OldBookPickerSheet(
        books: books,
        selectedId: provider.item.accountBookId,
      ),
    );
    if (book != null && mounted) {
      provider.changeBook(book);
    }
  }
}

/// 账本选择面板（旧版表单）
class _OldBookPickerSheet extends StatelessWidget {
  final List<UserBookVO> books;
  final String? selectedId;

  const _OldBookPickerSheet({required this.books, this.selectedId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    L10nManager.l10n.selectAccountBook,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              shrinkWrap: true,
              children: books.map((book) {
                final selected = book.id == selectedId;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primary.withAlpha(10)
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      leading: Icon(
                        Icons.book_outlined,
                        size: 22,
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.outline.withAlpha(60),
                      ),
                      title: Text(
                        book.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w600 : null,
                          color: selected
                              ? colorScheme.primary
                              : null,
                        ),
                      ),
                      trailing: selected
                          ? Icon(Icons.check_circle_rounded,
                              size: 22, color: colorScheme.primary)
                          : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onTap: () => Navigator.of(context).pop(book),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
