import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/dao_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/service_manager.dart';
import '../../providers/shared_module_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/common_dialog.dart';
import '../../widgets/common/common_user_picker.dart';
import '../../models/vo/attachment_vo.dart';
import '../../widgets/common/user_avatar.dart';

List<_ShareModule> get _modules => [
      _ShareModule('vehicle', Icons.directions_car_outlined,
          L10nManager.l10n.moduleVehicle),
      _ShareModule('fuelRecord', Icons.local_gas_station_outlined,
          L10nManager.l10n.moduleFuelRecord),
      _ShareModule('debt', Icons.account_balance_outlined,
          L10nManager.l10n.moduleDebt),
      _ShareModule('activity', Icons.emoji_events_outlined,
          L10nManager.l10n.tabActivity),
    ];

class _ShareModule {
  final String businessType;
  final IconData icon;
  final String label;
  const _ShareModule(this.businessType, this.icon, this.label);
}

/// 数据共享设置页
class ShareSettingsPage extends StatefulWidget {
  const ShareSettingsPage({super.key});

  @override
  State<ShareSettingsPage> createState() => _ShareSettingsPageState();
}

class _ShareSettingsPageState extends State<ShareSettingsPage> {
  List<_UserItem> _users = [];
  bool _loadingUsers = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    try {
      final provider = context.read<SharedModuleProvider>();
      await provider.loadAll();

      // Collect unique target user IDs from all shares
      final targetUserIds = <String>{};
      for (final share in provider.myShareList) {
        targetUserIds.add(share.targetUserId);
      }

      final items = <_UserItem>[];
      if (targetUserIds.isNotEmpty) {
        final users =
            await DaoManager.userDao.findByIds(targetUserIds.toList());
        // Batch load avatars
        final avatarIds = users
            .map((u) => u.avatar ?? '')
            .where((a) => a.isNotEmpty)
            .toList();
        final avatarMap = <String, AttachmentVO?>{};
        if (avatarIds.isNotEmpty) {
          try {
            final attachments = await ServiceManager.attachmentService
                .getAttachments(avatarIds);
            for (final a in attachments) {
              avatarMap[a.id] = a;
            }
          } catch (_) {}
        }
        for (final u in users) {
          final avatarId = u.avatar ?? '';
          items.add(_UserItem(
            userId: u.id,
            nickname: u.nickname.isNotEmpty ? u.nickname : u.username,
            avatar: avatarId.isNotEmpty ? avatarMap[avatarId] : null,
          ));
        }
      }
      if (mounted) {
        setState(() {
          _users = items;
          _loadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingUsers = false);
      }
    }
  }

  Future<void> _addUser() async {
    final excludeIds = _users.map((u) => u.userId).toSet();
    final option = await CommonUserPicker.showPicker(
      context: context,
      userId: AppConfigManager.instance.userId,
      excludeIds: excludeIds,
    );
    if (option != null && mounted) {
      setState(() => _users.add(_UserItem(
            userId: option.userId,
            nickname: option.nickname,
          )));
    }
  }

  Future<void> _removeUser(String userId) async {
    if (!mounted) return;
    final provider = context.read<SharedModuleProvider>();
    final confirm = await CommonDialog.showWarning(
      context: context,
      message: L10nManager.l10n.confirmRemoveShare,
    );
    if (confirm != true) return;
    for (final m in _modules) {
      await provider.setShare(userId, m.businessType, enabled: false);
    }
    if (mounted) setState(() => _users.removeWhere((u) => u.userId == userId));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(title: Text(L10nManager.l10n.shareSettings)),
      floatingActionButton: FloatingActionButton(
        heroTag: 'share_add_user',
        onPressed: _addUser,
        child: const Icon(Icons.person_add_outlined),
      ),
      body: Consumer<SharedModuleProvider>(
        builder: (context, provider, _) {
          if (_loadingUsers) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text(L10nManager.l10n.noSharedUsers,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _addUser,
                    icon: const Icon(Icons.person_add_outlined),
                    label: Text(L10nManager.l10n.addUser),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.separated(
              padding: spacing.pagePadding,
              itemCount: _users.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: spacing.listItemSpacing),
              itemBuilder: (_, i) {
                final user = _users[i];
                return CommonCardContainer(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User header with avatar
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                            spacing.formPadding.left,
                            spacing.formPadding.top,
                            spacing.formPadding.right,
                            spacing.formItemSpacing),
                        child: Row(
                          children: [
                            UserAvatar(
                              size: 44,
                              avatar: user.avatar,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(user.nickname,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                            ),
                            IconButton(
                              icon: Icon(Icons.person_remove_outlined,
                                  color: colorScheme.error, size: 20),
                              onPressed: () => _removeUser(user.userId),
                              tooltip: '移除',
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      // Module toggles
                      ..._modules.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final m = entry.value;
                        final isShared =
                            provider.isSharedTo(user.userId, m.businessType);
                        return InkWell(
                          onTap: () => provider.setShare(
                              user.userId, m.businessType,
                              enabled: !isShared),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                spacing.formPadding.left,
                                spacing.formItemSpacing,
                                spacing.formPadding.right,
                                idx == _modules.length - 1
                                    ? spacing.formPadding.bottom
                                    : spacing.formItemSpacing),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isShared
                                        ? colorScheme.primaryContainer
                                        : colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    m.icon,
                                    size: 20,
                                    color: isShared
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    m.label,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: isShared
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: isShared
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.85,
                                  child: SizedBox(
                                    width: 48,
                                    height: 32,
                                    child: Switch(
                                      value: isShared,
                                      activeThumbColor: colorScheme.primary,
                                      onChanged: (on) => provider.setShare(
                                          user.userId, m.businessType,
                                          enabled: on),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _UserItem {
  final String userId;
  final String nickname;
  final AttachmentVO? avatar;

  const _UserItem({
    required this.userId,
    required this.nickname,
    this.avatar,
  });
}
