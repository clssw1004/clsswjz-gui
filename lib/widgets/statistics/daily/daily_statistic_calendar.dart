import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import '../../../models/vo/statistic_vo.dart';
import '../../../manager/l10n_manager.dart';
import '../../../manager/app_config_manager.dart';
import '../../common/common_card_container.dart';
import '../../../utils/color_util.dart';

class DailyStatisticCalendar extends StatefulWidget {
  const DailyStatisticCalendar({
    super.key,
    required this.dailyStats,
    this.loading = false,
  });

  final List<DailyStatisticVO> dailyStats;
  final bool loading;

  @override
  State<DailyStatisticCalendar> createState() => _DailyStatisticCalendarState();
}

class _DailyStatisticCalendarState extends State<DailyStatisticCalendar> {
  late bool _showIncome;
  late bool _showExpense;

  @override
  void initState() {
    super.initState();
    // 从配置中读取初始状态
    final uiConfig = AppConfigManager.instance.uiConfig;
    _showIncome = uiConfig.calendarShowIncome;
    _showExpense = uiConfig.calendarShowExpense;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.loading) {
      return const SizedBox(
        height: 280,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.dailyStats.isEmpty) {
      return CommonCardContainer(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        child: SizedBox(
          height: 410,
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
      for (final s in widget.dailyStats) DateTime.parse(s.date): s,
    };

    final DateTime firstDay =
        dateToStat.keys.reduce((a, b) => a.isBefore(b) ? a : b);
    final DateTime lastDay =
        dateToStat.keys.reduce((a, b) => a.isAfter(b) ? a : b);
    final DateTime now = DateTime.now();
    final DateTime focusedDay = now.isAfter(lastDay) ? lastDay : now;
    final int currentMonth = focusedDay.month;
    final int currentYear = focusedDay.year;

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
          // 切换按钮 - 居中显示（可多选）
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 支出按钮（多选）
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _showExpense = !_showExpense;
                    });
                    // 保存配置到本地
                    await AppConfigManager.instance.updateCalendarDisplayConfig(
                      showExpense: _showExpense,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _showExpense
                          ? theme.colorScheme.surfaceContainerHighest.withAlpha(40)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _showExpense
                            ? ColorUtil.EXPENSE
                            : theme.colorScheme.outline.withAlpha(120),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      L10nManager.l10n.expense,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _showExpense ? ColorUtil.EXPENSE : theme.colorScheme.onSurfaceVariant,
                        fontWeight: _showExpense ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 收入按钮（多选）
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      _showIncome = !_showIncome;
                    });
                    // 保存配置到本地
                    await AppConfigManager.instance.updateCalendarDisplayConfig(
                      showIncome: _showIncome,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _showIncome
                          ? theme.colorScheme.surfaceContainerHighest.withAlpha(40)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _showIncome
                            ? ColorUtil.INCOME
                            : theme.colorScheme.outline.withAlpha(120),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      L10nManager.l10n.income,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _showIncome ? ColorUtil.INCOME : theme.colorScheme.onSurfaceVariant,
                        fontWeight: _showIncome ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 390,
            child: SfCalendar(
              view: CalendarView.month,
              showNavigationArrow: false,
              showDatePickerButton: false,
              minDate: firstDay,
              maxDate: lastDay,
              initialDisplayDate: focusedDay,
              monthViewSettings: MonthViewSettings(
                showAgenda: false,
                navigationDirection: MonthNavigationDirection.horizontal,
                numberOfWeeksInView: 6,
                showTrailingAndLeadingDates: false,
              ),
              headerStyle: CalendarHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ) ??
                    const TextStyle(),
              ),
              viewHeaderStyle: ViewHeaderStyle(
                dayTextStyle: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ) ??
                    const TextStyle(fontSize: 11),
              ),
              monthCellBuilder: (context, details) {
                final DateTime day = DateTime(details.date.year, details.date.month, details.date.day);
                if (day.month != currentMonth || day.year != currentYear) {
                  return const SizedBox.shrink();
                }
                final stat = dateToStat[day];
                return _buildMonthCell(context, theme, colorScheme, day, stat);
              },
              onViewChanged: (viewChangedDetails) {},
              todayHighlightColor: colorScheme.primary,
              backgroundColor: Colors.transparent,
              cellBorderColor: colorScheme.outline.withAlpha(40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCell(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    DateTime day,
    DailyStatisticVO? stat,
  ) {
    final income = stat?.income ?? 0;
    final expense = (stat?.expense ?? 0).abs();
    final hasIncome = _showIncome && income > 0;
    final hasExpense = _showExpense && expense > 0;
    final hasData = hasIncome || hasExpense;

    // 顶部日期文本，使用本地化短格式（仅展示日）
    final String dayText = DateFormat.d().format(day);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 18,
            child: Center(
              child: Text(
                dayText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
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
                      if (hasExpense)
                        Text(
                          '-${expense.toStringAsFixed(0)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: ColorUtil.EXPENSE,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (hasIncome)
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
