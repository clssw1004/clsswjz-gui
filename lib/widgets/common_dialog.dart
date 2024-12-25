import 'package:flutter/material.dart';

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
  final double borderRadius;

  const CommonDialog({
    super.key,
    this.title,
    required this.content,
    this.showCloseButton = true,
    this.width,
    this.height,
    this.contentPadding = const EdgeInsets.all(16),
    this.titlePadding = const EdgeInsets.all(16),
    this.titleStyle,
    this.backgroundColor,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surface,
          borderRadius: BorderRadius.circular(borderRadius),
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
                              theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    if (showCloseButton)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                  ],
                ),
              ),
            if (title != null || showCloseButton) const Divider(height: 1),
            Flexible(
              child: Padding(
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
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(16),
    EdgeInsetsGeometry titlePadding = const EdgeInsets.all(16),
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
}
