import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/app_config.dart';
import '../../pages/account_books_page.dart';
import '../../pages/language_settings_page.dart';
import '../../pages/theme_settings_page.dart';

/// 我的页面
class MineTab extends StatelessWidget {
  const MineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentUser = AppConfig.instance.currentUser;

    return ListView(
      children: [
        // 用户信息区域
        Container(
          color: colorScheme.surface,
          padding: const EdgeInsets.all(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              // TODO: 跳转到用户信息页面
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person_outline,
                    size: 32,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser?.nickname ?? l10n.notLoggedIn,
                        style: theme.textTheme.titleLarge,
                      ),
                      if (currentUser?.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          currentUser!.email!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // 功能按钮区域
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
                context: context,
                icon: Icons.book_outlined,
                label: l10n.accountBook,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AccountBooksPage(
                      userId: AppConfig.instance.currentUserId,
                    ),
                  ));
                },
              ),
              _buildGridButton(
                context: context,
                icon: Icons.category_outlined,
                label: l10n.category,
                onTap: () {
                  // TODO: 跳转到分类管理页面
                },
              ),
              _buildGridButton(
                context: context,
                icon: Icons.account_balance_outlined,
                label: l10n.account,
                onTap: () {
                  // TODO: 跳转到账户管理页面
                },
              ),
              _buildGridButton(
                context: context,
                icon: Icons.store_outlined,
                label: l10n.merchant,
                onTap: () {
                  // TODO: 跳转到商家管理页面
                },
              ),
              _buildGridButton(
                context: context,
                icon: Icons.label_outline,
                label: l10n.tag,
                onTap: () {
                  // TODO: 跳转到标签管理页面
                },
              ),
              _buildGridButton(
                context: context,
                icon: Icons.folder_outlined,
                label: l10n.project,
                onTap: () {
                  // TODO: 跳转到项目管理页面
                },
              ),
              _buildGridButton(
                context: context,
                icon: Icons.download_outlined,
                label: l10n.import,
                onTap: () {
                  // TODO: 跳转到导入页面
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // 系统设置区域
        Container(
          color: colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.systemSettings,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.palette_outlined,
                  color: colorScheme.primary,
                ),
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
              ListTile(
                leading: Icon(
                  Icons.language_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(l10n.languageSettings),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const LanguageSettingsPage(),
                  ));
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.storage_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(l10n.database),
                trailing: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  // TODO: 跳转到数据库查看器页面
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                ),
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
    );
  }

  Widget _buildGridButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
