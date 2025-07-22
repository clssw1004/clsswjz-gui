import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';

/// 时间范围选择器组件
class TimeRangeSelector extends StatelessWidget {
  final String selectedRange;
  final DateTimeRange? customRange;
  final void Function(String, DateTimeRange?) onChanged;

  const TimeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.customRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10nManager.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ranges = [
      'all',
      'year',
      'month',
      'week',
      'custom',
    ];
    final rangeLabels = {
      'all': l10n.timeRangeAll,
      'year': l10n.timeRangeYear,
      'month': l10n.timeRangeMonth,
      'week': l10n.timeRangeWeek,
      'custom': l10n.timeRangeCustom,
    };

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer ,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.selectTimeRange,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRange,
                borderRadius: BorderRadius.circular(12),
                style: theme.textTheme.bodyMedium,
                dropdownColor: colorScheme.surface,
                items: ranges
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(rangeLabels[r] ?? r),
                        ))
                    .toList(),
                onChanged: (value) async {
                  if (value == null) return;
                  if (value == 'custom') {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 10),
                      lastDate: DateTime(now.year + 1, 12, 31),
                      initialDateRange:
                          customRange ?? DateTimeRange(start: now, end: now),
                      builder: (context, child) {
                        return Theme(
                          data: theme.copyWith(
                            colorScheme: colorScheme,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      onChanged(value, picked);
                    }
                  } else {
                    onChanged(value, null);
                  }
                },
              ),
            ),
            if (selectedRange == 'custom' && customRange != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${customRange!.start.year}/${customRange!.start.month}/${customRange!.start.day} - '
                  '${customRange!.end.year}/${customRange!.end.month}/${customRange!.end.day}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 