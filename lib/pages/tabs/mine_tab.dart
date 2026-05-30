import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/setting/user_info_card.dart';
import '../../routes/app_routes.dart';
import '../../providers/sync_provider.dart';
import '../../utils/date_util.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_grid_feature_item.dart';
import '../../widgets/common/common_setting_tile.dart';
import '../fuel/fuel_record_list_page.dart';

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
    final provider = context.watch<UserProvider>();
    final bookProvider = context.read<BooksProvider>();
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
                      margin: spacing.pagePadding.copyWith(
                        top: spacing.formItemSpacing,
                      ),
                      decoration: BoxDecoration(
                        color:
                            colorScheme.surfaceContainerHighest.withAlpha(128),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: spacing.pagePadding.copyWith(top: 0),
              child: Column(
                children: [
                  // 当前账本功能区域
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withAlpha(40),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: spacing.formPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题：当前账本名称
                          Padding(
                            padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  accountBook?.name ?? '未选择账本',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 功能按钮网格
                          Row(
                            children: [
                              Expanded(child: CommonGridFeatureItem(
                                icon: Icons.category_outlined,
                                label: L10nManager.l10n.category,
                                onTap: () => Navigator.pushNamed(context, AppRoutes.categories, arguments: accountBook),
                                isHighlighted: true,
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: CommonGridFeatureItem(
                                icon: Icons.account_balance_wallet_outlined,
                                label: L10nManager.l10n.account,
                                onTap: () => Navigator.pushNamed(context, AppRoutes.funds, arguments: accountBook),
                                isHighlighted: true,
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: CommonGridFeatureItem(
                                icon: Icons.store_outlined,
                                label: L10nManager.l10n.merchant,
                                onTap: () => Navigator.pushNamed(context, AppRoutes.merchants, arguments: accountBook),
                                isHighlighted: true,
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: CommonGridFeatureItem(
                                icon: Icons.local_offer_outlined,
                                label: L10nManager.l10n.tag,
                                onTap: () => Navigator.pushNamed(context, AppRoutes.tags, arguments: accountBook),
                                isHighlighted: true,
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: CommonGridFeatureItem(
                                icon: Icons.folder_outlined,
                                label: L10nManager.l10n.project,
                                onTap: () => Navigator.pushNamed(context, AppRoutes.projects, arguments: accountBook),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.formGroupSpacing),
                  // 全局功能区域
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(40),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withAlpha(40),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: spacing.formPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 功能按钮网格
                          Row(
                            children: [
                              Expanded(child: CommonGridFeatureItem(
                                icon: Icons.book_outlined,
                                label: L10nManager.l10n.accountBook,
                                onTap: () => Navigator.pushNamed(context, AppRoutes.accountBooks),
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: CommonGridFeatureItem(
                                icon: Icons.file_upload_outlined,
                                label: L10nManager.l10n.import,
                                onTap: () => Navigator.pushNamed(context, '/import'),
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: CommonGridFeatureItem(
                                icon: Icons.attachment,
                                label: L10nManager.l10n.attachment,
                                onTap: () => Navigator.pushNamed(context, AppRoutes.attachments),
                              )),
                              const SizedBox(width: 8),
                              Expanded(child: CommonGridFeatureItem(
                                icon: Icons.card_giftcard,
                                label: '礼物卡',
                                onTap: () => Navigator.pushNamed(context, AppRoutes.giftCardList),
                              )),
                            ],
                          ),
                          SizedBox(height: spacing.formItemSpacing),
                          Row(
                            children: [
                              Expanded(child: CommonGridFeatureItem(
                                icon: Icons.local_gas_station,
                                label: '油耗记录',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const FuelRecordListPage())),
                              )),
                              const Expanded(child: SizedBox.shrink()),
                              const SizedBox(width: 8),
                              const Expanded(child: SizedBox.shrink()),
                              const SizedBox(width: 8),
                              const Expanded(child: SizedBox.shrink()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 系统设置区域
          SliverToBoxAdapter(
            child: Container(
              margin: spacing.pagePadding.copyWith(top: 0),
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
                    padding: EdgeInsets.fromLTRB(
                      spacing.formPadding.left,
                      spacing.formPadding.top,
                      spacing.formPadding.right,
                      spacing.formItemSpacing,
                    ),
                    child: Text(
                      L10nManager.l10n.systemSettings,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  CommonSettingTile(
                    icon: Icons.palette_outlined,
                    label: L10nManager.l10n.themeSettings,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.themeSettings),
                  ),
                  CommonSettingTile(
                    icon: Icons.language_outlined,
                    label: L10nManager.l10n.languageSettings,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.languageSettings),
                  ),
                  CommonSettingTile(
                    icon: Icons.dashboard_outlined,
                    label: L10nManager.l10n.uiLayoutSettings,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.uiLayoutSettings),
                  ),
                  CommonSettingTile(
                    icon: Icons.storage_outlined,
                    label: L10nManager.l10n.database,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.databaseViewer),
                  ),
                  CommonSettingTile(
                    icon: Icons.info_outline,
                    label: L10nManager.l10n.about,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.about),
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

  Widget _buildSyncSettingItem(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final syncProvider = context.watch<SyncProvider>();

    return Padding(
      padding: spacing.formItemPadding,
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
                          ? L10nManager.l10n.lastSyncTime(
                              DateUtil.format(syncProvider.lastSyncTime!))
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
                  backgroundColor:
                      colorScheme.surfaceContainerHighest.withAlpha(128),
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
                  backgroundColor:
                      colorScheme.surfaceContainerHighest.withAlpha(128),
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
                  backgroundColor:
                      colorScheme.surfaceContainerHighest.withAlpha(128),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  minHeight: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
