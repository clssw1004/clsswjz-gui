import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/common_app_bar.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.themeSettings),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              // 主题预览卡片
              _buildPreviewCard(context, themeProvider),
              const Divider(height: 32),

              // 主题模式选择
              ListTile(
                leading: const Icon(Icons.brightness_medium),
                title: Text(L10nManager.l10n.themeMode),
                trailing: DropdownButton<ThemeMode>(
                  value: themeProvider.themeMode,
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      themeProvider.setThemeMode(newMode);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(L10nManager.l10n.followSystem),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(L10nManager.l10n.lightMode),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(L10nManager.l10n.darkMode),
                    ),
                  ],
                ),
              ),

              // Material 3 开关
              SwitchListTile(
                secondary: const Icon(Icons.style),
                title: Text(L10nManager.l10n.useMaterial3),
                subtitle: Text(L10nManager.l10n.useMaterial3Description),
                value: themeProvider.useMaterial3,
                onChanged: (bool value) {
                  themeProvider.setUseMaterial3(value);
                },
              ),

              // 字体大小选择
              ListTile(
                leading: const Icon(Icons.format_size),
                title: Text(L10nManager.l10n.fontSize),
                trailing: DropdownButton<double>(
                  value: themeProvider.fontSize,
                  onChanged: (double? newSize) {
                    if (newSize != null) {
                      themeProvider.setFontSize(newSize);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: FontSize.smaller,
                      child: Text(L10nManager.l10n.fontSizeSmaller),
                    ),
                    DropdownMenuItem(
                      value: FontSize.normal,
                      child: Text(L10nManager.l10n.fontSizeNormal),
                    ),
                    DropdownMenuItem(
                      value: FontSize.larger,
                      child: Text(L10nManager.l10n.fontSizeLarger),
                    ),
                    DropdownMenuItem(
                      value: FontSize.largest,
                      child: Text(L10nManager.l10n.fontSizeLargest),
                    ),
                  ],
                ),
              ),

              // 圆角大小选择
              ListTile(
                leading: const Icon(Icons.rounded_corner),
                title: Text(L10nManager.l10n.radius),
                trailing: DropdownButton<double>(
                  value: themeProvider.radius,
                  onChanged: (double? newRadius) {
                    if (newRadius != null) {
                      themeProvider.setRadius(newRadius);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: RadiusSize.none,
                      child: Text(L10nManager.l10n.radiusNone),
                    ),
                    DropdownMenuItem(
                      value: RadiusSize.small,
                      child: Text(L10nManager.l10n.radiusSmall),
                    ),
                    DropdownMenuItem(
                      value: RadiusSize.medium,
                      child: Text(L10nManager.l10n.radiusMedium),
                    ),
                    DropdownMenuItem(
                      value: RadiusSize.large,
                      child: Text(L10nManager.l10n.radiusLarge),
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),

              // 主题颜色选择
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10nManager.l10n.themeColor,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12.0,
                      runSpacing: 12.0,
                      children: themeProvider.availableColors.map((color) {
                        return _ColorButton(
                          color: color,
                          isSelected: themeProvider.themeColor == color,
                          onTap: () => themeProvider.setThemeColor(color),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPreviewCard(BuildContext context, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                L10nManager.l10n.themePreview,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      child: Text(L10nManager.l10n.save),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: L10nManager.l10n.description,
                  hintText: L10nManager.l10n.pleaseInput(L10nManager.l10n.description),
                ),
                controller: TextEditingController(text: '示例文本'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final MaterialColor color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorButton({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
