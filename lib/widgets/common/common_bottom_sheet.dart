import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';

/// 通用底部弹出组件
class CommonBottomSheet extends StatelessWidget {
  /// 标题
  final String title;

  /// 是否显示分割线
  final bool showDivider;

  /// 内容
  final Widget child;

  /// 确认回调
  final VoidCallback? onConfirm;

  /// 取消回调
  final VoidCallback? onCancel;

  const CommonBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.showDivider = false,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final l10n = L10nManager.l10n;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    onCancel?.call();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onConfirm?.call();
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.confirm),
                ),
              ],
            ),
          ),
          // 分割线
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant,
            ),
          // 内容区域
          Flexible(
            child: child,
          ),
        ],
      ),
    );
  }
} 