import 'package:flutter/material.dart';
import '../settings/theme_settings_page.dart';

class MineTab extends StatelessWidget {
  const MineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息区域
            Material(
              color: colorScheme.surface,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primary,
                  child: const Text(
                    'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                title: Text(
                  '未登录',
                  style: theme.textTheme.titleMedium,
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  // TODO: 跳转到登录页面
                },
              ),
            ),
            const SizedBox(height: 8),
            // 功能按钮网格
            Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildGridButton(
                    context,
                    icon: Icons.book,
                    text: '账本',
                    onPressed: () {
                      // TODO: 跳转到账本管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.category,
                    text: '分类',
                    onPressed: () {
                      // TODO: 跳转到分类管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.account_balance_wallet,
                    text: '账户',
                    onPressed: () {
                      // TODO: 跳转到账户管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.store,
                    text: '商家',
                    onPressed: () {
                      // TODO: 跳转到商家管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.tag,
                    text: '标签',
                    onPressed: () {
                      // TODO: 跳转到标签管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.folder,
                    text: '项目',
                    onPressed: () {
                      // TODO: 跳转到项目管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.file_download,
                    text: '导入',
                    onPressed: () {
                      // TODO: 跳转到导入页面
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 系统设置
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '系统设置',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: colorScheme.surface,
              child: Column(
                children: [
                  SwitchListTile(
                    value:
                        const bool.fromEnvironment('DEBUG', defaultValue: true),
                    onChanged: (value) {
                      // TODO: 切换开发者模式
                    },
                    secondary:
                        Icon(Icons.developer_mode, color: colorScheme.primary),
                    title: const Text('开发者模式'),
                  ),
                  Divider(
                      height: 1, indent: 56, color: colorScheme.outlineVariant),
                  ListTile(
                    leading: Icon(Icons.color_lens, color: colorScheme.primary),
                    title: const Text('主题设置'),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ThemeSettingsPage(),
                      ));
                    },
                  ),
                  Divider(
                      height: 1, indent: 56, color: colorScheme.outlineVariant),
                  ListTile(
                    leading: Icon(Icons.language, color: colorScheme.primary),
                    title: const Text('语言设置'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '简体中文',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // TODO: 切换语言
                    },
                  ),
                  Divider(
                      height: 1, indent: 56, color: colorScheme.outlineVariant),
                  ListTile(
                    leading: Icon(Icons.settings, color: colorScheme.primary),
                    title: const Text('后台服务设置'),
                    onTap: () {
                      // TODO: 跳转到后台服务设置页面
                    },
                  ),
                  Divider(
                      height: 1, indent: 56, color: colorScheme.outlineVariant),
                  ListTile(
                    leading:
                        Icon(Icons.info_outline, color: colorScheme.primary),
                    title: const Text('关于'),
                    onTap: () {
                      // TODO: 跳转到关于页面
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
