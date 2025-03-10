import 'package:clsswjz/models/vo/user_fund_vo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_item_vo.dart';
import '../../providers/item_form_provider.dart';
import '../../utils/color_util.dart';
import '../../utils/toast_util.dart';
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
import '../../utils/file_util.dart';
import '../../widgets/book/amount_input.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_text_form_field.dart';
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
            onSelectionChanged: (Set<AccountItemType> selected) async {
              if (selected.isNotEmpty) {
                await provider.updateTypeAndSave(selected.first);
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
          AmountInput(
            controller: _amountController,
            color: ColorUtil.getAmountColor(item.type),
            onChanged: (value) {
              _debounce(() {
                provider.updateAmountAndSave(value);
              });
            },
          ),
          SizedBox(height: spacing.formItemSpacing),

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
                await provider.loadCategories();
                return provider.categories
                    .cast<AccountCategory>()
                    .firstWhere((category) => category.name == value);
              }
              return null;
            },
            onChanged: (value) async {
              final category = value as AccountCategory?;
              if (category != null) {
                await provider.updateCategoryAndSave(
                    category.code, category.name);
              } else {
                await provider.updateCategoryAndSave(null, null);
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
                AppConfigManager.instance.userId,
                provider.bookMeta.id,
                name: value,
              );
              if (result.data != null) {
                await provider.loadShops();
                final shop = provider.shops
                    .cast<AccountShop>()
                    .firstWhere((shop) => shop.name == value);
                await provider.updateShopAndSave(shop.code, shop.name);
                return shop;
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
            hintText:
                L10nManager.l10n.pleaseInput(L10nManager.l10n.description),
            prefixIcon: const Icon(Icons.description_outlined),
            onChanged: (value) {
              _debounce(() {
                provider.updateDescription(value);
              });
            },
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
            onTap: (attachment) async {
              final result = await FileUtil.openFile(attachment);
              if (!result.ok && mounted) {
                ToastUtil.showError(result.message ?? '打开文件失败');
              }
            },
          ),
          SizedBox(height: spacing.formItemSpacing),
        ],
      ),
    );
  }
}
