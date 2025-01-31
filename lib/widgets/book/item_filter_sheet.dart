import 'package:flutter/material.dart';
import '../../enums/account_type.dart';
import '../../enums/symbol_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/book_meta.dart';
import '../common/common_bottom_sheet.dart';
import '../common/multi_select_dialog.dart';

/// 账目筛选底部弹出组件
class ItemFilterSheet extends StatefulWidget {
  /// 初始筛选条件
  final ItemFilterDTO? initialFilter;

  /// 确认回调
  final void Function(ItemFilterDTO filter)? onConfirm;

  /// 清空回调
  final VoidCallback? onClear;

  /// 当前选中的账本
  final BookMetaVO? selectedBook;

  const ItemFilterSheet({
    super.key,
    this.initialFilter,
    this.onConfirm,
    this.onClear,
    required this.selectedBook,
  });

  @override
  State<ItemFilterSheet> createState() => _ItemFilterSheetState();
}

class _ItemFilterSheetState extends State<ItemFilterSheet> {
  /// 筛选条件
  late ItemFilterDTO _filter;

  /// 金额下限控制器
  final TextEditingController _minAmountController = TextEditingController();

  /// 金额上限控制器
  final TextEditingController _maxAmountController = TextEditingController();

  /// 开始日期
  DateTime? _startDate;

  /// 结束日期
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // 初始化筛选条件
    _filter = widget.initialFilter ?? const ItemFilterDTO();
    
    // 初始化金额输入框
    _minAmountController.text = _filter.minAmount?.toString() ?? '';
    _maxAmountController.text = _filter.maxAmount?.toString() ?? '';
    
