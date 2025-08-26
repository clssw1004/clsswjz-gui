import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../models/vo/statistic_vo.dart';
import '../../../manager/l10n_manager.dart';
import '../../../manager/app_config_manager.dart';
import '../../common/common_card_container.dart';
import '../../../utils/color_util.dart';

class DailyStatisticCalendar extends StatelessWidget {
  const DailyStatisticCalendar({
    super.key,
    required this.dailyStats,
    this.loading = false,
  });

  final List<DailyStatisticVO> dailyStats;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (loading) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (dailyStats.isEmpty) {
      return CommonCardContainer(
        child: SizedBox(
          height: 220,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 48,
                  color: colorScheme.onSurfaceVariant.withAlpha(100),
                ),
                const SizedBox(height: 16),
                Text(
                  L10nManager.l10n.noData,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final Map<DateTime, DailyStatisticVO> dateToStat = {
      for (final s in dailyStats) DateTime.parse(s.date): s,
    };

    final DateTime firstDay =
        dateToStat.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final DateTime lastDay =
        dateToStat.keys.reduce((a, b) => a.isAfter(b) ? a : b);
    final DateTime now = DateTime.now();
    final DateTime focusedDay = now.isAfter(lastDay) ? lastDay : now;

    return CommonCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  L10nManager.l10n.dailyIncomeExpense,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          TableCalendar(
            firstDay: firstDay,
            lastDay: lastDay,
            focusedDay: focusedDay,
            rowHeight: 58,
            locale: AppConfigManager.instance.locale.languageCode,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              leftChevronVisible: false,
              rightChevronVisible: false,
              titleTextStyle: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ) ?? const TextStyle(),
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(40),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final stat = dateToStat[DateTime(day.year, day.month, day.day)];
                return _buildDayCell(context, stat);
              },
              todayBuilder: (context, day, focusedDay) {
                final stat = dateToStat[DateTime(day.year, day.month, day.day)];
                return _buildDayCell(context, stat, highlightToday: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DailyStatisticVO? stat,
      {bool highlightToday = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final income = stat?.income ?? 0;
    final expense = (stat?.expense ?? 0).abs();
    final hasData = income != 0 || expense != 0;

    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 16,
            child: Center(
              child: Text(
                '${stat != null ? DateTime.parse(stat.date).day : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: highlightToday ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 30,
            child: hasData
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (expense > 0)
                        Text(
                          '-${expense.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ColorUtil.EXPENSE,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (income > 0)
                        Text(
                          '+${income.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ColorUtil.INCOME,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
