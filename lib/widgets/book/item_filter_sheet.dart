import 'package:flutter/material.dart';
import '../../enums/account_type.dart';
import '../../enums/symbol_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/book_meta.dart';
import '../common/multi_select_dialog.dart';
import '../common/multi_select_sheet.dart';

/// 账目筛选底部弹出组件
class ItemFilterSheet extends StatefulWidget {
  final ItemFilterDTO? initialFilter;
  final void Function(ItemFilterDTO filter)? onConfirm;
  final VoidCallback? onClear;
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

// ── filter field types ──

enum _FilterFieldType { type, amount, date, category, merchant, account, project, tag }

IconData _fieldIcon(_FilterFieldType type) {
  switch (type) {
    case _FilterFieldType.type: return Icons.swap_horiz_rounded;
    case _FilterFieldType.amount: return Icons.attach_money_rounded;
    case _FilterFieldType.date: return Icons.calendar_today_rounded;
    case _FilterFieldType.category: return Icons.category_outlined;
    case _FilterFieldType.merchant: return Icons.store_outlined;
    case _FilterFieldType.account: return Icons.account_balance_wallet_outlined;
    case _FilterFieldType.project: return Icons.folder_outlined;
    case _FilterFieldType.tag: return Icons.label_outlined;
  }
}

String _fieldLabel(_FilterFieldType type) {
  final l10n = L10nManager.l10n;
  switch (type) {
    case _FilterFieldType.type: return '类型';
    case _FilterFieldType.amount: return '金额';
    case _FilterFieldType.date: return '日期';
    case _FilterFieldType.category: return l10n.category;
    case _FilterFieldType.merchant: return l10n.merchant;
    case _FilterFieldType.account: return l10n.account;
    case _FilterFieldType.project: return l10n.project;
    case _FilterFieldType.tag: return l10n.tag;
  }
}

// ── state ──

class _ItemFilterSheetState extends State<ItemFilterSheet> {
  late ItemFilterDTO _filter;
  final _minCtl = TextEditingController();
  final _maxCtl = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  final _activeFields = <_FilterFieldType>{};
  _FilterFieldType? _expandedField;
  final _scrollController = ScrollController();
  final _minFocusNode = FocusNode();
  final _maxFocusNode = FocusNode();

  static const _quickAmounts = [
    ('≤50', null, 50.0),
    ('50~100', 50.0, 100.0),
    ('100~500', 100.0, 500.0),
    ('500~1k', 500.0, 1000.0),
    ('≥1k', 1000.0, null),
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter ?? const ItemFilterDTO();
    _minCtl.text = _filter.minAmount?.toString() ?? '';
    _maxCtl.text = _filter.maxAmount?.toString() ?? '';
    if (_filter.startDate != null) _start = DateTime.parse(_filter.startDate!);
    if (_filter.endDate != null) _end = DateTime.parse(_filter.endDate!);
    _syncActiveFields();
    _minFocusNode.addListener(() { if (mounted) setState(() {}); });
    _maxFocusNode.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void didUpdateWidget(ItemFilterSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFilter != oldWidget.initialFilter) {
      _filter = widget.initialFilter ?? const ItemFilterDTO();
      _minCtl.text = _filter.minAmount?.toString() ?? '';
      _maxCtl.text = _filter.maxAmount?.toString() ?? '';
      _start = _filter.startDate != null ? DateTime.parse(_filter.startDate!) : null;
      _end = _filter.endDate != null ? DateTime.parse(_filter.endDate!) : null;
      _syncActiveFields();
    }
  }

