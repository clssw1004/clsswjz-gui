import 'package:flutter/material.dart';
import '../../manager/dao_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/attachment_vo.dart';
import 'user_avatar.dart';

/// 用户选项
class UserPickerOption {
  final String userId;
  final String nickname;

  const UserPickerOption({required this.userId, required this.nickname});
}

/// 通用用户选择器组件
///
/// 弹出底部弹窗，从账本成员中选择用户。支持搜索过滤和排除已有用户。
/// 视觉风格与 [CommonSelectFormField] 一致。
class CommonUserPicker {
  /// 显示用户选择底部弹窗
  ///
  /// [userId] 当前用户 ID
  /// [excludeIds] 需要排除的用户 ID 集合（如已添加用户）
  /// 返回选中的 [UserPickerOption]，用户取消则返回 null
  static Future<UserPickerOption?> showPicker({
    required BuildContext context,
    required String userId,
    Set<String>? excludeIds,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = L10nManager.l10n;

    // Load eligible users with avatars
    final users = await DaoManager.userDao.findSelectableRecipients(userId);
    final filtered =
        users.where((u) => excludeIds == null || !excludeIds.contains(u.id));
    final options = filtered
        .map((u) => UserPickerOption(
              userId: u.id,
              nickname: u.nickname.isNotEmpty ? u.nickname : u.username,
            ))
        .toList();

    // Batch load avatar attachments
    final avatarIds = filtered
        .map((u) => u.avatar ?? '')
        .where((a) => a.isNotEmpty)
        .toList();
    final avatarMap = <String, AttachmentVO?>{};
    if (avatarIds.isNotEmpty) {
      try {
        final attachments =
            await ServiceManager.attachmentService.getAttachments(avatarIds);
        for (final a in attachments) {
          avatarMap[a.id] = a;
        }
      } catch (_) {}
    }
    final avatarById = <String, AttachmentVO?>{};
    for (final u in filtered) {
      final avatarId = u.avatar ?? '';
      if (avatarId.isNotEmpty && avatarMap.containsKey(avatarId)) {
        avatarById[u.id] = avatarMap[avatarId];
      }
    }

    if (!context.mounted) return null;

    String searchQuery = '';

    return showModalBottomSheet<UserPickerOption>(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = searchQuery.isEmpty
                ? options
                : options
                    .where((o) => o.nickname
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: [
                  // Drag handle
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withAlpha(60),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(l10n.addUser,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              color: colorScheme.onSurfaceVariant),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  // Search field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        prefixIcon: Icon(Icons.search,
                            color: colorScheme.onSurfaceVariant),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) =>
                          setSheetState(() => searchQuery = value),
                    ),
                  ),
                  const Divider(height: 1),
                  // User list
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(l10n.noSharedUsers,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant)),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1, indent: 72),
                            itemBuilder: (_, i) {
                              final option = filtered[i];
                              return ListTile(
                                leading: UserAvatar(
                                  size: 40,
                                  avatar: avatarById[option.userId],
                                ),
                                title: Text(option.nickname,
                                    style: theme.textTheme.bodyLarge),
                                onTap: () =>
                                    Navigator.of(context).pop(option),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
