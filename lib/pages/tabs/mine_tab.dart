import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../database/database_service.dart';
import '../settings/theme_settings_page.dart';

class MineTab extends StatelessWidget {
  const MineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
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
                  l10n.notLoggedIn,
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
                    text: l10n.accountBook,
                    onPressed: () {
                      // TODO: 跳转到账本管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.category,
                    text: l10n.category,
                    onPressed: () {
                      // TODO: 跳转到分类管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.account_balance_wallet,
                    text: l10n.account,
                    onPressed: () {
                      // TODO: 跳转到账户管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.store,
                    text: l10n.merchant,
                    onPressed: () {
                      // TODO: 跳转到商家管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.tag,
                    text: l10n.tag,
                    onPressed: () {
                      // TODO: 跳转到标签管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.folder,
                    text: l10n.project,
                    onPressed: () {
                      // TODO: 跳转到项目管理页面
                    },
                  ),
                  _buildGridButton(
                    context,
                    icon: Icons.file_download,
                    text: l10n.import,
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
                l10n.systemSettings,
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
                  ListTile(
                    leading: Icon(Icons.color_lens, color: colorScheme.primary),
                    title: Text(l10n.themeSettings),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
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
                    title: Text(l10n.languageSettings),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.simplifiedChinese,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: colorScheme.onSurfaceVariant,
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
                    title: Text(l10n.backendSettings),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      // TODO: 跳转到后台服务设置页面
                    },
                  ),
                  Divider(
                      height: 1, indent: 56, color: colorScheme.outlineVariant),
                  ListTile(
                    leading: Icon(Icons.storage, color: colorScheme.primary),
                    title: Text(l10n.database),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DriftDbViewer(DatabaseService.db),
                      ));
                    },
                  ),
                  Divider(
                      height: 1, indent: 56, color: colorScheme.outlineVariant),
                  ListTile(
                    leading:
                        Icon(Icons.info_outline, color: colorScheme.primary),
                    title: Text(l10n.about),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
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
