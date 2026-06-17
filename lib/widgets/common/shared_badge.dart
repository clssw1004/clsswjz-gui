import 'package:flutter/material.dart';

/// 共享徽章组件
class SharedBadge extends StatelessWidget {
  /// 用户名
  final String name;

  const SharedBadge({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: colorScheme.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontSize: 10,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
