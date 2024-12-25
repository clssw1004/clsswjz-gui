import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/theme_provider.dart';

/// 主题设置页面
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = context.watch<ThemeProvider>();
    final currentThemeMode = themeProvider.themeMode;
    final currentThemeColor = themeProvider.themeColor;
    final currentFontSize = themeProvider.fontSize;
    final currentRadius = themeProvider.radius;
    final currentUseMaterial3 = themeProvider.useMaterial3;

    String getFontSizeLabel(double size) {
      if (size == FontSize.smaller) return l10n.fontSizeSmaller;
      if (size == FontSize.normal) return l10n.fontSizeNormal;
      if (size == FontSize.larger) return l10n.fontSizeLarger;
      if (size == FontSize.largest) return l10n.fontSizeLargest;
      return l10n.fontSizeNormal;
    }

    String getRadiusLabel(double radius) {
      if (radius == Radius.none) return l10n.radiusNone;
      if (radius == Radius.small) return l10n.radiusSmall;
      if (radius == Radius.medium) return l10n.radiusMedium;
      if (radius == Radius.large) return l10n.radiusLarge;
      return l10n.radiusMedium;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.themeSettings),
      ),
      body: ListView(
        children: [
          // 主题模式设置
          ListTile(
            title: Text(l10n.themeMode),
            subtitle: Text(
              switch (currentThemeMode) {
                ThemeMode.system => l10n.followSystem,
                ThemeMode.light => l10n.lightMode,
                ThemeMode.dark => l10n.darkMode,
              },
            ),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.followSystem),
            value: ThemeMode.system,
            groupValue: currentThemeMode,
            onChanged: (value) => themeProvider.setThemeMode(value!),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.lightMode),
            value: ThemeMode.light,
            groupValue: currentThemeMode,
            onChanged: (value) => themeProvider.setThemeMode(value!),
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.darkMode),
            value: ThemeMode.dark,
            groupValue: currentThemeMode,
            onChanged: (value) => themeProvider.setThemeMode(value!),
          ),

          const Divider(),

          // 主题色设置
          ListTile(
            title: Text(l10n.themeColor),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: themeProvider.availableColors.map((color) {
                return InkWell(
                  onTap: () => themeProvider.setThemeColor(color),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: currentThemeColor.value == color.value
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // 字体大小设置
          ListTile(
            title: Text(l10n.fontSize),
            subtitle: Text(getFontSizeLabel(currentFontSize)),
          ),
          RadioListTile<double>(
            title: Text(l10n.fontSizeSmaller),
            value: FontSize.smaller,
            groupValue: currentFontSize,
            onChanged: (value) => themeProvider.setFontSize(value!),
          ),
          RadioListTile<double>(
            title: Text(l10n.fontSizeNormal),
            value: FontSize.normal,
            groupValue: currentFontSize,
            onChanged: (value) => themeProvider.setFontSize(value!),
          ),
          RadioListTile<double>(
            title: Text(l10n.fontSizeLarger),
            value: FontSize.larger,
            groupValue: currentFontSize,
            onChanged: (value) => themeProvider.setFontSize(value!),
          ),
          RadioListTile<double>(
            title: Text(l10n.fontSizeLargest),
            value: FontSize.largest,
            groupValue: currentFontSize,
            onChanged: (value) => themeProvider.setFontSize(value!),
          ),

          const Divider(),

          // 圆角大小设置
          ListTile(
            title: Text(l10n.radius),
            subtitle: Text(getRadiusLabel(currentRadius)),
          ),
          RadioListTile<double>(
            title: Text(l10n.radiusNone),
            value: Radius.none,
            groupValue: currentRadius,
            onChanged: (value) => themeProvider.setRadius(value!),
          ),
          RadioListTile<double>(
            title: Text(l10n.radiusSmall),
            value: Radius.small,
            groupValue: currentRadius,
            onChanged: (value) => themeProvider.setRadius(value!),
          ),
          RadioListTile<double>(
            title: Text(l10n.radiusMedium),
            value: Radius.medium,
            groupValue: currentRadius,
            onChanged: (value) => themeProvider.setRadius(value!),
          ),
          RadioListTile<double>(
            title: Text(l10n.radiusLarge),
            value: Radius.large,
            groupValue: currentRadius,
            onChanged: (value) => themeProvider.setRadius(value!),
          ),

          const Divider(),

          // Material 3 设置
          SwitchListTile(
            title: Text(l10n.useMaterial3),
            value: currentUseMaterial3,
            onChanged: (value) => themeProvider.setUseMaterial3(value),
          ),
        ],
      ),
    );
  }
}
