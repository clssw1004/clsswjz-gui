import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../database/database.dart';
import '../models/vo/statistic_vo.dart';
import '../routes/app_routes.dart';

/// 用户信息卡片组件
class UserInfoCard extends StatelessWidget {
  /// 用户信息
  final User? user;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              // 统计信息
              if (statistic != null) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    // 账本数量
                    Expanded(
                      child: _buildStatisticItem(
                        context,
                        value: statistic!.bookCount,
                        label: l10n.accountBook,
                      ),
                    ),
                    // 账目数量
                    Expanded(
                      child: _buildStatisticItem(
                        context,
                        value: statistic!.itemCount,
                        label: l10n.accountItemCount,
                      ),
                    ),
                    // 记账天数
                    Expanded(
                      child: _buildStatisticItem(
                        context,
                        value: statistic!.dayCount,
                        label: l10n.accountDayCount,
                      ),
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
    required int value,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
