import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/account_type.dart';
import '../../enums/business_type.dart';
import '../../enums/symbol_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../providers/item_form_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/attachment.util.dart';
import '../../utils/color_util.dart';
import '../../utils/toast_util.dart';
import '../../widgets/book/animated_type_toggle.dart';
import '../../widgets/book/calculator_panel.dart';
import '../../widgets/common/common_attachment_field.dart';
import '../../widgets/common/common_badge.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_text_form_field.dart';

/// 新版账目表单组件
/// add 和 edit 页面共享此组件，通过 autoSave 区分行为
class ModernItemForm extends StatefulWidget {
  final ItemFormProvider provider;
  final bool autoSave;
  final bool autoFocusAmount;
  final VoidCallback? onSaved;

  const ModernItemForm({
    super.key,
    required this.provider,
    this.autoSave = false,
    this.autoFocusAmount = false,
    this.onSaved,
  });

  @override
  State<ModernItemForm> createState() => _ModernItemFormState();
}

class _ModernItemFormState extends State<ModernItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocusNode = FocusNode();
  late String _selectedDate;
  late String _selectedTime;
  Timer? _debounceTimer;

  /// 错落入场动画
  final List<bool> _sectionVisible = List.filled(6, false);

  @override
  void initState() {
    super.initState();
    final item = widget.provider.item;
    _amountController.text = item.amount.toString();
    _descriptionController.text = item.description ?? '';

    // 初始化日期和时间
    if (widget.provider.isNew) {
      final now = DateTime.now();
      _selectedDate = DateFormat('yyyy-MM-dd').format(now);
      _selectedTime = DateFormat('HH:mm').format(now);
      widget.provider.item.updateDateTime(_selectedDate, '$_selectedTime:00');
    } else {
      _selectedDate = item.accountDateOnly;
      _selectedTime = item.accountTimeOnly;
      widget.provider.loadAttachments();
    }

    // 自动聚焦金额（新增页面）
    if (widget.autoFocusAmount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCalculator();
      });
    }

    // 错落入场动画
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _sectionVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 80 * i), () {
          if (mounted) setState(() => _sectionVisible[i] = true);
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// 防抖
  void _debounce(VoidCallback callback) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), callback);
  }

  /// 打开金额计算器
  void _showCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalculatorPanel(
        initialValue:
            double.tryParse(_amountController.text)?.abs(),
        onConfirm: (value) {
          widget.provider.updateAmount(value);
          setState(() {
            _amountController.text =
                widget.provider.item.amount.toString();
          });
          if (widget.autoSave) {
            _debounce(() =>
                widget.provider.updateAmountAndSave(value));
          }
        },
      ),
    );
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
      _onDateTimeChanged();
    }
  }

  /// 选择时间
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      initialTime: TimeOfDay.fromDateTime(
        DateTime.parse('2024-01-01 $_selectedTime:00'),
      ),
    );

    if (picked != null) {
      setState(() {
        _selectedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
      _onDateTimeChanged();
    }
  }

  void _onDateTimeChanged() {
    if (widget.autoSave) {
      widget.provider.updateDateTimeAndSave(
          _selectedDate, '$_selectedTime:00');
    } else {
      widget.provider.item.updateDateTime(
          _selectedDate, '$_selectedTime:00');
    }
  }

  /// 类型切换回调
  void _onTypeChanged(AccountItemType newType) {
    final currentAmount =
        double.tryParse(_amountController.text) ?? 0;
    if (currentAmount != 0) {
      final currentType = AccountItemType.fromCode(
              widget.provider.item.type) ??
          AccountItemType.expense;
      if (currentType == AccountItemType.expense &&
          newType == AccountItemType.income) {
        _amountController.text = currentAmount.abs().toString();
      } else if (currentType == AccountItemType.income &&
          newType == AccountItemType.expense) {
        _amountController.text =
            (-currentAmount.abs()).toString();
      }
    }
    if (widget.autoSave) {
      widget.provider.updateTypeAndSave(newType);
      widget.provider.updateAmountAndSave(
          double.parse(_amountController.text));
    } else {
      widget.provider.updateType(newType);
      widget.provider.updateAmount(
          double.parse(_amountController.text));
    }
  }

  Color get _amountColor =>
      ColorUtil.getAmountColor(widget.provider.item.type);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final provider = widget.provider;
    final item = provider.item;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 区块 0: 类型切换 ──
          _buildAnimatedSection(
            index: 0,
            child: AnimatedTypeToggle(
              value: AccountItemType.fromCode(item.type) ??
                  AccountItemType.expense,
              onChanged: _onTypeChanged,
            ),
          ),

          SizedBox(height: spacing.formGroupSpacing),

          // ── 区块 1: 金额 ──
          _buildAnimatedSection(
            index: 1,
            child: _buildAmountSection(theme, colorScheme),
          ),

          SizedBox(height: spacing.formGroupSpacing),

          // ── 区块 2: 分类与账户 ──
          _buildAnimatedSection(
            index: 2,
            child: _buildCategoryAccountSection(
                theme, colorScheme, provider, item),
          ),

          SizedBox(height: spacing.formGroupSpacing),

          // ── 区块 3: 详细信息 ──
          _buildAnimatedSection(
            index: 3,
            child: _buildDetailsSection(
                theme, colorScheme, provider, item),
          ),

          SizedBox(height: spacing.formGroupSpacing),

          // ── 区块 4: 备注 ──
          _buildAnimatedSection(
            index: 4,
            child: _buildNotesSection(
                theme, colorScheme, provider),
          ),

          SizedBox(height: spacing.formGroupSpacing),

          // ── 区块 5: 保存按钮 (仅新增页面) ──
          if (!widget.autoSave)
            _buildAnimatedSection(
              index: 5,
              child: _buildSaveButton(theme, colorScheme, provider),
            ),

          SizedBox(height: spacing.formGroupSpacing),
        ],
      ),
    );
  }

  /// 错落动画包裹
  Widget _buildAnimatedSection({
    required int index,
    required Widget child,
  }) {
    return AnimatedOpacity(
      opacity: _sectionVisible[index] ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      child: child,
    );
  }

  /// 分割线标题
  Widget _buildSectionDivider({
    required IconData icon,
    required String title,
    required Color primary,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: primary.withAlpha(20)),
        ),
      ],
    );
  }

  /// 区块 1: 英雄金额
  Widget _buildAmountSection(
      ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _showCalculator,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: _amountColor,
                    ),
                    child: const Text('¥'),
                  ),
                  const SizedBox(width: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.w700,
                      color: _amountColor,
                      height: 1.1,
                    ),
                    child: Text(
                      _amountController.text.isEmpty
                          ? '0.00'
                          : _amountController.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              L10nManager.l10n.pleaseInput(L10nManager.l10n.amount),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 区块 2: 分类与账户
  Widget _buildCategoryAccountSection(ThemeData theme,
      ColorScheme colorScheme, ItemFormProvider provider, UserItemVO item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionDivider(
          icon: Icons.account_tree_outlined,
          title: L10nManager.l10n.basicInfo,
          primary: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        CommonSelectFormField<AccountCategory>(
          items: provider.categories
              .where((c) => c.categoryType == item.type)
              .toList()
              .cast<AccountCategory>(),
          value: item.categoryCode,
          displayMode: DisplayMode.expand,
          displayField: (e) => e.name,
          keyField: (e) => e.code,
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
                  .firstWhere((c) => c.name == value);
            }
            return null;
          },
          onChanged: (value) {
            final category = value as AccountCategory?;
            if (widget.autoSave) {
              provider.updateCategoryAndSave(
                  category?.code, category?.name);
            } else {
              provider.updateCategory(
                  category?.code, category?.name);
            }
          },
          validator: (v) =>
              v == null ? L10nManager.l10n.required : null,
        ),
        const SizedBox(height: 16),
        CommonSelectFormField<UserFundVO>(
          items: provider.funds.cast<UserFundVO>(),
          value: item.fundId,
          allowCreate: false,
          displayMode: DisplayMode.iconText,
          displayField: (e) => e.name,
          keyField: (e) => e.id,
          icon: Icons.account_balance_wallet_outlined,
          label: L10nManager.l10n.account,
          required: true,
          onChanged: (value) {
            final fund = value as UserFundVO?;
            if (widget.autoSave) {
              provider.updateFundAndSave(fund?.id, fund?.name);
            } else {
              provider.updateFund(fund?.id, fund?.name);
            }
          },
          validator: (v) =>
              v == null ? L10nManager.l10n.required : null,
        ),
        const SizedBox(height: 16),
        CommonSelectFormField<AccountShop>(
          items: provider.shops.cast<AccountShop>(),
          value:
              item.shopCode == 'NO_SHOP' ? null : item.shopCode,
          displayMode: DisplayMode.iconText,
          displayField: (e) => e.name,
          keyField: (e) => e.code,
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
              return provider.shops
                  .cast<AccountShop>()
                  .firstWhere((s) => s.name == value);
            }
            return null;
          },
          onChanged: (value) {
            final shop = value as AccountShop?;
            if (widget.autoSave) {
              provider.updateShopAndSave(shop?.code, shop?.name);
            } else {
              provider.updateShop(shop?.code, shop?.name);
            }
          },
        ),
      ],
    );
  }

  /// 区块 3: 详细信息
  Widget _buildDetailsSection(ThemeData theme,
      ColorScheme colorScheme, ItemFormProvider provider, UserItemVO item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionDivider(
          icon: Icons.label_outline,
          title: L10nManager.l10n.details,
          primary: colorScheme.primary,
        ),
        const SizedBox(height: 16),
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
                displayField: (e) => e.name,
                keyField: (e) => e.code,
                icon: Icons.local_offer_outlined,
                hint: L10nManager.l10n.tag,
                onCreateItem: (value) async {
                  final result =
                      await DriverFactory.driver.createSymbol(
                    AppConfigManager.instance.userId,
                    provider.bookMeta.id,
                    name: value,
                    symbolType: SymbolType.tag,
                  );
                  if (result.data != null) {
                    await provider.loadTags();
                    return provider.tags
                        .cast<AccountSymbol>()
                        .firstWhere((t) => t.name == value);
                  }
                  return null;
                },
                onChanged: (value) {
                  final tag = value as AccountSymbol?;
                  if (widget.autoSave) {
                    provider.updateTagAndSave(
                        tag?.code, tag?.name);
                  } else {
                    provider.updateTag(tag?.code, tag?.name);
                  }
                },
              ),
              CommonSelectFormField<AccountSymbol>(
                items: provider.projects.cast<AccountSymbol>(),
                value: item.projectCode,
                label: L10nManager.l10n.project,
                displayMode: DisplayMode.badge,
                displayField: (e) => e.name,
                keyField: (e) => e.code,
                icon: Icons.folder_outlined,
                hint: L10nManager.l10n.project,
                onCreateItem: (value) async {
                  final result =
                      await DriverFactory.driver.createSymbol(
                    AppConfigManager.instance.userId,
                    provider.bookMeta.id,
                    name: value,
                    symbolType: SymbolType.project,
                  );
                  if (result.data != null) {
                    await provider.loadProjects();
                    return provider.projects
                        .cast<AccountSymbol>()
                        .firstWhere((p) => p.name == value);
                  }
                  return null;
                },
                onChanged: (value) {
                  final project = value as AccountSymbol?;
                  if (widget.autoSave) {
                    provider.updateProjectAndSave(
                        project?.code, project?.name);
                  } else {
                    provider.updateProject(
                        project?.code, project?.name);
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
      ],
    );
  }

  /// 区块 4: 备注与附件
  Widget _buildNotesSection(ThemeData theme,
      ColorScheme colorScheme, ItemFormProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSectionDivider(
          icon: Icons.description_outlined,
          title: L10nManager.l10n.remark,
          primary: colorScheme.primary,
        ),
        const SizedBox(height: 16),
        CommonTextFormField(
          initialValue: _descriptionController.text,
          labelText: L10nManager.l10n.description,
          hintText: L10nManager.l10n
              .pleaseInput(L10nManager.l10n.description),
          prefixIcon: const Icon(Icons.description_outlined),
          onChanged: (value) {
            if (widget.autoSave) {
              _debounce(
                  () => provider.updateDescriptionAndSave(value));
            } else {
              provider.updateDescription(value);
            }
          },
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 9,
        ),
        const SizedBox(height: 16),
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
            final updated = [
              ...provider.attachments,
              ...attachments
            ];
            if (widget.autoSave) {
              await provider.updateAttachmentsAndSave(updated);
            } else {
              provider.updateAttachments(updated);
            }
          },
          onDelete: (attachment) async {
            final updated = provider.attachments
                .where((a) => a.id != attachment.id)
                .toList();
            if (widget.autoSave) {
              await provider.updateAttachmentsAndSave(updated);
            } else {
              provider.updateAttachments(updated);
            }
          },
        ),
      ],
    );
  }

  /// 保存按钮 (仅新增页面)
  Widget _buildSaveButton(ThemeData theme,
      ColorScheme colorScheme, ItemFormProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: provider.saving
            ? null
            : () async {
                if (_formKey.currentState?.validate() ?? false) {
                  if (await provider.create()) {
                    if (context.mounted) {
                      widget.onSaved?.call();
                    }
                  } else if (context.mounted &&
                      provider.error != null) {
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
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(
              horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
