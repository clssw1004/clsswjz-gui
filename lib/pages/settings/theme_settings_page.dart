import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题设置'),
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
                title: const Text('主题模式'),
                trailing: DropdownButton<ThemeMode>(
                  value: themeProvider.themeMode,
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) {
                      themeProvider.setThemeMode(newMode);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('跟随系统'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('浅色'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('深色'),
                    ),
                  ],
                ),
              ),

              // Material 3 开关
              SwitchListTile(
                secondary: const Icon(Icons.style),
                title: const Text('Material You'),
                subtitle: const Text('使用 Material Design 3'),
                value: themeProvider.useMaterial3,
                onChanged: (bool value) {
                  themeProvider.setUseMaterial3(value);
                },
              ),

              // 字体大小选择
              ListTile(
                leading: const Icon(Icons.format_size),
                title: const Text('字体大小'),
                trailing: DropdownButton<double>(
                  value: themeProvider.fontSize,
                  onChanged: (double? newSize) {
                    if (newSize != null) {
                      themeProvider.setFontSize(newSize);
                    }
                  },
                  items: FontSize.options
                      .map((option) => DropdownMenuItem(
                            value: option['value'] as double,
                            child: Text(option['label'] as String),
                          ))
                      .toList(),
                ),
              ),

              // 圆角大小选择
              ListTile(
                leading: const Icon(Icons.rounded_corner),
                title: const Text('圆角大小'),
                trailing: DropdownButton<double>(
                  value: themeProvider.radius,
                  onChanged: (double? newRadius) {
                    if (newRadius != null) {
                      themeProvider.setRadius(newRadius);
                    }
                  },
                  items: Radius.options
                      .map((option) => DropdownMenuItem(
                            value: option['value'] as double,
                            child: Text(option['label'] as String),
                          ))
                      .toList(),
                ),
              ),

              const Divider(height: 32),

              // 主题颜色选择
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '主题颜色',
                      style: TextStyle(
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
                '主题预览',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('主要按钮'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('次要按钮'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: '输入框示例',
                  hintText: '请输入内容',
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
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
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
