import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/user_provider.dart';
import '../../widgets/setting/user_info_card.dart';
import '../../routes/app_routes.dart';
import '../../providers/sync_provider.dart';
import '../../utils/date_util.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_setting_tile.dart';

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
    final spacing = theme.spacing;
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildProfileSliver(context, userProvider, colorScheme),
          _buildSettingsSliver(
            context,
            spacing: spacing,
            child: _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    icon: Icons.settings_outlined,
                    title: L10nManager.l10n.systemSettings,
                  ),
                  _buildGeneralSettings(context),
                ],
              ),
            ),
          ),
          _buildSettingsSliver(
            context,
            spacing: spacing,
            child: _buildSectionCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    icon: Icons.handyman_outlined,
                    title: L10nManager.l10n.hubGroupDataTools,
                  ),
                  _buildDataSettings(context),
                ],
              ),
            ),
          ),
          _buildFooterSliver(context),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  /// 分组标题（图标 + 标题，与工具工作台视觉一致）
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 通用设置组：分享 / 主题 / 语言 / 界面布局
  Widget _buildGeneralSettings(BuildContext context) {
    final l10n = L10nManager.l10n;
    return Column(
      children: [
        CommonSettingTile(
          icon: Icons.share_outlined,
          label: l10n.shareSettings,
          onTap: () => Navigator.pushNamed(context, AppRoutes.shareSettings),
          color: const Color(0xFF3BA55D),
        ),
        CommonSettingTile(
          icon: Icons.palette_outlined,
          label: l10n.themeSettings,
          onTap: () => Navigator.pushNamed(context, AppRoutes.themeSettings),
          color: const Color(0xFF7C5CFC),
        ),
        CommonSettingTile(
          icon: Icons.language_outlined,
          label: l10n.languageSettings,
          onTap: () => Navigator.pushNamed(context, AppRoutes.languageSettings),
          color: const Color(0xFF2E86DE),
        ),
        CommonSettingTile(
          icon: Icons.dashboard_outlined,
          label: l10n.uiLayoutSettings,
          onTap: () => Navigator.pushNamed(context, AppRoutes.uiLayoutSettings),
          color: const Color(0xFFF97316),
        ),
      ],
    );
  }

  /// 数据工具组：同步 / 数据库 / 关于
  Widget _buildDataSettings(BuildContext context) {
    final l10n = L10nManager.l10n;
    return Column(
      children: [
        CommonSettingTile(
          icon: Icons.cloud_outlined,
          label: l10n.syncSettings,
          onTap: () => Navigator.pushNamed(context, AppRoutes.syncSettings),
          color: const Color(0xFF00A9C9),
        ),
        CommonSettingTile(
          icon: Icons.storage_outlined,
          label: l10n.database,
          onTap: () => Navigator.pushNamed(context, AppRoutes.databaseViewer),
          color: const Color(0xFF5C6BC0),
        ),
        CommonSettingTile(
          icon: Icons.info_outline,
          label: l10n.about,
          onTap: () => Navigator.pushNamed(context, AppRoutes.about),
          isLast: true,
          color: const Color(0xFF8A90A6),
        ),
      ],
    );
  }

  Widget _buildProfileSliver(
    BuildContext context,
    UserProvider provider,
    ColorScheme colorScheme,
  ) {
    return SliverToBoxAdapter(
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
              _buildCompactSyncRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactSyncRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final syncProvider = context.watch<SyncProvider>();
    final l10n = L10nManager.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(70),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colorScheme.outlineVariant.withAlpha(40),
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: syncProvider.syncing
                        ? Text(
                            syncProvider.currentStep ?? l10n.syncing,
                            style: theme.textTheme.bodySmall,
                            key: const ValueKey('syncing'),
                          )
                        : syncProvider.backgroundSyncing
                            ? Text(
                                l10n.backgroundSyncing(
                                  (syncProvider.backgroundProgress * 100)
                                      .toInt(),
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                key: const ValueKey('background'),
                              )
                            : Text(
                                syncProvider.lastSyncTime != null
                                    ? l10n.lastSyncTime(DateUtil.format(
                                        syncProvider.lastSyncTime!))
                                    : l10n.notSynced,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                key: const ValueKey('idle'),
                              ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildMiniButton(
                  context,
                  onPressed: syncProvider.syncing ||
                          syncProvider.backgroundSyncing
                      ? null
                      : () async {
                          await syncProvider.syncData();
                        },
                  child: syncProvider.syncing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Icon(
                          Icons.sync,
                          size: 16,
                          color: colorScheme.onSecondaryContainer,
                        ),
                ),
                const SizedBox(width: 4),
                _buildMiniButton(
                  context,
                  onPressed: () =>
                      Navigator.pushNamed(context, '/sync_settings'),
                  child: Icon(
                    Icons.settings,
                    size: 16,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: syncProvider.syncing
                        ? syncProvider.progress
                        : syncProvider.backgroundProgress,
                    minHeight: 2,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                ),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState:
                  syncProvider.syncing || syncProvider.backgroundSyncing
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniButton(
    BuildContext context, {
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(128),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      icon: child,
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSettingsSliver(
    BuildContext context, {
    required ThemeSpacing spacing,
    required Widget child,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: spacing.pagePadding.copyWith(top: 0, bottom: 12),
        child: child,
      ),
    );
  }

  /// 底部品牌区：Logo + 应用名 + 版本号，填充页面底部留白
  Widget _buildFooterSliver(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = L10nManager.l10n;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.appName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final version = snapshot.connectionState ==
                            ConnectionState.done &&
                        snapshot.hasData
                    ? snapshot.data!.version
                    : '';
                return Text(
                  version.isEmpty ? '' : '${l10n.version} $version',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
