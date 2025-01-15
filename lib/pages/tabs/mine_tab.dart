import 'package:clsswjz/providers/account_books_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/user_provider.dart';
import '../../widgets/user_info_card.dart';
import '../../routes/app_routes.dart';
import '../../providers/sync_provider.dart';
import '../../utils/date_util.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<UserProvider>();
    final bookProvider = context.read<AccountBooksProvider>();
    final accountBook = bookProvider.selectedBook;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 用户信息区域
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary.withAlpha(26),
                    colorScheme.surface,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    UserInfoCard(
                      user: provider.user,
                      statistic: provider.statistic,
                      onTap: () => Navigator.pushNamed(context, '/user_info'),
                    ),
                    // 同步功能区域
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withAlpha(128),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withAlpha(128),
                          width: 1,
                        ),
                      ),
                      child: _buildSyncSettingItem(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 功能按钮区域
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildFeatureItem(
                  context,
                  Icons.book_outlined,
                  L10nManager.l10n.accountBook,
                  () => Navigator.pushNamed(context, AppRoutes.accountBooks),
                ),
                _buildFeatureItem(
                  context,
                  Icons.category_outlined,
                  L10nManager.l10n.category,
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.categories,
                    arguments: accountBook,
                  ),
                ),
                _buildFeatureItem(
                  context,
                  Icons.account_balance_wallet_outlined,
                  L10nManager.l10n.account,
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.funds,
                    arguments: accountBook,
                  ),
                ),
                _buildFeatureItem(
                  context,
                  Icons.store_outlined,
                  L10nManager.l10n.merchant,
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.merchants,
                    arguments: accountBook,
                  ),
                ),
                _buildFeatureItem(
                  context,
                  Icons.local_offer_outlined,
                  L10nManager.l10n.tag,
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.tags,
                    arguments: accountBook,
                  ),
                ),
                _buildFeatureItem(
                  context,
                  Icons.folder_outlined,
                  L10nManager.l10n.project,
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.projects,
                    arguments: accountBook,
                  ),
                ),
                _buildFeatureItem(
                  context,
                  Icons.file_upload_outlined,
                  L10nManager.l10n.import,
                  () => Navigator.pushNamed(context, '/import'),
                ),
              ],
            ),
          ),
          // 系统设置区域
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(128),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withAlpha(128),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      L10nManager.l10n.systemSettings,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _buildSettingItem(
                    context,
                    Icons.palette_outlined,
                    L10nManager.l10n.themeSettings,
                    () => Navigator.pushNamed(context, AppRoutes.themeSettings),
                  ),
                  _buildSettingItem(
                    context,
                    Icons.language_outlined,
                    L10nManager.l10n.languageSettings,
                    () => Navigator.pushNamed(context, AppRoutes.languageSettings),
                  ),
                  _buildSettingItem(
                    context,
                    Icons.storage_outlined,
                    L10nManager.l10n.database,
                    () => Navigator.pushNamed(context, AppRoutes.databaseViewer),
                  ),
                  _buildSettingItem(
                    context,
                    Icons.info_outline,
                    L10nManager.l10n.about,
                    () => Navigator.pushNamed(context, AppRoutes.about),
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest.withAlpha(128),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 24,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isLast = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 68),
            child: Divider(
              height: 1,
              color: colorScheme.outlineVariant.withAlpha(128),
            ),
          ),
      ],
    );
  }

  Widget _buildSyncSettingItem(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final syncProvider = context.watch<SyncProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      syncProvider.lastSyncTime != null
                          ? L10nManager.l10n.lastSyncTime(DateUtil.format(syncProvider.lastSyncTime!))
                          : L10nManager.l10n.notSynced,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (syncProvider.currentStep != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          syncProvider.currentStep!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(128),
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: syncProvider.syncing
                    ? null
                    : () async {
                        await syncProvider.syncData();
                      },
                icon: syncProvider.syncing
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Icon(
                        Icons.sync,
                        size: 18,
                        color: colorScheme.onSecondaryContainer,
                      ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                visualDensity: VisualDensity.compact,
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(128),
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pushNamed(context, '/sync_settings'),
                icon: Icon(
                  Icons.settings,
                  size: 18,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          if (syncProvider.currentStep != null)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 52),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: syncProvider.progress,
                  backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(128),
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  minHeight: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
