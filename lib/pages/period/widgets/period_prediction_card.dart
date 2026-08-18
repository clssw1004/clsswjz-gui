import 'package:flutter/material.dart';
import '../../../models/vo/period_statistics_vo.dart';
import '../../../theme/theme_spacing.dart';
import '../../../manager/l10n_manager.dart';

/// 预测统计 Tile 网格（2x2 布局）
///
/// 每个 tile 有独立图标 + 标签 + 数值
/// 数据不足时显示引导文案
class PeriodPredictionCard extends StatelessWidget {
  final PeriodStatisticsVO statistics;
  const PeriodPredictionCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final cs = theme.colorScheme;
    final l10n = L10nManager.l10n;

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

    return Column(
      children: [
        // 第一行
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context,
                icon: Icons.autorenew,
                label: l10n.avgCycleTile,
                value: '${statistics.averageCycleLength}',
                unit: l10n.days,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTile(
                context,
                icon: Icons.water_drop_outlined,
                label: l10n.avgPeriodTile,
                value: '${statistics.averagePeriodLength}',
                unit: l10n.days,
                color: cs.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 第二行
        Row(
          children: [
            Expanded(
              child: _buildTile(
                context,
                icon: Icons.calendar_today,
                label: l10n.nextPeriodTile,
                value: statistics.nextPeriodDate != null
                    ? statistics.nextPeriodDate!.substring(5)
                    : '-',
                unit: '',
                color: cs.tertiary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildTile(
                context,
                icon: Icons.egg_outlined,
                label: l10n.ovulationTile,
                value: statistics.ovulationDate != null
                    ? statistics.ovulationDate!.substring(5)
                    : '-',
                unit: '',
                color: cs.tertiary,
              ),
            ),
          ],
        ),
        // 易孕期（如果有）
        if (statistics.fertileWindowStart != null &&
            statistics.fertileWindowEnd != null) ...[
          const SizedBox(height: 10),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withAlpha(30),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              text: value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              children: unit.isNotEmpty
                  ? [
                      TextSpan(
                        text: ' $unit',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.normal,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(30), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
