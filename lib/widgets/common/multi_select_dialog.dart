import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';

/// 多选对话框选项
class MultiSelectOption {
  /// ID
  final String key;

  /// 名称
  final String name;

  /// 图标
  final IconData? icon;

  const MultiSelectOption({
    required this.key,
    required this.name,
    this.icon,
  });
}

/// 多选对话框
class MultiSelectDialog extends StatefulWidget {
  /// 标题
  final String title;

  /// 选项列表
  final List<MultiSelectOption> options;

  /// 已选择的ID列表
  final List<String>? selectedIds;

  const MultiSelectDialog({
    super.key,
    required this.title,
    required this.options,
    this.selectedIds,
  });

  @override
  State<MultiSelectDialog> createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  /// 已选择的ID列表
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedIds ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = L10nManager.l10n;

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.options.length,
          itemBuilder: (context, index) {
            final option = widget.options[index];
            final selected = _selectedIds.contains(option.key);

            return CheckboxListTile(
              value: selected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedIds.add(option.key);
                  } else {
                    _selectedIds.remove(option.key);
                  }
                });
              },
              title: Text(option.name),
              secondary: option.icon != null
                  ? Icon(
                      option.icon,
                      color: selected ? colorScheme.primary : colorScheme.outline,
                    )
                  : null,
              activeColor: colorScheme.primary,
              checkboxShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            l10n.cancel,
            style: TextStyle(color: colorScheme.outline),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_selectedIds),
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
} 