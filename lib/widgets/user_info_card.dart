import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/vo/statistic_vo.dart';
import '../models/vo/user_vo.dart';
import '../routes/app_routes.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap ?? () => Navigator.pushNamed(context, AppRoutes.userInfo),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 用户基本信息
                    Text(
                      user?.nickname ?? l10n.notLoggedIn,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: 4),
                      // 邮箱
                      Text(
                        user!.email!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 统计信息
              if (statistic != null) ...[
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatisticItem(
                      context,
                      icon: Icons.book_outlined,
                      value: statistic!.bookCount,
                      label: l10n.accountBook,
                    ),
                    const SizedBox(height: 8),
                    _buildStatisticItem(
                      context,
                      icon: Icons.receipt_outlined,
                      value: statistic!.itemCount,
                      label: l10n.accountItemCount,
                    ),
                    const SizedBox(height: 8),
                    _buildStatisticItem(
                      context,
                      icon: Icons.calendar_today_outlined,
                      value: statistic!.dayCount,
                      label: l10n.accountDayCount,
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

  Widget _buildStatisticItem(
    BuildContext context, {
    required IconData icon,
    required int value,
    required String label,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 90, // 减小整体宽度
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // 使用spaceBetween替代Expanded
        children: [
          // 图标和文字左对齐
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          // 数字右对齐
          Text(
            value.toString(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
