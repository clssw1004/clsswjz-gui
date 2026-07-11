import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/setting/user_info_card.dart';
import '../../routes/app_routes.dart';
import '../../providers/sync_provider.dart';
import '../../utils/date_util.dart';
import '../../manager/app_config_manager.dart';
import '../../theme/theme_spacing.dart';
import '../fuel/fuel_record_list_page.dart';

class MineTab extends StatelessWidget {
  const MineTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MineTabView();
  }
}

class _GridFeatureItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _GridFeatureItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });
}

/// 可折叠账本功能区块
class _BookSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<_GridFeatureItemData> items;
  const _BookSection({required this.icon, required this.title, required this.items});
  @override
  State<_BookSection> createState() => _BookSectionState();
}

class _BookSectionState extends State<_BookSection> with SingleTickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = AppConfigManager.instance.bookSectionExpanded;
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    AppConfigManager.instance.setBookSectionExpanded(_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _toggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(children: [
              Icon(widget.icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(widget.title, style: theme.textTheme.titleSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600))),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                firstChild: Icon(Icons.expand_less, size: 20, color: cs.primary),
                secondChild: Icon(Icons.expand_more, size: 20, color: cs.onSurfaceVariant),
              ),
            ]),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildGrid(),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: _buildRows(theme, cs),
        ),
      ),
    );
  }

  List<Widget> _buildRows(ThemeData theme, ColorScheme cs) {
    final rows = <Widget>[];
    const int cols = 4;
    for (var i = 0; i < widget.items.length; i += cols) {
      final end = (i + cols > widget.items.length) ? widget.items.length : i + cols;
      final rowItems = widget.items.sublist(i, end);
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i > 0 ? 4 : 0),
          child: Row(
            children: List.generate(cols, (colIndex) {
              if (colIndex < rowItems.length) {
                final item = rowItems[colIndex];
                return Expanded(
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(item.icon, size: 24, color: cs.primary),
                          const SizedBox(height: 4),
                          Text(item.label,
                            style: TextStyle(fontSize: 11, color: cs.onSurface, fontWeight: FontWeight.w500),
                            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const Expanded(child: SizedBox.shrink());
            }),
          ),
        ),
      );
    }
    return rows;
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
    final bookProvider = context.read<BooksProvider>();
    final accountBook = bookProvider.selectedBook;

    final bookFeatureItems = [
      _GridFeatureItemData(icon: Icons.category_outlined, label: L10nManager.l10n.category, onTap: () => Navigator.pushNamed(context, AppRoutes.categories, arguments: accountBook), isHighlighted: true),
      _GridFeatureItemData(icon: Icons.store_outlined, label: L10nManager.l10n.merchant, onTap: () => Navigator.pushNamed(context, AppRoutes.merchants, arguments: accountBook), isHighlighted: true),
      _GridFeatureItemData(icon: Icons.account_balance_wallet_outlined, label: L10nManager.l10n.account, onTap: () => Navigator.pushNamed(context, AppRoutes.funds, arguments: accountBook), isHighlighted: true),
      _GridFeatureItemData(icon: Icons.local_offer_outlined, label: L10nManager.l10n.tag, onTap: () => Navigator.pushNamed(context, AppRoutes.tags, arguments: accountBook), isHighlighted: true),
      _GridFeatureItemData(icon: Icons.folder_outlined, label: L10nManager.l10n.project, onTap: () => Navigator.pushNamed(context, AppRoutes.projects, arguments: accountBook)),
      _GridFeatureItemData(icon: Icons.repeat, label: L10nManager.l10n.recurringConfig, onTap: () => Navigator.pushNamed(context, AppRoutes.recurringConfigList), isHighlighted: true),
      _GridFeatureItemData(icon: Icons.auto_fix_high, label: L10nManager.l10n.bookkeepingRule, onTap: () => Navigator.pushNamed(context, AppRoutes.bookkeepingRuleList), isHighlighted: true),
    ];

    final dataToolItems = [
      _GridFeatureItemData(
        icon: Icons.book_outlined,
        label: L10nManager.l10n.accountBook,
        onTap: () => Navigator.pushNamed(context, AppRoutes.accountBooks),
      ),
      _GridFeatureItemData(
        icon: Icons.attachment,
        label: L10nManager.l10n.attachment,
        onTap: () => Navigator.pushNamed(context, AppRoutes.attachments),
      ),
      _GridFeatureItemData(
        icon: Icons.card_giftcard,
        label: L10nManager.l10n.giftCard,
        onTap: () => Navigator.pushNamed(context, AppRoutes.giftCardList),
      ),
      _GridFeatureItemData(
        icon: Icons.local_gas_station,
        label: L10nManager.l10n.fuelRecord,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FuelRecordListPage()),
        ),
      ),
      _GridFeatureItemData(
        icon: Icons.emoji_events_outlined,
        label: L10nManager.l10n.tabActivity,
        onTap: () => Navigator.pushNamed(context, AppRoutes.activityCheckin),
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildProfileSliver(context, userProvider, spacing, colorScheme),
          // 账本功能（可折叠展开）
          SliverToBoxAdapter(
            child: Padding(
              padding: spacing.contentPadding.copyWith(top: 16, bottom: 0),
              child: _BookSection(
                icon: Icons.book_outlined,
                title: accountBook?.name ?? '未选择账本',
                items: bookFeatureItems,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.contentPadding.left,
                vertical: 8,
              ),
              child: Divider(
                height: 1,
                color: colorScheme.outlineVariant.withAlpha(60),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: spacing.contentPadding.copyWith(bottom: 0),
              child: _buildSectionHeader(
                context,
                icon: Icons.build_outlined,
                title: '数据工具',
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: spacing.contentPadding.copyWith(top: 12, bottom: 8),
              child: _buildCompactFeatureRow(context, items: dataToolItems),
            ),
          ),
          _buildSectionSliver(
            context,
            spacing: spacing,
            child: _buildSectionCard(
              context,
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
                    child: _buildSectionHeader(
                      context,
                      icon: Icons.settings_outlined,
                      title: L10nManager.l10n.systemSettings,
                    ),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.share_outlined,
                    label: L10nManager.l10n.shareSettings,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.shareSettings),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.palette_outlined,
                    label: L10nManager.l10n.themeSettings,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.themeSettings),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.language_outlined,
                    label: L10nManager.l10n.languageSettings,
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.languageSettings),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.dashboard_outlined,
                    label: L10nManager.l10n.uiLayoutSettings,
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.uiLayoutSettings),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.storage_outlined,
                    label: L10nManager.l10n.database,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.databaseViewer),
                  ),
                  _buildSettingsTile(
                    context,
                    icon: Icons.info_outline,
                    label: L10nManager.l10n.about,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSliver(
    BuildContext context,
    UserProvider provider,
    ThemeSpacing spacing,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                          syncProvider.currentStep ?? '同步中...',
                          style: theme.textTheme.bodySmall,
                          key: const ValueKey('syncing'),
                        )
                      : syncProvider.backgroundSyncing
                          ? Text(
                              '后台同步中 ${(syncProvider.backgroundProgress * 100).toInt()}%',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              key: const ValueKey('background'),
                            )
                          : Text(
                              syncProvider.lastSyncTime != null
                              ? L10nManager.l10n.lastSyncTime(
                                  DateUtil.format(syncProvider.lastSyncTime!))
                              : L10nManager.l10n.notSynced,
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
                onPressed: syncProvider.syncing || syncProvider.backgroundSyncing
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
                onPressed: () => Navigator.pushNamed(context, '/sync_settings'),
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
              padding: const EdgeInsets.only(top: 8, left: 22),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: syncProvider.syncing ? syncProvider.progress : syncProvider.backgroundProgress,
                  minHeight: 2,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ),
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: syncProvider.syncing || syncProvider.backgroundSyncing
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
          ),
        ],
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionSliver(
    BuildContext context, {
    required ThemeSpacing spacing,
    required Widget child,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: spacing.pagePadding.copyWith(top: 0),
        child: child,
      ),
    );
  }

  Widget _buildCompactFeatureRow(
    BuildContext context, {
    required List<_GridFeatureItemData> items,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: items.map((item) {
        return Expanded(
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 24, color: colorScheme.primary),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
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
    );
  }
}