  @override
  void dispose() {
    _minCtl.dispose();
    _maxCtl.dispose();
    _minFocusNode.dispose();
    _maxFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _syncActiveFields() {
    _activeFields.clear();
    if (_filter.types?.isNotEmpty == true) _activeFields.add(_FilterFieldType.type);
    if (_filter.categoryCodes?.isNotEmpty == true) _activeFields.add(_FilterFieldType.category);
    if (_filter.shopCodes?.isNotEmpty == true) _activeFields.add(_FilterFieldType.merchant);
    if (_filter.fundIds?.isNotEmpty == true) _activeFields.add(_FilterFieldType.account);
    if (_filter.projectCodes?.isNotEmpty == true) _activeFields.add(_FilterFieldType.project);
    if (_filter.tagCodes?.isNotEmpty == true) _activeFields.add(_FilterFieldType.tag);
    if (_filter.minAmount != null || _filter.maxAmount != null) _activeFields.add(_FilterFieldType.amount);
    if (_start != null) _activeFields.add(_FilterFieldType.date);
  }

  bool _isFieldActive(_FilterFieldType type) => _activeFields.contains(type);

  void _removeCondition(_FilterFieldType type) {
    // copyWith 无法将字段置 null（?? 回退实例值），需重建 DTO
    ItemFilterDTO cleared() => ItemFilterDTO(
          types: type == _FilterFieldType.type ? null : _filter.types,
          categoryCodes: type == _FilterFieldType.category ? null : _filter.categoryCodes,
          shopCodes: type == _FilterFieldType.merchant ? null : _filter.shopCodes,
          fundIds: type == _FilterFieldType.account ? null : _filter.fundIds,
          tagCodes: type == _FilterFieldType.tag ? null : _filter.tagCodes,
          projectCodes: type == _FilterFieldType.project ? null : _filter.projectCodes,
          minAmount: type == _FilterFieldType.amount ? null : _filter.minAmount,
          maxAmount: type == _FilterFieldType.amount ? null : _filter.maxAmount,
          startDate: _filter.startDate,
          endDate: _filter.endDate,
          source: _filter.source,
          sourceIds: _filter.sourceIds,
          keyword: _filter.keyword,
        );
    setState(() {
      _activeFields.remove(type);
      _filter = cleared();
      if (type == _FilterFieldType.amount) { _minCtl.clear(); _maxCtl.clear(); }
      if (type == _FilterFieldType.date) { _start = null; _end = null; }
    });
  }

  void _onFieldSelected(_FilterFieldType type) {
    if (_isFieldActive(type)) return;
    setState(() => _activeFields.add(type));
    // 多选字段添加后立即弹出选择器
    switch (type) {
      case _FilterFieldType.category:
      case _FilterFieldType.merchant:
      case _FilterFieldType.account:
      case _FilterFieldType.project:
      case _FilterFieldType.tag:
        WidgetsBinding.instance.addPostFrameCallback((_) => _openMultiSelectFor(type));
        break;
      default:
        break;
    }
  }

  List<MultiSelectOption> _optionsFor(_FilterFieldType type) {
    final book = widget.selectedBook;
    switch (type) {
      case _FilterFieldType.category:
        return book?.categories?.map((e) => MultiSelectOption(key: e.code, name: e.name)).toList() ?? [];
      case _FilterFieldType.merchant:
        return book?.shops?.map((e) => MultiSelectOption(key: e.code, name: e.name)).toList() ?? [];
      case _FilterFieldType.account:
        return book?.funds?.map((e) => MultiSelectOption(key: e.id, name: e.name, icon: Icons.account_balance_wallet_outlined)).toList() ?? [];
      case _FilterFieldType.project:
        return book?.symbols?.where((e) => SymbolType.fromCode(e.symbolType) == SymbolType.project)
            .map((e) => MultiSelectOption(key: e.code, name: e.name)).toList() ?? [];
      case _FilterFieldType.tag:
        return book?.symbols?.where((e) => SymbolType.fromCode(e.symbolType) == SymbolType.tag)
            .map((e) => MultiSelectOption(key: e.code, name: e.name)).toList() ?? [];
      default: return [];
    }
  }

  Future<void> _openMultiSelectFor(_FilterFieldType type) async {
    final options = _optionsFor(type);
    if (options.isEmpty) return;
    final List<String>? selectedIds;
    switch (type) {
      case _FilterFieldType.category: selectedIds = _filter.categoryCodes;
      case _FilterFieldType.merchant: selectedIds = _filter.shopCodes;
      case _FilterFieldType.account: selectedIds = _filter.fundIds;
      case _FilterFieldType.project: selectedIds = _filter.projectCodes;
      case _FilterFieldType.tag: selectedIds = _filter.tagCodes;
      default: return;
    }
    final result = await MultiSelectSheet.show(
      context, title: _fieldLabel(type), options: options, selectedIds: selectedIds);
    if (result != null && mounted) {
      setState(() {
        if (result.isEmpty) {
          _removeCondition(type);
        } else {
          switch (type) {
            case _FilterFieldType.category: _filter = _filter.copyWith(categoryCodes: result);
            case _FilterFieldType.merchant: _filter = _filter.copyWith(shopCodes: result);
            case _FilterFieldType.account: _filter = _filter.copyWith(fundIds: result);
            case _FilterFieldType.project: _filter = _filter.copyWith(projectCodes: result);
            case _FilterFieldType.tag: _filter = _filter.copyWith(tagCodes: result);
            default: break;
          }
        }
      });
    }
  }

  // ── helpers ──

  bool get _hasDate => _start != null && _end != null;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String? _activePreset() {
    if (!_hasDate) return 'all';
    final now = DateTime.now();
    if (_isSameDay(_start!, now.subtract(Duration(days: now.weekday - 1))) &&
        _isSameDay(_end!, now)) { return 'week'; }
    if (_start!.year == now.year && _start!.month == now.month && _start!.day == 1 &&
        _isSameDay(_end!, now)) { return 'month'; }
    if (_start!.year == now.year && _start!.month == 1 && _start!.day == 1 &&
        _isSameDay(_end!, now)) { return 'year'; }
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _setDatePreset(String key) {
    final now = DateTime.now();
    setState(() {
      switch (key) {
        case 'all': _start = null; _end = null; _activeFields.remove(_FilterFieldType.date);
        case 'week': _start = now.subtract(Duration(days: now.weekday - 1)); _end = now; _activeFields.add(_FilterFieldType.date);
        case 'month': _start = DateTime(now.year, now.month, 1); _end = now; _activeFields.add(_FilterFieldType.date);
        case 'year': _start = DateTime(now.year, 1, 1); _end = now; _activeFields.add(_FilterFieldType.date);
      }
    });
  }

  Future<void> _pickDate() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _hasDate ? DateTimeRange(start: _start!, end: _end!) : null,
    );
    if (r != null) setState(() { _start = r.start; _end = r.end; _activeFields.add(_FilterFieldType.date); });
  }

