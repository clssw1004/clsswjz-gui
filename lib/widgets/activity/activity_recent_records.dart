import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/activity_definition_vo.dart';

/// 最近打卡活动摘要（按活动分组展示）
class ActivityRecentRecords extends StatelessWidget {
  final List<ActivityDefinitionVO> definitions;
  final Map<String, int> todayCounts;
  final VoidCallback? onViewAll;

  const ActivityRecentRecords({
    super.key,
    required this.definitions,
    required this.todayCounts,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final activeDefs = definitions
        .where((d) => (todayCounts[d.id] ?? 0) > 0)
        .toList();

    if (activeDefs.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withAlpha(60),
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_outlined,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(L10nManager.l10n.recentCheckins,
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                if (onViewAll != null)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Row(
                      children: [
                        Text(L10nManager.l10n.viewAll,
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary)),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right,
                            size: 16, color: colorScheme.primary),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...activeDefs.map((d) => _buildRow(d, theme, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    ActivityDefinitionVO def,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final count = todayCounts[def.id] ?? 0;
    final bgColor = Color(def.color);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(def.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(def.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: bgColor.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              L10nManager.l10n.activityTimes(count),
              style: theme.textTheme.labelSmall?.copyWith(
                color: bgColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
