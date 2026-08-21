import 'package:flutter/material.dart';

import '../../manager/l10n_manager.dart';
import '../../models/vo/statistic_vo.dart';
import '../../models/vo/user_vo.dart';
import '../../routes/app_routes.dart';
import '../common/user_avatar.dart';

/// 用户信息卡片组件
class UserInfoCard extends StatelessWidget {
  /// 用户信息
  final UserVO? user;

  /// 用户统计信息
  final UserStatisticVO? statistic;

  /// 点击回调
  final VoidCallback? onTap;

  const UserInfoCard({
    super.key,
    required this.user,
    this.statistic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap:
            onTap ?? () => Navigator.pushNamed(context, AppRoutes.userInfo),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  UserAvatar(avatar: user?.avatar, size: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nickname ?? L10nManager.l10n.notLoggedIn,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (user?.email != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            user!.email!,
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
                    color: colorScheme.outline,
                  ),
                ],
              ),
              if (statistic != null) ...[
                const SizedBox(height: 14),
                Container(
                  height: 1,
                  color: colorScheme.outlineVariant.withAlpha(80),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildStatItem(
                      context,
                      icon: Icons.book_outlined,
                      iconColor: const Color(0xFF5C6BC0),
                      value: statistic!.bookCount,
                      label: L10nManager.l10n.accountBook,
                    ),
                    _buildStatDivider(context),
                    _buildStatItem(
                      context,
                      icon: Icons.receipt_outlined,
                      iconColor: const Color(0xFF3D6BF5),
                      value: statistic!.itemCount,
                      label: L10nManager.l10n.accountItemCount,
                    ),
                    _buildStatDivider(context),
                    _buildStatItem(
                      context,
                      icon: Icons.calendar_today_outlined,
                      iconColor: const Color(0xFFF0A92E),
                      value: statistic!.dayCount,
                      label: L10nManager.l10n.accountDayCount,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required int value,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: iconColor,
              ),
              const SizedBox(width: 6),
              Text(
                value.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: 26,
      color: colorScheme.outlineVariant.withAlpha(100),
    );
  }
}
