import 'package:flutter/material.dart';

class PeriodLegend extends StatelessWidget {
  const PeriodLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildItem(cs, theme, cs.error, '经期'),
        const SizedBox(width: 12),
        _buildItem(cs, theme, cs.tertiary, '排卵期'),
        const SizedBox(width: 12),
        _buildItem(cs, theme, Colors.green, '安全区'),
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
