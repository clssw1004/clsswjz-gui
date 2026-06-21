import 'package:flutter/material.dart';
import '../../models/vo/activity_statistic_vo.dart';
import '../../pages/activity/activity_detail_page.dart';
import '../common/common_card_container.dart';
import '../../manager/l10n_manager.dart';

final List<Color> _activityPalette = [
  const Color(0xFF5C6BC0),
  const Color(0xFF26A69A),
  const Color(0xFFFF7043),
  const Color(0xFFAB47BC),
  const Color(0xFF42A5F5),
  const Color(0xFF66BB6A),
  const Color(0xFFEC407A),
  const Color(0xFFFFA726),
  const Color(0xFF26C6DA),
  const Color(0xFF8D6E63),
  const Color(0xFF78909C),
  const Color(0xFFEF5350),
];

Color _colorForActivity(String name) {
  final index = name.hashCode.abs() % _activityPalette.length;
  return _activityPalette[index];
}

/// 活动统计卡片组件
class ActivityStatisticCard extends StatelessWidget {
  final List<ActivityStatisticVO> data;
  final bool loading;

  const ActivityStatisticCard({
    super.key,
    required this.data,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CommonCardContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Icon(Icons.playlist_add_check,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  L10nManager.l10n.activityStatistics,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (data.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    L10nManager.l10n.noData,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...data.map((stat) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: stat.definition != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActivityDetailPage(
                                definition: stat.definition!,
                              ),
                            ),
                          );
                        }
                      : null,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _colorForActivity(stat.activityName),
                      child: Text(
                        stat.emoji.isNotEmpty
                            ? stat.emoji
                            : (stat.activityName.isNotEmpty
                                ? stat.activityName[0]
                                : '?'),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        stat.activityName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        L10nManager.l10n.activityTimes(stat.count),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),   // close Row
              ),     // close InkWell
            )),      // close Padding + map expr

            // 合计
            if (data.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      L10nManager.l10n.activityTimes(data.fold<int>(0, (sum, s) => sum + s.count)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
