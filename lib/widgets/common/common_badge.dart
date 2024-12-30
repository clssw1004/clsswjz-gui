import 'package:flutter/material.dart';

/// 通用徽章组件
class CommonBadge extends StatelessWidget {
  /// 图标
  final IconData? icon;

  /// 文本
  final String text;

  /// 点击事件
  final VoidCallback? onTap;

  /// 背景颜色
  final Color? backgroundColor;

  /// 文本颜色
  final Color? textColor;

  /// 图标颜色（不指定则使用文本颜色）
  final Color? iconColor;

  /// 边框颜色
  final Color? borderColor;

  /// 是否选中
  final bool selected;

  const CommonBadge({
    super.key,
    this.icon,
    required this.text,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderColor,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = backgroundColor ?? colorScheme.surface;
    final fgColor = textColor ??
        (selected
            ? colorScheme.onSecondaryContainer
            : colorScheme.onSurfaceVariant);
    final border = Border.all(
      color: borderColor ?? colorScheme.outline.withAlpha(51),
      width: 1,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: iconColor ?? fgColor,
                ),
                const SizedBox(width: 2),
              ],
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
