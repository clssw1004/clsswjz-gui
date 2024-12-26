import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/user_info_card.dart';

class MineTab extends StatelessWidget {
  const MineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider()..getUserInfo(),
      child: const _MineTabView(),
    );
  }
}

class _MineTabView extends StatelessWidget {
  const _MineTabView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<UserProvider>();

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(l10n.tabMine),
      ),
      body: ListView(
        children: [
          // 用户信息区域
          UserInfoCard(
            user: provider.user,
            statistic: provider.statistic,
            onTap: () => Navigator.pushNamed(context, '/user_info'),
          ),
          const Divider(height: 1),
          // 功能按钮区域
          GridView.count(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildGridItem(
                context,
                icon: Icons.book_outlined,
                label: l10n.accountBook,
                onTap: () {
                  Navigator.pushNamed(context, '/account_books');
                },
              ),
              _buildGridItem(
                context,
                icon: Icons.category_outlined,
                label: l10n.category,
                onTap: () {
                  Navigator.pushNamed(context, '/categories');
                },
              ),
              _buildGridItem(
                context,
                icon: Icons.account_balance_wallet_outlined,
                label: l10n.account,
                onTap: () {
                  Navigator.pushNamed(context, '/accounts');
                },
              ),
              _buildGridItem(
                context,
                icon: Icons.store_outlined,
                label: l10n.merchant,
                onTap: () {
                  Navigator.pushNamed(context, '/merchants');
                },
              ),
              _buildGridItem(
                context,
                icon: Icons.local_offer_outlined,
                label: l10n.tag,
                onTap: () {
                  Navigator.pushNamed(context, '/tags');
                },
              ),
              _buildGridItem(
                context,
                icon: Icons.folder_outlined,
                label: l10n.project,
                onTap: () {
                  Navigator.pushNamed(context, '/projects');
                },
              ),
              _buildGridItem(
                context,
                icon: Icons.file_upload_outlined,
                label: l10n.import,
                onTap: () {
                  Navigator.pushNamed(context, '/import');
                },
              ),
            ],
          ),
          const Divider(height: 1),
          // 系统设置区域
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.systemSettings,
              style: theme.textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.themeSettings),
            onTap: () {
              Navigator.pushNamed(context, '/theme_settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.languageSettings),
            onTap: () {
              Navigator.pushNamed(context, '/language_settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(l10n.database),
            onTap: () {
              Navigator.pushNamed(context, '/database_viewer');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
