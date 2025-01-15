import 'package:flutter/material.dart';

import '../../manager/l10n_manager.dart';

/// 通用图标选择组件
class CommonIconPicker extends StatelessWidget {
  /// 图标列表
  final List<IconData> icons;

  /// 当前选中的图标代码
  final String? selectedIconCode;

  /// 图标选择回调
  final ValueChanged<String> onIconSelected;

  /// 图标大小
  final double? iconSize;

  /// 每行显示的图标数量
  final int crossAxisCount;

  /// 图标间距
  final double spacing;

  /// 是否显示取消按钮
  final bool showCancelButton;

  const CommonIconPicker({
    super.key,
    required this.icons,
    required this.selectedIconCode,
    required this.onIconSelected,
    this.iconSize,
    this.crossAxisCount = 5,
    this.spacing = 8,
    this.showCancelButton = true,
  });

  /// 显示图标选择对话框
  static Future<void> show({
    required BuildContext context,
    required List<IconData> icons,
    required String? selectedIconCode,
    required ValueChanged<String> onIconSelected,
    double? iconSize,
    int crossAxisCount = 5,
    double spacing = 8,
    bool showCancelButton = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(L10nManager.l10n.selectIcon),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: CommonIconPicker(
              icons: icons,
              selectedIconCode: selectedIconCode,
              onIconSelected: (iconCode) {
                onIconSelected(iconCode);
                Navigator.of(context).pop();
              },
              iconSize: iconSize,
              crossAxisCount: crossAxisCount,
              spacing: spacing,
              showCancelButton: false,
            ),
          ),
          actions: [
            if (showCancelButton)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final icon = icons[index];
        return _IconItem(
          icon: icon,
          selected: icon.codePoint.toString() == selectedIconCode,
          onTap: () => onIconSelected(icon.codePoint.toString()),
          size: iconSize,
        );
      },
    );
  }
}

/// 图标项组件
class _IconItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final double? size;

  const _IconItem({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: Icon(
          icon,
          color: selected ? colorScheme.primary : colorScheme.onSurface,
          size: size,
        ),
      ),
    );
  }
}
