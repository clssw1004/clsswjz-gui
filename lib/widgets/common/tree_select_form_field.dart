import 'package:flutter/material.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../theme/theme_radius.dart';

/// 树形选择器（BottomSheet 展示层级缩进列表）
class TreeSelectFormField<T> extends FormField<T?> {
  TreeSelectFormField({
    super.key,
    required List<TreeNode<T>> roots,
    T? value,
    required String Function(T) displayField,
    required String Function(T) idField,
    Set<String>? excludeIds, // 排除这些 ID 的节点（移动时排除自身+子孙）
    String? label,
    String? hint,
    ValueChanged<T?>? onChanged,
    super.validator,
  }) : super(
          initialValue: value,
          builder: (state) {
            return _TreeSelectWidget<T>(
              roots: roots,
              value: value,
              displayField: displayField,
              idField: idField,
              excludeIds: excludeIds ?? {},
              label: label,
              hint: hint,
              errorText: state.errorText,
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
  final T? value;
  final String Function(T) displayField;
  final String Function(T) idField;
  final Set<String> excludeIds;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<T?>? onChanged;

  const _TreeSelectWidget({
    required this.roots,
    this.value,
    required this.displayField,
    required this.idField,
    this.excludeIds = const {},
    this.label,
    this.hint,
    this.errorText,
    this.onChanged,
  });

  @override
  State<_TreeSelectWidget<T>> createState() => _TreeSelectWidgetState<T>();
}

class _TreeSelectWidgetState<T> extends State<_TreeSelectWidget<T>> {
  T? get _selectedItem => widget.value;

  String get _displayText {
    if (_selectedItem == null) return widget.hint ?? '请选择';
    return widget.displayField(_selectedItem as T);
  }

  Future<void> _showPicker() async {
    final radius = Theme.of(context).extension<ThemeRadius>()?.radius ?? 12;
    final screenH = MediaQuery.of(context).size.height;

    // 扁平化树，排除 excludeIds 中的节点
    final allNodes = TreeBuilder.flatten(widget.roots);
    final filtered = allNodes
        .where((n) => !widget.excludeIds.contains(widget.idField(n.data)))
        .toList();

    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
      ),
      builder: (ctx) {
        final localColor = Theme.of(ctx).colorScheme;
        final localRadius =
            Theme.of(ctx).extension<ThemeRadius>()?.radius ?? 12;

        return Container(
          constraints: BoxConstraints(
            maxHeight: screenH * 0.8,
            minHeight: 300,
          ),
          decoration: BoxDecoration(
            color: localColor.surface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(localRadius * 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示条
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 2),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: localColor.onSurfaceVariant.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // 标题
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Icon(Icons.account_tree_outlined,
                        size: 18, color: localColor.primary),
                    const SizedBox(width: 8),
                    Text(
                      widget.label ?? '选择',
                      style: Theme.of(ctx)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: localColor.outline.withAlpha(20)),
              if (filtered.isEmpty)
                const Expanded(
                  child: Center(child: Text('无可选项')),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    children: filtered.map((node) {
                      final isSelected = widget.value != null &&
                          widget.idField(node.data) ==
                              widget.idField(widget.value as T);
                      return Padding(
                        padding: EdgeInsets.only(left: node.level * 24.0),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? localColor.primary.withAlpha(10)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            leading: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? localColor.primary
                                    : localColor.outline.withAlpha(40),
                              ),
                            ),
                            title: Text(
                              widget.displayField(node.data),
                              style: Theme.of(ctx)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : null,
                                    color: isSelected
                                        ? localColor.primary
                                        : null,
                                  ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle_rounded,
                                    color: localColor.primary, size: 22)
                                : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onTap: () => Navigator.of(ctx).pop(node.data),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      widget.onChanged?.call(result);
    }
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
        hintText: _selectedItem == null
            ? (widget.hint ?? '请选择')
            : null,
        errorText: widget.errorText,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(30),
        prefixIcon: const Icon(Icons.account_tree_outlined, size: 20),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: BorderSide(
            color: colorScheme.primary.withAlpha(120),
            width: 1.5,
          ),
        ),
      ),
      controller: TextEditingController(text: _displayText),
      style: theme.textTheme.bodyLarge,
    );
  }
}
