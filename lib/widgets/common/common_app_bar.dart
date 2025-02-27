import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/theme_radius.dart';

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

  /// 是否显示语言选择
  final bool showLanguageSelector;

  /// 是否显示主题模式选择
  final bool showThemeSelector;

  /// 是否居中标题（仅在 Android 下生效）
  final bool centerTitle;

  const CommonAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.showBackButton = true,
    this.showLanguageSelector = false,
    this.showThemeSelector = false,
    this.centerTitle = true,
  });

  /// 切换语言
  Future<void> _changeLanguage(BuildContext context, String locale) async {
    final parts = locale.split('_');
    final newLocale =
        parts.length > 1 ? Locale(parts[0], parts[1]) : Locale(parts[0]);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    // 保存新的语言设置
    await localeProvider.setLocale(newLocale);

    if (context.mounted) {
      // 重新构建整个应用以应用新的语言设置
      // 使用 pushNamedAndRemoveUntil 而不是 pushReplacementNamed，
      // 因为我们需要清除整个导航栈以确保所有页面都使用新的语言
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  /// 切换主题模式
  void _changeThemeMode(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final currentMode = themeProvider.themeMode;
    final newMode =
        currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    themeProvider.setThemeMode(newMode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLocale = Localizations.localeOf(context).toString();
    final isIOS = Platform.isIOS;

    // 构建返回按钮
    Widget? leadingWidget;
    if (showBackButton) {
      leadingWidget = IconButton(
        icon: Icon(
          isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back,
          color: colorScheme.onSurface,
          size: isIOS ? 20 : 24,
        ),
        onPressed: () => Navigator.of(context).pop(true),
      );
    }

    // 构建右侧按钮
    final List<Widget> finalActions = [
      ...?actions,
      if (showThemeSelector)
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            final isDark = themeProvider.themeMode == ThemeMode.dark;
            return IconButton(
              icon: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.onSurface,
                size: isIOS ? 20 : 24,
              ),
              tooltip: isDark
                  ? L10nManager.l10n.lightMode
                  : L10nManager.l10n.darkMode,
              onPressed: () => _changeThemeMode(context),
            );
          },
        ),
      if (showLanguageSelector)
        PopupMenuButton<String>(
          icon: Icon(
            Icons.language,
            color: colorScheme.onSurface,
            size: isIOS ? 20 : 24,
          ),
          tooltip: L10nManager.l10n.language,
          position: PopupMenuPosition.under,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'zh',
              child: Row(
                children: [
                  Text(L10nManager.l10n.simplifiedChinese),
                  if (currentLocale == 'zh') ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuItem(
              value: 'zh_Hant',
              child: Row(
                children: [
                  Text(L10nManager.l10n.traditionalChinese),
                  if (currentLocale == 'zh_Hant') ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuItem(
              value: 'en',
              child: Row(
                children: [
                  Text(L10nManager.l10n.english),
                  if (currentLocale == 'en') ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ],
          onSelected: (locale) => _changeLanguage(context, locale),
        ),
    ];

    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      automaticallyImplyLeading: false,
      leading: leadingWidget,
      title: DefaultTextStyle(
        style: theme.textTheme.titleLarge?.copyWith(
              fontSize: isIOS ? 17 : null,
              fontWeight: isIOS ? FontWeight.w600 : null,
            ) ??
            const TextStyle(),
        child: title ?? const SizedBox(),
      ),
      centerTitle: isIOS ? true : centerTitle,
      titleSpacing: isIOS
          ? NavigationToolbar.kMiddleSpacing
          : NavigationToolbar.kMiddleSpacing,
      actions: finalActions,
      bottom: bottom,
      leadingWidth: showBackButton ? (isIOS ? 44 : null) : 0,
      toolbarHeight: isIOS ? 44 : kToolbarHeight,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: bottom == null
              ? Radius.circular(theme.extension<ThemeRadius>()?.radius ?? 0)
              : Radius.zero,
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight((Platform.isIOS ? 44 : kToolbarHeight) +
          (bottom?.preferredSize.height ?? 0.0));
}
