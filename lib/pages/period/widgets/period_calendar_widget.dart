import 'package:flutter/material.dart';
import '../../../models/vo/period_record_vo.dart';
import '../../../models/vo/period_statistics_vo.dart';
import '../../../services/period_prediction_service.dart';

class PeriodCalendarWidget extends StatelessWidget {
  final int year;
  final int month;
  final List<PeriodRecordVO> records;
  final PeriodStatisticsVO? statistics;
  final String? selectedDate;
  final ValueChanged<String> onDateTap;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  const PeriodCalendarWidget({
    super.key,
    required this.year,
    required this.month,
    required this.records,
    this.statistics,
    this.selectedDate,
    required this.onDateTap,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateTypes = PeriodPredictionService.getMonthDateTypes(records, statistics);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final firstDay = DateTime(year, month, 1);
    final startWeekday = firstDay.weekday % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: cs.onSurface),
              onPressed: onPreviousMonth,
            ),
            Text(
              '$year年$month月',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: cs.onSurface),
              onPressed: onNextMonth,
            ),
          ],
        ),
        Row(
          children: ['日', '一', '二', '三', '四', '五', '六'].map((d) {
            return Expanded(
              child: Center(
                child: Text(d, style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        ...List.generate(((startWeekday + daysInMonth + 6) ~/ 7), (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final cellIndex = weekIndex * 7 + dayIndex;
              final dayNum = cellIndex - startWeekday + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }
              final dateStr = '$year-${month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
              final dateType = dateTypes[dateStr];
              final isToday = dateStr == todayStr;
              final isSelected = dateStr == selectedDate;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDateTap(dateStr),
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary.withAlpha(40)
                          : _getBackgroundColor(cs, dateType),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: cs.primary, width: 2)
                          : isToday
                              ? Border.all(color: cs.primary, width: 2)
                              : dateType == DateType.predictedPeriod
                                  ? Border.all(color: cs.error.withAlpha(128), width: 1)
                                  : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? cs.primary : _getTextColor(cs, dateType),
                          fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Color? _getBackgroundColor(ColorScheme cs, DateType? type) {
    return switch (type) {
      DateType.period => cs.error.withAlpha(46),
      DateType.ovulation => cs.tertiary.withAlpha(60),
      DateType.fertile => cs.tertiary.withAlpha(30),
      DateType.safe => Colors.green.withAlpha(20),
      DateType.predictedPeriod => cs.error.withAlpha(15),
      null => null,
    };
  }

  Color _getTextColor(ColorScheme cs, DateType? type) {
    return switch (type) {
      DateType.period => cs.error,
      DateType.ovulation => cs.tertiary,
      _ => cs.onSurface,
    };
  }
}
