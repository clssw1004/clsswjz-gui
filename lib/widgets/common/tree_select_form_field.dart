import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../theme/theme_radius.dart';

/// 树形选择器（BottomSheet 展示层级缩进列表），支持单选/多选
class TreeSelectFormField<T> extends FormField<dynamic> {
  /// 是否多选模式（true 时 value 为 List<String>，false 时为 T?）
  final bool multiSelect;

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
                  ? (state.value is List ? List<String>.from(state.value) : <String>[])
                  : state.value,
              displayField: displayField,
              idField: idField,
              excludeIds: excludeIds ?? {},
              label: label,
              hint: hint,
              errorText: state.errorText,
              multiSelect: multiSelect,
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
  final dynamic value; // T? for single, List<String> for multi
  final String Function(T) displayField;
  final String Function(T) idField;
  final Set<String> excludeIds;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool multiSelect;
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
    this.onChanged,
  });

  @override
  State<_TreeSelectWidget<T>> createState() => _TreeSelectWidgetState<T>();
}

class _TreeSelectWidgetState<T> extends State<_TreeSelectWidget<T>> {
  // For multi-select: temp selection set during picker
  Set<String> _tempSelected = {};

  String get _displayText {
    if (widget.multiSelect) {
      final ids = (widget.value is List ? List<String>.from(widget.value) : <String>[]);
      if (ids.isEmpty) return widget.hint ?? L10nManager.l10n.pleaseSelect('');
      return '已选 ${ids.length} 项';
    }
    if (widget.value == null) return widget.hint ?? L10nManager.l10n.pleaseSelect('');
    return widget.displayField(widget.value as T);
  }

  Future<void> _showPicker() async {
    final radius = Theme.of(context).extension<ThemeRadius>()?.radius ?? 12;
    final screenH = MediaQuery.of(context).size.height;

    final allNodes = TreeBuilder.flatten(widget.roots);
    final filtered = allNodes
        .where((n) => !widget.excludeIds.contains(widget.idField(n.data)))
        .toList();

    // Initialize temp selection for multi-select
    if (widget.multiSelect) {
      _tempSelected = Set<String>.from(
        widget.value is List ? List<String>.from(widget.value) : <String>[],
      );
    }

    if (widget.multiSelect) {
      // Multi-select mode
      await _showMultiPicker(radius, screenH, filtered);
    } else {
      // Single-select mode (existing)
      final result = await _showSinglePicker(radius, screenH, filtered);
      if (result != null && mounted) {
        widget.onChanged?.call(result);
      }
    }
  }

  Future<T?> _showSinglePicker(double radius, double screenH, List<TreeNode<T>> filtered) async {
    final localColor = Theme.of(context).colorScheme;
    final localRadius = Theme.of(context).extension<ThemeRadius>()?.radius ?? 12;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.8, minHeight: 300),
        decoration: BoxDecoration(
          color: localColor.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(localRadius * 1.5)),
        ),
        child: _buildSheetContent(ctx, filtered, localColor, localRadius),
      ),
    );
  }

  Future<void> _showMultiPicker(double radius, double screenH, List<TreeNode<T>> filtered) async {
    final localColor = Theme.of(context).colorScheme;
    final localRadius = Theme.of(context).extension<ThemeRadius>()?.radius ?? 12;

    await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            final lc = Theme.of(ctx).colorScheme;
            final lr = Theme.of(ctx).extension<ThemeRadius>()?.radius ?? 12;
            return Container(
              constraints: BoxConstraints(maxHeight: screenH * 0.8, minHeight: 300),
              decoration: BoxDecoration(
                color: lc.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(lr * 1.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(ctx, lc),
                  Divider(height: 1, color: lc.outline.withAlpha(20)),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(child: Text(L10nManager.l10n.treeNoOptions))
                        : ListView(
                            padding: const EdgeInsets.only(top: 4, bottom: 80),
                            children: filtered.map((node) {
                              final id = widget.idField(node.data);
                              final checked = _tempSelected.contains(id);
                              return Padding(
                                padding: EdgeInsets.only(left: node.level * 24.0),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                    leading: Icon(
                                      checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                                      size: 22,
                                      color: checked ? lc.primary : lc.outline,
                                    ),
                                    title: Text(
                                      widget.displayField(node.data),
                                      style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                                            fontWeight: checked ? FontWeight.w600 : null,
                                          ),
                                    ),
                                    onTap: () {
                                      setLocalState(() {
                                        if (checked) {
                                          _tempSelected.remove(id);
                                        } else {
                                          _tempSelected.add(id);
                                        }
                                      });
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  // Bottom actions
                  Container(
                    decoration: BoxDecoration(
                      color: lc.surface,
                      border: Border(top: BorderSide(color: lc.outline.withAlpha(20))),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(L10nManager.l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: () {
                                Navigator.pop(ctx, _tempSelected);
                              },
                              child: Text(L10nManager.l10n.treeSelectedCount(_tempSelected.length)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result != null && mounted) {
        widget.onChanged?.call(result.toList());
      }
    });
  }

  Widget _buildSheetContent(BuildContext ctx, List<TreeNode<T>> filtered,
      ColorScheme localColor, double localRadius) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(ctx, localColor),
        Divider(height: 1, color: localColor.outline.withAlpha(20)),
        if (filtered.isEmpty)
          Expanded(child: Center(child: Text(L10nManager.l10n.treeNoOptions)))
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              children: filtered.map((node) {
                final isSelected = widget.value != null &&
                    widget.idField(node.data) == widget.idField(widget.value as T);
                return Padding(
                  padding: EdgeInsets.only(left: node.level * 24.0),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? localColor.primary.withAlpha(10) : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      leading: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? localColor.primary : localColor.outline.withAlpha(40),
                        ),
                      ),
                      title: Text(
                        widget.displayField(node.data),
                        style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : null,
                              color: isSelected ? localColor.primary : null,
                            ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: localColor.primary, size: 22)
                          : null,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onTap: () => Navigator.of(ctx).pop(node.data),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext ctx, ColorScheme localColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 2),
          child: Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: localColor.onSurfaceVariant.withAlpha(50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Icon(Icons.account_tree_outlined, size: 18, color: localColor.primary),
              const SizedBox(width: 8),
              Text(
                widget.label ?? '选择',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (widget.multiSelect)
                Text(' (可多选)', style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                  color: localColor.onSurfaceVariant,
                )),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;

    return TextFormField(
      readOnly: true,
      onTap: _showPicker,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.multiSelect
            ? (widget.hint ?? '${L10nManager.l10n.pleaseSelect('')}${L10nManager.l10n.treeMultiSelectHint}')
            : (widget.hint ?? L10nManager.l10n.pleaseSelect('')),
        errorText: widget.errorText,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(30),
        prefixIcon: const Icon(Icons.account_tree_outlined, size: 20),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(60)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.primary.withAlpha(120), width: 1.5),
        ),
      ),
      controller: TextEditingController(text: _displayText),
      style: theme.textTheme.bodyLarge,
    );
  }
}