  void _setAmount(double? v, {bool isMin = true}) {
    final ctl = isMin ? _minCtl : _maxCtl;
    ctl.text = v?.toStringAsFixed(0) ?? '';
    setState(() {
      if (v == null) {
        _filter = ItemFilterDTO(
            types: _filter.types, categoryCodes: _filter.categoryCodes,
            shopCodes: _filter.shopCodes, fundIds: _filter.fundIds,
            tagCodes: _filter.tagCodes, projectCodes: _filter.projectCodes,
            minAmount: isMin ? null : _filter.minAmount,
            maxAmount: isMin ? _filter.maxAmount : null,
            startDate: _filter.startDate, endDate: _filter.endDate,
            source: _filter.source, sourceIds: _filter.sourceIds, keyword: _filter.keyword);
      } else {
        _filter = isMin ? _filter.copyWith(minAmount: v) : _filter.copyWith(maxAmount: v);
      }
      if (_filter.minAmount == null && _filter.maxAmount == null) {
        _activeFields.remove(_FilterFieldType.amount);
      } else {
        _activeFields.add(_FilterFieldType.amount);
      }
    });
  }

  // ── chip builders ──

  Widget _typeChip(ColorScheme cs, String label, String code, List<String> types) {
    final sel = types.contains(code);
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: sel,
      showCheckmark: false,
      onSelected: (v) {
        setState(() {
          final list = List<String>.from(types);
          v ? list.add(code) : list.remove(code);
          _filter = _filter.copyWith(types: list.isEmpty ? null : list);
          if (list.isEmpty) _activeFields.remove(_FilterFieldType.type);
        });
      },
      selectedColor: cs.primaryContainer,
      labelStyle: TextStyle(
        color: sel ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        fontWeight: sel ? FontWeight.w600 : FontWeight.normal),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _amtField(ThemeData t, TextEditingController c, String hint, void Function(double?) onChanged,
      {String? label, FocusNode? focusNode}) {
    final cs = t.colorScheme;
    return TextField(
      controller: c,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(fontSize: 13, color: cs.onSurface),
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        hintText: hint,
        hintStyle: TextStyle(color: cs.outline, fontSize: 12),
        prefixText: '¥ ',
        prefixStyle: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.w600),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.primary, width: 1.2)),
      ),
      onChanged: (v) => onChanged(double.tryParse(v)),
    );
  }

  Widget _amtChip(ColorScheme cs, String label, double? minVal, double? maxVal) {
    final matched = _filter.minAmount == minVal && _filter.maxAmount == maxVal;
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 11,
          fontWeight: matched ? FontWeight.w600 : FontWeight.normal,
          color: matched ? cs.onPrimaryContainer : cs.onSurfaceVariant)),
      onPressed: () => _setAmountRange(matched ? null : minVal, matched ? null : maxVal),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      side: BorderSide(color: matched ? cs.primary : cs.outlineVariant, width: matched ? 1.2 : 0.5),
      backgroundColor: matched ? cs.primaryContainer : Colors.transparent,
    );
  }

  /// 同时设置 min/max 完成一个完整金额筛选条件
  void _setAmountRange(double? min, double? max) {
    _minCtl.text = min?.toStringAsFixed(0) ?? '';
    _maxCtl.text = max?.toStringAsFixed(0) ?? '';
    setState(() {
      _filter = ItemFilterDTO(
          types: _filter.types, categoryCodes: _filter.categoryCodes,
          shopCodes: _filter.shopCodes, fundIds: _filter.fundIds,
          tagCodes: _filter.tagCodes, projectCodes: _filter.projectCodes,
          minAmount: min, maxAmount: max,
          startDate: _filter.startDate, endDate: _filter.endDate,
          source: _filter.source, sourceIds: _filter.sourceIds, keyword: _filter.keyword);
      if (min == null && max == null) {
        _activeFields.remove(_FilterFieldType.amount);
      } else {
        _activeFields.add(_FilterFieldType.amount);
      }
    });
  }

  Widget _dateChip(ColorScheme cs, String label, String key, bool selected) {
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      showCheckmark: false,
      onSelected: selected ? (_) => _setDatePreset('all') : (_) => _setDatePreset(key),
      selectedColor: cs.primaryContainer,
      labelStyle: TextStyle(
        color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildDatePickerRow(ThemeData t, ColorScheme cs, dynamic l10n) {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(children: [
          Expanded(child: Text(
              _hasDate ? '${_fmt(_start!)} — ${_fmt(_end!)}' : l10n.timeRangeCustom,
              style: TextStyle(fontSize: 12, color: _hasDate ? cs.onSurface : cs.outline))),
          if (_hasDate)
            GestureDetector(
              onTap: () => setState(() { _start = null; _end = null; _activeFields.remove(_FilterFieldType.date); }),
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(Icons.close, size: 13, color: cs.outline))),
        ]),
      ),
    );
  }

  // ── condition card editors ──

  Widget _buildFieldEditor(ThemeData t, _FilterFieldType type) {
    switch (type) {
      case _FilterFieldType.type: return _buildTypeEditor(t);
      case _FilterFieldType.amount: return _buildAmountEditor(t);
      case _FilterFieldType.date: return _buildDateEditor(t);
      case _FilterFieldType.category:
      case _FilterFieldType.merchant:
      case _FilterFieldType.account:
      case _FilterFieldType.project:
      case _FilterFieldType.tag:
        return _buildMultiSelectEditor(t, _filterValue(type), _optionsFor(type), () => _openMultiSelectFor(type));
    }
  }

  List<String>? _filterValue(_FilterFieldType type) {
    switch (type) {
      case _FilterFieldType.category: return _filter.categoryCodes;
      case _FilterFieldType.merchant: return _filter.shopCodes;
      case _FilterFieldType.account: return _filter.fundIds;
      case _FilterFieldType.project: return _filter.projectCodes;
      case _FilterFieldType.tag: return _filter.tagCodes;
      default: return null;
    }
  }

  Widget _buildTypeEditor(ThemeData t) {
    final l10n = L10nManager.l10n;
    final types = _filter.types ?? [];
    return Wrap(spacing: 6, runSpacing: 6, children: [
      _typeChip(t.colorScheme, l10n.expense, AccountItemType.expense.code, types),
      _typeChip(t.colorScheme, l10n.income, AccountItemType.income.code, types),
      _typeChip(t.colorScheme, l10n.transfer, AccountItemType.transfer.code, types),
    ]);
  }

  Widget _buildAmountEditor(ThemeData t) {
    final cs = t.colorScheme;
    final invalid = _filter.minAmount != null && _filter.maxAmount != null &&
        _filter.minAmount! > _filter.maxAmount!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _amtField(t, _minCtl, '选填', (v) => _setAmount(v, isMin: true),
            label: '最低', focusNode: _minFocusNode)),
        const SizedBox(width: 10),
        Expanded(child: _amtField(t, _maxCtl, '选填', (v) => _setAmount(v, isMin: false),
            label: '最高', focusNode: _maxFocusNode)),
      ]),
      if (invalid)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(children: [
            Icon(Icons.info_outline, size: 12, color: cs.error),
            const SizedBox(width: 4),
            Text('最低不能高于最高',
                style: TextStyle(fontSize: 11, color: cs.error)),
          ]),
        ),
      const SizedBox(height: 8),
      Wrap(spacing: 6, runSpacing: 4,
          children: _quickAmounts.map((a) => _amtChip(cs, a.$1, a.$2, a.$3)).toList()),
      const SizedBox(height: 4),
    ]);
  }

  Widget _buildDateEditor(ThemeData t) {
    final l10n = L10nManager.l10n;
    final cs = t.colorScheme;
    final active = _activePreset();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 6, runSpacing: 4, children: [
        _dateChip(cs, l10n.timeRangeAll, 'all', active == 'all'),
        _dateChip(cs, l10n.timeRangeWeek, 'week', active == 'week'),
        _dateChip(cs, l10n.timeRangeMonth, 'month', active == 'month'),
        _dateChip(cs, l10n.timeRangeYear, 'year', active == 'year'),
      ]),
      const SizedBox(height: 6),
      _buildDatePickerRow(t, cs, l10n),
    ]);
  }

  Widget _buildMultiSelectEditor(ThemeData t, List<String>? selectedIds,
      List<MultiSelectOption> options, VoidCallback onTap) {
    final cs = t.colorScheme;
    final selected = options.where((o) => selectedIds?.contains(o.key) ?? false).toList();
    if (selected.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Icon(Icons.add_rounded, size: 16, color: cs.outline),
            const SizedBox(width: 4),
            Text('请选择', style: TextStyle(fontSize: 13, color: cs.outline)),
          ]),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Wrap(spacing: 6, runSpacing: 6,
          children: selected.map((opt) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(16)),
            child: Text(opt.name,
                style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer, fontWeight: FontWeight.w500)),
          )).toList()),
    );
  }

  // ── condition card ──

  bool _isInlineType(_FilterFieldType type) =>
      type == _FilterFieldType.type ||
      type == _FilterFieldType.amount ||
      type == _FilterFieldType.date;

  Widget _buildConditionTile(ThemeData t, _FilterFieldType type) {
    final cs = t.colorScheme;
    final isExpanded = _expandedField == type;
    final isInline = _isInlineType(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                if (isInline) {
                  setState(() => _expandedField = isExpanded ? null : type);
                } else {
                  _openMultiSelectFor(type);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
                child: Row(children: [
                  Icon(_fieldIcon(type),
                      size: 16, color: cs.primary.withAlpha(180)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildCompactSummary(t, type)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _removeCondition(type),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      child: Icon(Icons.close_rounded,
                          size: 16, color: cs.outline)),
                  ),
                ]),
              ),
            ),
            if (isExpanded && isInline)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: _buildFieldEditor(t, type),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSummary(ThemeData t, _FilterFieldType type) {
    final cs = t.colorScheme;
    final l10n = L10nManager.l10n;

    switch (type) {
      case _FilterFieldType.type: {
        final types = _filter.types ?? [];
        if (types.isEmpty) return _hintText(cs);
        return Text(
          types.map((code) =>
              code == AccountItemType.expense.code ? l10n.expense :
              code == AccountItemType.income.code ? l10n.income :
              l10n.transfer).join(' · '),
          style: TextStyle(fontSize: 13, color: cs.onSurface,
              fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        );
      }
      case _FilterFieldType.amount: {
        final minStr = _filter.minAmount?.toStringAsFixed(0);
        final maxStr = _filter.maxAmount?.toStringAsFixed(0);
        if (minStr == null && maxStr == null) return _hintText(cs);
        return Text(
          minStr != null && maxStr != null
              ? '¥$minStr — ¥$maxStr'
              : maxStr != null
                  ? '≤ ¥$maxStr'
                  : '≥ ¥$minStr',
          style: TextStyle(fontSize: 13, color: cs.onSurface,
              fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis);
      }
      case _FilterFieldType.date: {
        if (!_hasDate) return _hintText(cs);
        final preset = _activePreset();
        if (preset != null && preset != 'all') {
          return Text(
            preset == 'week' ? l10n.timeRangeWeek :
            preset == 'month' ? l10n.timeRangeMonth :
            l10n.timeRangeYear,
            style: TextStyle(fontSize: 13, color: cs.onSurface,
                fontWeight: FontWeight.w500),
          );
        }
        return Text('${_fmt(_start!)} — ${_fmt(_end!)}',
            style: TextStyle(fontSize: 13, color: cs.onSurface,
                fontWeight: FontWeight.w500));
      }
      default: {
        final names = _optionsFor(type)
            .where((o) => _filterValue(type)?.contains(o.key) ?? false)
            .map((o) => o.name).toList();
        if (names.isEmpty) return _hintText(cs);
        return Text(
          names.join(' · '),
          style: TextStyle(fontSize: 13, color: cs.onSurface,
              fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        );
      }
    }
  }

  Widget _hintText(ColorScheme cs) =>
      Text('点击设置', style: TextStyle(fontSize: 13, color: cs.outline));

  // ── add condition button ──

  Widget _buildAddConditionButton(ThemeData t) {
    final cs = t.colorScheme;
    return PopupMenuButton<_FilterFieldType>(
      onSelected: (type) => _onFieldSelected(type),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      color: cs.surface,
      position: PopupMenuPosition.over,
      itemBuilder: (_) => _FilterFieldType.values.map((type) {
        final active = _isFieldActive(type);
        return PopupMenuItem<_FilterFieldType>(
          value: type,
          height: 40,
          child: Row(children: [
            Icon(_fieldIcon(type), size: 16,
                color: active ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(_fieldLabel(type),
                style: TextStyle(
                  fontSize: 13,
                  color: active ? cs.primary : cs.onSurface,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                )),
            if (active) ...[
              const Spacer(),
              Icon(Icons.check_circle_rounded, size: 16, color: cs.primary),
            ],
          ]),
        );
      }).toList(),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: null,
          icon: const Icon(Icons.add_rounded, size: 16),
          label: const Text('添加筛选条件', style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.primary,
            side: BorderSide(color: cs.outlineVariant),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size.fromHeight(38),
            padding: const EdgeInsets.symmetric(vertical: 6),
          ),
        ),
      ),
    );
  }

  // ── build ──

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final l10n = L10nManager.l10n;

    void handleConfirm() {
      final f = _filter.copyWith(startDate: _start?.toIso8601String(), endDate: _end?.toIso8601String());
      final cleaned = ItemFilterDTO(
        types: f.types?.isEmpty == true ? null : f.types,
        categoryCodes: f.categoryCodes?.isEmpty == true ? null : f.categoryCodes,
        shopCodes: f.shopCodes?.isEmpty == true ? null : f.shopCodes,
        fundIds: f.fundIds?.isEmpty == true ? null : f.fundIds,
        tagCodes: f.tagCodes?.isEmpty == true ? null : f.tagCodes,
        projectCodes: f.projectCodes?.isEmpty == true ? null : f.projectCodes,
        minAmount: f.minAmount, maxAmount: f.maxAmount,
        startDate: f.startDate, endDate: f.endDate,
        source: f.source, sourceIds: f.sourceIds, keyword: f.keyword,
      );
      if (mounted && context.mounted) {
        widget.onConfirm?.call(cleaned);
        Navigator.of(context).pop();
      }
    }

    void handleClear() {
      setState(() {
        _filter = const ItemFilterDTO();
        _minCtl.clear(); _maxCtl.clear();
        _start = null; _end = null;
        _activeFields.clear();
      });
      if (mounted && context.mounted) {
        widget.onClear?.call();
        Navigator.of(context).pop();
      }
    }

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.66),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(children: [
        // 拖拽手柄
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withAlpha(50),
              borderRadius: BorderRadius.circular(2))),
        ),

        // 顶栏: 清空 — 标题 — 确认
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(children: [
            TextButton(
              onPressed: handleClear,
              style: TextButton.styleFrom(
                foregroundColor: cs.outline,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
              child: Text(l10n.clear)),
            const Spacer(),
            Text('筛选', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            FilledButton(
              onPressed: handleConfirm,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10)),
              child: Text(l10n.confirm)),
          ]),
        ),

        Divider(height: 1, color: cs.outlineVariant),

        // 可滚动内容 + 底部添加按钮
        Expanded(
          child: Column(children: [
            // 条件卡片区（可滚动）
            Expanded(
              child: _activeFields.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.filter_alt_outlined, size: 36, color: cs.outlineVariant),
                          const SizedBox(height: 8),
                          Text('暂无筛选条件', style: TextStyle(fontSize: 14, color: cs.outline)),
                        ],
                      ),
                    )
                  : ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      children: _FilterFieldType.values
                          .where((f) => _isFieldActive(f))
                          .map((f) => _buildConditionTile(t, f))
                          .toList(),
                    ),
            ),
            // 添加按钮固定在底部
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: _buildAddConditionButton(t),
            ),
          ]),
        ),
      ]),
    );
  }
}
