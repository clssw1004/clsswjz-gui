import 'package:flutter/material.dart';
import '../../theme/theme_radius.dart';
import '../../manager/l10n_manager.dart';

/// 通用弹窗组件
class CommonDialog extends StatelessWidget {
  /// 标题
  final String? title;

  /// 内容区域
  final Widget content;

  /// 是否显示关闭按钮
  final bool showCloseButton;

  /// 宽度
  final double? width;

  /// 高度
  final double? height;

  /// 内边距
  final EdgeInsetsGeometry contentPadding;

  /// 标题栏内边距
  final EdgeInsetsGeometry titlePadding;

  /// 标题样式
  final TextStyle? titleStyle;

  /// 背景色
  final Color? backgroundColor;

  /// 圆角半径
  final double? borderRadius;

  const CommonDialog({
    super.key,
    this.title,
    required this.content,
    this.showCloseButton = true,
    this.width,
    this.height,
    this.contentPadding = const EdgeInsets.all(24),
    this.titlePadding = const EdgeInsets.fromLTRB(24, 16, 16, 16),
    this.titleStyle,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 16;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width ?? MediaQuery.of(context).size.width * 0.85,
        height: height,
        constraints: BoxConstraints(
          maxWidth: 450,
          minWidth: 280,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius ?? radius),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(38),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null || showCloseButton)
              Padding(
                padding: titlePadding,
                child: Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: titleStyle ??
                              theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                        ),
                      ),
                    if (showCloseButton)
                      Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          style: IconButton.styleFrom(
                            shape: const CircleBorder(),
                          ),
                          icon: Icon(
                            Icons.close,
                            color: colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                  ],
                ),
              ),
            if (title != null || showCloseButton)
              Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outlineVariant.withAlpha(128),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: contentPadding,
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示弹窗
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    bool showCloseButton = true,
    double? width,
    double? height,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(24),
    EdgeInsetsGeometry titlePadding = const EdgeInsets.fromLTRB(24, 16, 16, 16),
    TextStyle? titleStyle,
    Color? backgroundColor,
    double borderRadius = 16,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => CommonDialog(
        title: title,
        content: content,
        showCloseButton: showCloseButton,
        width: width,
        height: height,
        contentPadding: contentPadding,
        titlePadding: titlePadding,
        titleStyle: titleStyle,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
      ),
    );
  }

  /// 显示警告弹窗
  static Future<bool?> showWarning({
    required BuildContext context,
    required String message,
    int countdown = 5,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    bool canConfirm = false;
    int currentCountdown = countdown;

    return CommonDialog.show<bool>(
      context: context,
      title: L10nManager.l10n.warning,
      titleStyle: theme.textTheme.titleLarge?.copyWith(
        color: colorScheme.error,
        fontWeight: FontWeight.w600,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          if (!canConfirm) {
            Future.delayed(const Duration(seconds: 1), () {
              if (currentCountdown > 0) {
                setState(() => currentCountdown--);
              } else {
                setState(() => canConfirm = true);
              }
            });
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: colorScheme.onErrorContainer,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(L10nManager.l10n.cancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      elevation: 0,
                      disabledBackgroundColor: colorScheme.error.withAlpha(128),
                      disabledForegroundColor: colorScheme.onError.withAlpha(128),
                    ),
                    onPressed: canConfirm ? () => Navigator.of(context).pop(true) : null,
                    child: Text(canConfirm
                        ? L10nManager.l10n.confirm
                        : "${L10nManager.l10n.confirm} (${currentCountdown}s)"),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      showCloseButton: false,
    );
  }
}
