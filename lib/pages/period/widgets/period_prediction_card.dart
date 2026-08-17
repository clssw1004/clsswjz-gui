import 'package:flutter/material.dart';
import '../../../models/vo/period_statistics_vo.dart';
import '../../../widgets/common/common_card_container.dart';
import '../../../theme/theme_spacing.dart';

class PeriodPredictionCard extends StatelessWidget {
  final PeriodStatisticsVO statistics;
  const PeriodPredictionCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final cs = theme.colorScheme;

    if (!statistics.canPredict) {
      return CommonCardContainer(
        padding: spacing.contentPadding,
        child: Row(
          children: [
            Icon(Icons.info_outline, color: cs.onSurfaceVariant, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '至少需要2个完整周期才能预测',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return CommonCardContainer(
      padding: spacing.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text('周期预测', style: theme.textTheme.titleSmall?.copyWith(
                color: cs.primary, fontWeight: FontWeight.w600,
              )),
            ],
          ),
          SizedBox(height: spacing.formItemSpacing),
          _buildRow(theme, '平均周期', '${statistics.averageCycleLength}天'),
          _buildRow(theme, '平均经期', '${statistics.averagePeriodLength}天'),
          if (statistics.nextPeriodDate != null)
            _buildRow(theme, '下次经期', '${statistics.nextPeriodDate}（预计）'),
          if (statistics.ovulationDate != null)
            _buildRow(theme, '排卵日', '${statistics.ovulationDate}（预计）'),
          if (statistics.fertileWindowStart != null && statistics.fertileWindowEnd != null)
            _buildRow(theme, '危险期', '${statistics.fertileWindowStart} ~ ${statistics.fertileWindowEnd}'),
        ],
      ),
    );
  }

  Widget _buildRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }
}
