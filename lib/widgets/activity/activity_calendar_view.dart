import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import '../../drivers/driver_factory.dart';
import '../../events/event_bus.dart';
import '../../events/special/event_book.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/activity_record_vo.dart';
import '../../models/vo/activity_statistic_vo.dart';

class ActivityCalendarView extends StatefulWidget {
  const ActivityCalendarView({super.key});

  @override
  State<ActivityCalendarView> createState() => ActivityCalendarViewState();
}

class ActivityCalendarViewState extends State<ActivityCalendarView> {
  DateTime _selectedDate = DateTime.now();
  List<ActivityRecordVO> _monthRecords = [];
  List<ActivityStatisticVO> _monthStats = [];
  bool _loading = false;
  StreamSubscription? _activityChangedSubscription;

  String? get _bookId => AppConfigManager.instance.defaultBookId;

  @override
  void initState() {
    super.initState();
    _loadMonthData();
    _activityChangedSubscription =
        EventBus.instance.on<ActivityChangedEvent>((event) {
      _loadMonthData();
    });
  }

  @override
  void dispose() {
    _activityChangedSubscription?.cancel();
    super.dispose();
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// 加载当前月份的活动记录和统计
  Future<void> _loadMonthData() async {
    if (_loading || _bookId == null) return;
    setState(() => _loading = true);

    try {
      final startDate = _formatDate(DateTime(_selectedDate.year, _selectedDate.month, 1));
      final endDate = _formatDate(DateTime(_selectedDate.year, _selectedDate.month + 1, 0));
      final userId = AppConfigManager.instance.userId;

      final recordsResult = await DriverFactory.driver.listActivityRecordsByBook(
        userId, _bookId!,
        startDate: startDate,
        endDate: endDate,
        limit: 366,
      );

      final statsResult = await DriverFactory.driver.getActivityStatistics(
        userId, _bookId!,
        startDate: startDate,
        endDate: endDate,
      );

      if (!mounted) return;
      setState(() {
        if (recordsResult.ok) _monthRecords = recordsResult.data ?? [];
        if (statsResult.ok) _monthStats = statsResult.data ?? [];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 外部调用：添加活动后刷新
  Future<void> refreshData() async {
    await _loadMonthData();
  }

  /// 是否有某日的活动
  bool _hasActivity(DateTime day) {
    final key = _formatDate(day);
    return _monthRecords.any((r) => r.recordDate == key);
  }

  /// 获取某日的活动
  List<ActivityRecordVO> _getDayRecords(DateTime day) {
    final key = _formatDate(day);
    return _monthRecords.where((r) => r.recordDate == key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10nManager.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading && _monthRecords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final locale = Localizations.localeOf(context).toString();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          // 日历卡片
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SizedBox(
              height: 392,
              child: SfCalendar(
                view: CalendarView.month,
                showNavigationArrow: true,
                showDatePickerButton: false,
                initialDisplayDate: _selectedDate,
                initialSelectedDate: _selectedDate,
                minDate: DateTime.utc(2020, 1, 1),
                maxDate: DateTime.now(),
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.primary.withAlpha(77),
                    width: 1.5,
                  ),
                ),
                monthViewSettings: MonthViewSettings(
                  numberOfWeeksInView: 6,
                  showAgenda: false,
                  showTrailingAndLeadingDates: false,
                  appointmentDisplayMode: MonthAppointmentDisplayMode.none,
                ),
                headerStyle: CalendarHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ) ??
                      const TextStyle(),
                ),
                viewHeaderStyle: ViewHeaderStyle(
                  dayTextStyle: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(179),
                        fontWeight: FontWeight.w500,
                      ) ??
                      const TextStyle(fontSize: 11),
                ),
                monthCellBuilder: (context, details) {
                  final day = DateTime(
                    details.date.year,
                    details.date.month,
                    details.date.day,
                  );
                  if (day.month != _selectedDate.month ||
                      day.year != _selectedDate.year) {
                    return const SizedBox.shrink();
                  }
                  final isToday = _isSameDate(day, DateTime.now());
                  final isSelected = _isSameDate(day, _selectedDate);
                  final hasActivity = _hasActivity(day);

                  return Container(
                    margin: EdgeInsets.zero,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primary,
                                colorScheme.primary.withAlpha(230),
                              ],
                            )
                          : isToday
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colorScheme.primary.withAlpha(38),
                                    colorScheme.primary.withAlpha(13),
                                  ],
                                )
                              : null,
                      border: isToday && !isSelected
                          ? Border.all(
                              color: colorScheme.primary.withAlpha(77),
                              width: 1.5,
                            )
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withAlpha(64),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${day.day}',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : isToday
                                    ? colorScheme.primary
                                    : null,
                            fontSize: 15,
                            height: 1.1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (hasActivity)
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
                onSelectionChanged: (details) {
                  final date = details.date;
                  if (date == null) return;
                  if (!mounted) return;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() {
                      _selectedDate =
                          DateTime(date.year, date.month, date.day);
                    });
                  });
                },
                onViewChanged: (details) {
                  final visible = details.visibleDates;
                  if (visible.isEmpty) return;
                  final mid = visible[visible.length ~/ 2];
                  final monthAnchor = DateTime(mid.year, mid.month, 1);
                  final currentAnchor =
                      DateTime(_selectedDate.year, _selectedDate.month, 1);
                  if (monthAnchor != currentAnchor) {
                    if (!mounted) return;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() {
                        _selectedDate = monthAnchor;
                      });
                      _loadMonthData();
                    });
                  }
                },
                todayHighlightColor: colorScheme.primary,
                backgroundColor: Colors.transparent,
                cellBorderColor: colorScheme.outline.withAlpha(32),
              ),
            ),
          ),

          // 本月活动统计
          if (_monthStats.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart,
                          size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        l10n.activityMonthlyStats,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._monthStats.map((stat) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            stat.activityName.isNotEmpty
                                ? stat.activityName[0]
                                : '?',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            stat.activityName,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.activityTimes(stat.count),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

          // 选中日期的活动详情
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildSelectedDayContent(theme, colorScheme, locale),
          ),

        ],
      ),
    );
  }

  Widget _buildSelectedDayContent(
      ThemeData theme, ColorScheme colorScheme, String locale) {
    final records = _getDayRecords(_selectedDate);
    final dateFormat = DateFormat.yMd(locale);
    final isToday = _isSameDate(_selectedDate, DateTime.now());

    String title;
    if (isToday) {
      title = L10nManager.l10n.currentDay;
    } else {
      title = dateFormat.format(_selectedDate);
    }

    if (records.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: colorScheme.outline.withAlpha(128),
              ),
              const SizedBox(height: 12),
              Text(
                L10nManager.l10n.activityNoRecordsForDay,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.outline.withAlpha(128),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  L10nManager.l10n.activityItems(records.length),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...records.map((record) => _buildRecordTile(record, theme, colorScheme)),
      ],
    );
  }

  Widget _buildRecordTile(ActivityRecordVO record, ThemeData theme,
      ColorScheme colorScheme) {
    final time = DateTime.fromMillisecondsSinceEpoch(record.createdAt);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              record.activityName.isNotEmpty ? record.activityName[0] : '?',
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.activityName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (record.location != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    record.location!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            timeStr,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
