import 'package:flutter/material.dart';
import '../../../models/vo/period_statistics_vo.dart';
import '../../../widgets/common/common_card_container.dart';
import '../../../theme/theme_spacing.dart';
import '../../../manager/l10n_manager.dart';

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
      return CommonCardContainer(
        padding: spacing.contentPadding,
        child: Row(
          children: [
            Icon(Icons.info_outline, color: cs.onSurfaceVariant, size: 20),
            const SizedBox(width: 8),
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

    return CommonCardContainer(
      padding: spacing.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(l10n.cyclePrediction, style: theme.textTheme.titleSmall?.copyWith(
                color: cs.primary, fontWeight: FontWeight.w600,
              )),
            ],
          ),
          SizedBox(height: spacing.formItemSpacing),
          _buildRow(theme, l10n.avgCycle, '${statistics.averageCycleLength}${l10n.days}'),
          _buildRow(theme, l10n.avgPeriod, '${statistics.averagePeriodLength}${l10n.days}'),
          if (statistics.nextPeriodDate != null)
            _buildRow(theme, l10n.nextPeriod, '${statistics.nextPeriodDate}${l10n.predicted}'),
          if (statistics.ovulationDate != null)
            _buildRow(theme, l10n.ovulationDay, '${statistics.ovulationDate}${l10n.predicted}'),
          if (statistics.fertileWindowStart != null && statistics.fertileWindowEnd != null)
            _buildRow(theme, l10n.fertileWindow, '${statistics.fertileWindowStart} ~ ${statistics.fertileWindowEnd}'),
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
