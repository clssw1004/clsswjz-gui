import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../theme/theme_radius.dart';
import 'selection_trigger.dart';
import 'tree_select/tree_select_sheet.dart';

/// 树形选择器（BottomSheet 展示树状连线层级），支持单选/多选
class TreeSelectFormField<T> extends FormField<dynamic> {
  final bool multiSelect;
  final bool showSearch;
  final bool cascadeSelect;
  final bool allowCreate;
  final Future<T?> Function(String value)? onCreateItem;
  final bool Function(T data)? isSelectableCheck;
  final Map<String, double>? scores;

  TreeSelectFormField({
    super.key,
    required List<TreeNode<T>> roots,
    dynamic value,
    required String Function(T) displayField,
    required String Function(T) idField,
    Set<String>? excludeIds,
    String? label,
    String? hint,
    this.multiSelect = false,
    this.showSearch = true,
    this.cascadeSelect = true,
    this.allowCreate = false,
    this.onCreateItem,
    this.isSelectableCheck,
    this.scores,
    ValueChanged<dynamic>? onChanged,
    super.validator,
  }) : super(
          initialValue: multiSelect
              ? (value is List ? List<String>.from(value) : <String>[])
              : value,
          builder: (state) {
            return _TreeSelectWidget<T>(
              roots: roots,
              value: multiSelect
                  ? (state.value is List
                      ? List<String>.from(state.value)
                      : <String>[])
                  : state.value,
              displayField: displayField,
              idField: idField,
              excludeIds: excludeIds ?? {},
              label: label,
              hint: hint,
              errorText: state.errorText,
              multiSelect: multiSelect,
              showSearch: showSearch,
              cascadeSelect: cascadeSelect,
              allowCreate: allowCreate,
              onCreateItem: onCreateItem,
              isSelectableCheck: isSelectableCheck,
              scores: scores,
              onChanged: (v) {
                state.didChange(v);
                if (onChanged != null) onChanged(v);
              },
            );
          },
        );
}

class _TreeSelectWidget<T> extends StatefulWidget {
  final List<TreeNode<T>> roots;
  final dynamic value;
  final String Function(T) displayField;
  final String Function(T) idField;
  final Set<String> excludeIds;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool multiSelect;
  final bool showSearch;
  final bool cascadeSelect;
  final bool allowCreate;
  final Future<T?> Function(String value)? onCreateItem;
  final bool Function(T data)? isSelectableCheck;
  final Map<String, double>? scores;
  final ValueChanged<dynamic>? onChanged;

  const _TreeSelectWidget({
    required this.roots,
    this.value,
    required this.displayField,
    required this.idField,
    this.excludeIds = const {},
    this.label,
    this.hint,
    this.errorText,
    this.multiSelect = false,
    this.showSearch = true,
    this.cascadeSelect = true,
    this.allowCreate = false,
    this.onCreateItem,
    this.isSelectableCheck,
    this.scores,
    this.onChanged,
  });

  @override
  State<_TreeSelectWidget<T>> createState() => _TreeSelectWidgetState<T>();
}

class _TreeSelectWidgetState<T> extends State<_TreeSelectWidget<T>> {
  String get _displayText {
    if (widget.multiSelect) {
      final ids = (widget.value is List
          ? List<String>.from(widget.value)
          : <String>[]);
      if (ids.isEmpty) return '';
      return L10nManager.l10n.treeSelectedCount(ids.length);
    }
    if (widget.value == null) return '';
    if (widget.value is T) return widget.displayField(widget.value as T);
    // 当 value 是 String code 时，从树中查找名称
    final flat = TreeBuilder.flatten(widget.roots);
    final found = flat
        .cast<TreeNode<dynamic>>()
        .where((n) =>
            widget.idField(n.data) == widget.value.toString())
        .firstOrNull;
    if (found != null) return widget.displayField(found.data as T);
    return widget.value.toString();
  }

  List<TreeNode<T>> get _filteredRoots {
    // apply excludeIds to tree roots
    List<TreeNode<T>> filterNodes(List<TreeNode<T>> nodes) {
      return nodes
          .where((n) =>
              !widget.excludeIds.contains(widget.idField(n.data)))
          .map((n) => n.copyWith(
              children: filterNodes(n.children)))
          .toList();
    }
    return filterNodes(widget.roots);
  }

  bool Function(T data)? get _effectiveSelectableCheck {
    if (widget.isSelectableCheck != null) return widget.isSelectableCheck;
    return (data) {
      try {
        return (data as dynamic).isBookkeepingSelectable ?? true;
      } catch (_) {
        return true;
      }
    };
  }

  Future<void> _showPicker() async {
    final check = _effectiveSelectableCheck;
    if (widget.multiSelect) {
      final result = await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              (Theme.of(context).extension<ThemeRadius>()?.radius ?? 12) * 1.5,
            ),
          ),
        ),
        builder: (ctx) => TreeSelectSheet<T>(
          filtered: _filteredRoots,
          displayField: widget.displayField,
          idField: widget.idField,
          multiSelect: true,
          label: widget.label,
          initialValue: widget.value,
          allowCreate: widget.allowCreate,
          onCreateItem: widget.onCreateItem,
          isSelectableCheck: check,
          scores: widget.scores,
        ),
      );
      if (result != null && mounted) {
        widget.onChanged?.call(result);
      }
    } else {
      final result = await showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              (Theme.of(context).extension<ThemeRadius>()?.radius ?? 12) * 1.5,
            ),
          ),
        ),
        builder: (ctx) => TreeSelectSheet<T>(
          filtered: _filteredRoots,
          displayField: widget.displayField,
          idField: widget.idField,
          multiSelect: false,
          label: widget.label,
          initialValue: widget.value,
          allowCreate: widget.allowCreate,
          onCreateItem: widget.onCreateItem,
          isSelectableCheck: check,
          scores: widget.scores,
        ),
      );
      if (result != null && mounted) {
        widget.onChanged?.call(result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SelectionTrigger(
      label: widget.label,
      hint: widget.hint ??
          (widget.multiSelect
              ? L10nManager.l10n.pleaseSelect('')
              : L10nManager.l10n.pleaseSelect('')),
      errorText: widget.errorText,
      displayText: _displayText,
      prefixIcon: Icons.account_tree_outlined,
      onTap: _showPicker,
    );
  }
}
