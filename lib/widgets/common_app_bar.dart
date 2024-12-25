import 'package:flutter/material.dart';

/// 通用导航栏组件
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标题
  final Widget? title;

  /// 左侧按钮
  final List<Widget>? leading;

  /// 右侧按钮
  final List<Widget>? actions;

  /// 底部组件
  final PreferredSizeWidget? bottom;

  /// 背景色
  final Color? backgroundColor;

  /// 是否显示返回按钮
  final bool showBackButton;

  const CommonAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: title,
      actions: actions,
      bottom: bottom,
      leadingWidth: showBackButton ? null : 0,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
