import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/activity_record_vo.dart';

class ActivityRecentRecords extends StatelessWidget {
  final List<ActivityRecordVO> records;
  final VoidCallback? onViewAll;

  const ActivityRecentRecords({
    super.key,
    required this.records,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
            if (records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(L10nManager.l10n.noCheckinRecords,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant)),
              )
            else
              ...records.map((r) => _buildRecordTile(r, theme, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTile(
      ActivityRecordVO record, ThemeData theme, ColorScheme colorScheme) {
    final time = DateTime.fromMillisecondsSinceEpoch(record.createdAt);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('🏃', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(record.activityName,
                style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500)),
          ),
          Text(timeStr,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
