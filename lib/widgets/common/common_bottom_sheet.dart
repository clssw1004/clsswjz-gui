import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';

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

  /// 清空回调
  final VoidCallback? onClear;

  const CommonBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.showDivider = false,
    this.onConfirm,
    this.onCancel,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = L10nManager.l10n;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动手柄
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题栏
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: showDivider ? Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ) : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    onCancel?.call();
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.outline,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40), // 平衡左侧按钮的宽度
              ],
            ),
          ),
          // 内容区域
          Flexible(
            child: child,
          ),
          // 底部按钮区域
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Row(
              children: [
                if (onClear != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClear,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.error),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(28)),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.pressed)) {
                            return colorScheme.error.withAlpha(31);
                          }
                          if (states.contains(WidgetState.hovered)) {
                            return colorScheme.error.withAlpha(20);
                          }
                          return null;
                        }),
                      ),
                      child: Text(
                        l10n.clear,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(28)),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ).copyWith(
                      overlayColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.pressed)) {
                          return colorScheme.onPrimary.withAlpha(31);
                        }
                        if (states.contains(WidgetState.hovered)) {
                          return colorScheme.onPrimary.withAlpha(20);
                        }
                        return null;
                      }),
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.disabled)) {
                          return colorScheme.primary.withAlpha(31);
                        }
                        return colorScheme.primary;
                      }),
                    ),
                    child: Text(
                      l10n.confirm,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 