import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';
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

  const CommonAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.showBackButton = true,
    this.showLanguageSelector = false,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // 获取当前语言
    final currentLocale = Localizations.localeOf(context).toString();

    final List<Widget> finalActions = [
      ...?actions,
      if (showLanguageSelector)
        PopupMenuButton<String>(
          icon: Icon(
            Icons.language,
            color: colorScheme.onSurface,
          ),
          tooltip: l10n.language,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'zh',
              child: Row(
                children: [
                  Text(l10n.simplifiedChinese),
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
                  Text(l10n.traditionalChinese),
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
                  Text(l10n.english),
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
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: DefaultTextStyle(
        style: theme.textTheme.titleLarge ?? const TextStyle(),
        child: title ?? const SizedBox(),
      ),
      actions: finalActions,
      bottom: bottom,
      leadingWidth: showBackButton ? null : 0,
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
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
