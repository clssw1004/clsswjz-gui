import 'package:flutter/material.dart';

class CommonTag extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final Color? color;
  final Color? backgroundColor;
  final bool outlined;

  const CommonTag({
    super.key,
    this.icon,
    this.label,
    this.color,
    this.backgroundColor,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tagColor = color ?? colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? null : (backgroundColor ?? tagColor.withAlpha(24)),
        borderRadius: BorderRadius.circular(8),
        border: outlined
            ? Border.all(
                color: tagColor.withAlpha(50),
                width: 1,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: tagColor,
            ),
            if (label != null) const SizedBox(width: 4),
          ],
          if (label != null)
            Text(
              label!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: tagColor,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
} 