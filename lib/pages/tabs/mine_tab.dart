import 'package:clsswjz/providers/account_books_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../widgets/user_info_card.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/sync_data_button.dart';

class MineTab extends StatelessWidget {
  const MineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MineTabView();
  }
}

class _MineTabView extends StatelessWidget {
  const _MineTabView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final provider = context.watch<UserProvider>();
    // 获取当前选中的账本
    final bookProvider = context.read<AccountBooksProvider>();
    final accountBook = bookProvider.selectedBook;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        children: [
          // 用户信息区域
          UserInfoCard(
            user: provider.user,
            statistic: provider.statistic,
            onTap: () => Navigator.pushNamed(context, '/user_info'),
          ),
          const Divider(height: 1),
          const SyncDataButton(),
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
                Icons.book_outlined,
                l10n.accountBook,
                () => Navigator.pushNamed(context, AppRoutes.accountBooks),
              ),
              _buildGridItem(
                context,
                Icons.category_outlined,
                l10n.category,
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.categories,
                  arguments: accountBook,
                ),
              ),
              _buildGridItem(
                context,
                Icons.account_balance_wallet_outlined,
                l10n.account,
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.funds,
                  arguments: accountBook,
                ),
              ),
              _buildGridItem(
                context,
                Icons.store_outlined,
                l10n.merchant,
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.merchants,
                  arguments: accountBook,
                ),
              ),
              _buildGridItem(
                context,
                Icons.local_offer_outlined,
                l10n.tag,
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.tags,
                  arguments: accountBook,
                ),
              ),
              _buildGridItem(
                context,
                Icons.folder_outlined,
                l10n.project,
                () => Navigator.pushNamed(
                  context,
                  AppRoutes.projects,
                  arguments: accountBook,
                ),
              ),
              _buildGridItem(
                context,
                Icons.file_upload_outlined,
                l10n.import,
                () => Navigator.pushNamed(context, '/import'),
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
            onTap: () => Navigator.pushNamed(context, AppRoutes.themeSettings),
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(l10n.languageSettings),
            onTap: () => Navigator.pushNamed(context, AppRoutes.languageSettings),
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: Text(l10n.database),
            onTap: () => Navigator.pushNamed(context, AppRoutes.databaseViewer),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
