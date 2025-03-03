import 'package:flutter/material.dart';

/// 通用的空状态视图
class CommonEmptyView extends StatelessWidget {
  /// 空状态消息
  final String message;

  /// 图标
  final IconData? icon;

  /// 额外的操作按钮
  final Widget? actionButton;

  const CommonEmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionButton != null) 
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: actionButton,
            ),
        ],
      ),
    );
  }
} 