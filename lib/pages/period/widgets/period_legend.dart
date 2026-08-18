import 'package:flutter/material.dart';
import '../../../manager/l10n_manager.dart';

class PeriodLegend extends StatelessWidget {
  const PeriodLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = L10nManager.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildItem(cs, theme, cs.error, l10n.legendPeriod),
        const SizedBox(width: 12),
        _buildItem(cs, theme, cs.tertiary, l10n.legendOvulation),
        const SizedBox(width: 12),
        _buildItem(cs, theme, cs.tertiaryContainer, l10n.legendSafe),
      ],
    );
  }

  Widget _buildItem(ColorScheme cs, ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withAlpha(46),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
