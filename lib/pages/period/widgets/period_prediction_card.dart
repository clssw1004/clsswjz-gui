import 'package:flutter/material.dart';
import '../../../models/vo/period_statistics_vo.dart';
import '../../../theme/theme_spacing.dart';
import '../../../manager/l10n_manager.dart';

/// 预测统计 Tile 网格（2x4 紧凑布局）
///
/// 放在日历下方，小尺寸方格展示平均周期/经期/下次/排卵/易孕期
class PeriodPredictionCard extends StatelessWidget {
  final PeriodStatisticsVO statistics;
  const PeriodPredictionCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final cs = theme.colorScheme;
    final l10n = L10nManager.l10n;

    // 数据不足时显示引导
    if (!statistics.canPredict) {
      return Container(
        padding: spacing.contentPadding,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withAlpha(60),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cs.outlineVariant.withAlpha(60),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.insights_outlined, color: cs.onSurfaceVariant.withAlpha(120), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.needMoreCycles,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 数据项列表
    final items = <({IconData icon, String label, String value, String unit, Color color})>[
      (
        icon: Icons.autorenew,
        label: l10n.avgCycleTile,
        value: '${statistics.averageCycleLength}',
        unit: l10n.days,
        color: cs.primary,
      ),
      (
        icon: Icons.water_drop_outlined,
        label: l10n.avgPeriodTile,
        value: '${statistics.averagePeriodLength}',
        unit: l10n.days,
        color: cs.error,
      ),
      (
        icon: Icons.calendar_today,
        label: l10n.nextPeriodTile,
        value: statistics.nextPeriodDate != null
            ? statistics.nextPeriodDate!.substring(5)
            : '-',
        unit: '',
        color: cs.tertiary,
      ),
      (
        icon: Icons.egg_outlined,
        label: l10n.ovulationTile,
        value: statistics.ovulationDate != null
            ? statistics.ovulationDate!.substring(5)
            : '-',
        unit: '',
        color: cs.tertiary,
      ),
    ];

    // 如果有易孕期信息，追加一个宽条目
    final hasFertile = statistics.fertileWindowStart != null &&
        statistics.fertileWindowEnd != null;

    return Column(
      children: [
        // 2x2 紧凑网格
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context,
                icon: items[0].icon,
                label: items[0].label,
                value: items[0].value,
                unit: items[0].unit,
                color: items[0].color,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTile(
                context,
                icon: items[1].icon,
                label: items[1].label,
                value: items[1].value,
                unit: items[1].unit,
                color: items[1].color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context,
                icon: items[2].icon,
                label: items[2].label,
                value: items[2].value,
                unit: items[2].unit,
                color: items[2].color,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTile(
                context,
                icon: items[3].icon,
                label: items[3].label,
                value: items[3].value,
                unit: items[3].unit,
                color: items[3].color,
              ),
            ),
          ],
        ),
        if (hasFertile) ...[
          const SizedBox(height: 8),
          _buildWideTile(
            context,
            icon: Icons.favorite_outline,
            label: l10n.fertileTile,
            value:
                '${statistics.fertileWindowStart!.substring(5)} ~ ${statistics.fertileWindowEnd!.substring(5)}',
            color: Colors.pink,
          ),
        ],
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(24),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          RichText(
            text: TextSpan(
              text: value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
                fontSize: 16,
              ),
              children: unit.isNotEmpty
                  ? [
                      TextSpan(
                        text: ' $unit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(24), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}