    // 初始化日期范围
    if (_filter.startDate != null) {
      _startDate = DateTime.parse(_filter.startDate!);
    }
    if (_filter.endDate != null) {
      _endDate = DateTime.parse(_filter.endDate!);
    }
  }

  @override
  void didUpdateWidget(ItemFilterSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 initialFilter 发生变化时更新状态
    if (widget.initialFilter != oldWidget.initialFilter) {
      setState(() {
        _filter = widget.initialFilter ?? const ItemFilterDTO();
        _minAmountController.text = _filter.minAmount?.toString() ?? '';
        _maxAmountController.text = _filter.maxAmount?.toString() ?? '';
        if (_filter.startDate != null) {
          _startDate = DateTime.parse(_filter.startDate!);
        } else {
          _startDate = null;
        }
        if (_filter.endDate != null) {
          _endDate = DateTime.parse(_filter.endDate!);
        } else {
          _endDate = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  /// 选择日期范围
  Future<void> _selectDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });
    }
  }

  /// 构建类型选择器
  Widget _buildTypeSelector(ThemeData theme) {
    final l10n = L10nManager.l10n;
    final types = _filter.types?.map((e) => AccountItemType.fromCode(e)).whereType<AccountItemType>().toList() ?? [];
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withAlpha(128)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '账目类型',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                FilterChip(
                  label: Text(l10n.expense),
                  selected: types.contains(AccountItemType.expense),
                  showCheckmark: false,
                  selectedColor: colorScheme.primaryContainer,
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: types.contains(AccountItemType.expense)
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      final currentTypes = _filter.types?.toList() ?? [];
                      if (selected) {
                        currentTypes.add(AccountItemType.expense.code);
                      } else {
                        currentTypes.remove(AccountItemType.expense.code);
                      }
                      _filter = _filter.copyWith(types: currentTypes);
                    });
                  },
                ),
                FilterChip(
                  label: Text(l10n.income),
                  selected: types.contains(AccountItemType.income),
                  showCheckmark: false,
                  selectedColor: colorScheme.primaryContainer,
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: types.contains(AccountItemType.income)
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      final currentTypes = _filter.types?.toList() ?? [];
                      if (selected) {
                        currentTypes.add(AccountItemType.income.code);
                      } else {
                        currentTypes.remove(AccountItemType.income.code);
                      }
                      _filter = _filter.copyWith(types: currentTypes);
                    });
                  },
                ),
                FilterChip(
                  label: Text(l10n.transfer),
                  selected: types.contains(AccountItemType.transfer),
                  showCheckmark: false,
                  selectedColor: colorScheme.primaryContainer,
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: types.contains(AccountItemType.transfer)
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      final currentTypes = _filter.types?.toList() ?? [];
                      if (selected) {
                        currentTypes.add(AccountItemType.transfer.code);
                      } else {
                        currentTypes.remove(AccountItemType.transfer.code);
                      }
                      _filter = _filter.copyWith(types: currentTypes);
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建金额范围选择器
  Widget _buildAmountRangeSelector(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monetization_on_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '金额范围',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '最小金额',
                    hintStyle: TextStyle(
                      color: colorScheme.outline,
                      fontSize: 14,
                    ),
                    prefixText: '¥',
                    prefixStyle: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                  onChanged: (value) {
                    final amount = double.tryParse(value);
                    setState(() {
                      _filter = _filter.copyWith(minAmount: amount);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '至',
                  style: TextStyle(
                    color: colorScheme.outline,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _maxAmountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '最大金额',
                    hintStyle: TextStyle(
                      color: colorScheme.outline,
                      fontSize: 14,
                    ),
                    prefixText: '¥',
                    prefixStyle: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                  ),
                  onChanged: (value) {
                    final amount = double.tryParse(value);
                    setState(() {
                      _filter = _filter.copyWith(maxAmount: amount);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建日期范围选择器
  Widget _buildDateRangeSelector(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: _selectDateRange,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '日期范围',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.outline,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
              child: Text(
                _startDate != null && _endDate != null
                    ? '${_startDate!.year}-${_startDate!.month}-${_startDate!.day} 至 ${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'
                    : '点击选择日期范围',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _startDate != null ? colorScheme.onSurface : colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建多选筛选项
  Widget _buildMultiSelector({
    required ThemeData theme,
    required String title,
    required List<String>? selectedItems,
    required List<MultiSelectOption> options,
    required IconData icon,
    required List<String> Function(List<String>?) onSelect,
  }) {
    final colorScheme = theme.colorScheme;
    final selectedOptions =
        options.where((o) => selectedItems?.contains(o.key) ?? false).toList();

    return InkWell(
      onTap: () async {
        final result = await showDialog<List<String>>(
          context: context,
          builder: (context) => MultiSelectDialog(
            title: title,
            options: options,
            selectedIds: selectedItems,
          ),
        );

        if (result != null) {
          onSelect(result);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  selectedItems?.isNotEmpty == true
                      ? '已选择 ${selectedItems!.length} 项'
                      : '点击选择',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: selectedItems?.isNotEmpty == true
                        ? colorScheme.onSurface
                        : colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.outline,
                ),
              ],
            ),
            if (selectedOptions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: selectedOptions
                    .map((option) => Chip(
                          label: Text(
                            option.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                          backgroundColor: colorScheme.secondaryContainer,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10nManager.l10n;

    return CommonBottomSheet(
      title: '筛选',
      showDivider: true,
      onConfirm: () {
        // 更新日期范围
        final filter = _filter.copyWith(
          startDate: _startDate?.toIso8601String(),
          endDate: _endDate?.toIso8601String(),
        );
        
        // 先回调，再关闭页面
        if (mounted && context.mounted) {
          widget.onConfirm?.call(filter);
          Navigator.of(context).pop();
        }
      },
      onClear: () {
        setState(() {
          // 清空所有筛选条件
          _filter = const ItemFilterDTO();
          _minAmountController.clear();
          _maxAmountController.clear();
          _startDate = null;
          _endDate = null;
        });
        // 先回调，再关闭页面
        if (mounted && context.mounted) {
          widget.onClear?.call();
          Navigator.of(context).pop();
        }
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 第一行：账目类型
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 账目类型
              SizedBox(
                width: 120,
                child: _buildTypeSelector(theme),
              ),
              const SizedBox(width: 12),
              // 右侧列
              Expanded(
                child: Column(
                  children: [
                    // 日期范围
                    _buildDateRangeSelector(theme),
                    const SizedBox(height: 12),
                    // 金额范围
                    _buildAmountRangeSelector(theme),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 分类选择器
          _buildMultiSelector(
            theme: theme,
            title: l10n.category,
            selectedItems: _filter.categoryCodes,
            options: widget.selectedBook?.categories
                    ?.map((e) => MultiSelectOption(
                          key: e.code,
                          name: e.name,
                        ))
                    .toList() ??
                [],
            onSelect: (codes) {
              setState(() {
                _filter = _filter.copyWith(categoryCodes: codes);
              });
              return codes ?? [];
            },
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 16),
          // 商户选择器
          _buildMultiSelector(
            theme: theme,
            title: l10n.merchant,
            selectedItems: _filter.shopCodes,
            options: widget.selectedBook?.shops
                    ?.map((e) => MultiSelectOption(
                          key: e.code,
                          name: e.name,
                        ))
                    .toList() ??
                [],
            onSelect: (codes) {
              setState(() {
                _filter = _filter.copyWith(shopCodes: codes);
              });
              return codes ?? [];
            },
            icon: Icons.store_outlined,
          ),
          const SizedBox(height: 16),
          // 账户选择器
          _buildMultiSelector(
            theme: theme,
            title: l10n.account,
            selectedItems: _filter.fundIds,
            options: widget.selectedBook?.funds
                    ?.map((e) => MultiSelectOption(
                          key: e.id,
                          name: e.name,
                          icon: Icons.account_balance_wallet_outlined,
                        ))
                    .toList() ??
                [],
            onSelect: (ids) {
              setState(() {
                _filter = _filter.copyWith(fundIds: ids);
              });
              return ids ?? [];
            },
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 16),
          // 项目选择器
          _buildMultiSelector(
            theme: theme,
            title: l10n.project,
            selectedItems: _filter.projectCodes,
            options: widget.selectedBook?.symbols
                    ?.where((e) =>
                        SymbolType.fromCode(e.symbolType) == SymbolType.project)
                    .map((e) => MultiSelectOption(
                          key: e.code,
                          name: e.name,
                        ))
                    .toList() ??
                [],
            onSelect: (codes) {
              setState(() {
                _filter = _filter.copyWith(projectCodes: codes);
              });
              return codes ?? [];
            },
            icon: Icons.folder_outlined,
          ),
          const SizedBox(height: 16),
          // 标签选择器
          _buildMultiSelector(
            theme: theme,
            title: l10n.tag,
            selectedItems: _filter.tagCodes,
            options: widget.selectedBook?.symbols
                    ?.where((e) =>
                        SymbolType.fromCode(e.symbolType) == SymbolType.tag)
                    .map((e) => MultiSelectOption(
                          key: e.code,
                          name: e.name,
                        ))
                    .toList() ??
                [],
            onSelect: (codes) {
              setState(() {
                _filter = _filter.copyWith(tagCodes: codes);
              });
              return codes ?? [];
            },
            icon: Icons.label_outlined,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
