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
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (onConfirm != null) {
                        onConfirm!();
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: Text(l10n.confirm),
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