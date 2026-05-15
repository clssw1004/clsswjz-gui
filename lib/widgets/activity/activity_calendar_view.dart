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

/// 为不同活动名称分配不同颜色的调色板
final List<Color> _activityPalette = [
  const Color(0xFF5C6BC0),
  const Color(0xFF26A69A),
  const Color(0xFFFF7043),
  const Color(0xFFAB47BC),
  const Color(0xFF42A5F5),
  const Color(0xFF66BB6A),
  const Color(0xFFEC407A),
  const Color(0xFFFFA726),
  const Color(0xFF26C6DA),
  const Color(0xFF8D6E63),
  const Color(0xFF78909C),
  const Color(0xFFEF5350),
];

Color _colorForActivity(String name) {
  final index = name.hashCode.abs() % _activityPalette.length;
  return _activityPalette[index];
}

class ActivityCalendarView extends StatefulWidget {
  const ActivityCalendarView({super.key});

  @override
  State<ActivityCalendarView> createState() => ActivityCalendarViewState();
}

class ActivityCalendarViewState extends State<ActivityCalendarView> {
  DateTime _selectedDate = DateTime.now();
  List<ActivityRecordVO> _monthRecords = [];
  bool _loading = false;
  bool _hasInteracted = false;
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

      if (!mounted) return;
      setState(() {
        if (recordsResult.ok) _monthRecords = recordsResult.data ?? [];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> refreshData() async {
    await _loadMonthData();
  }

  bool _hasActivity(DateTime day) {
    final key = _formatDate(day);
    return _monthRecords.any((r) => r.recordDate == key);
  }

  List<ActivityRecordVO> _getDayRecords(DateTime day) {
    final key = _formatDate(day);
    return _monthRecords.where((r) => r.recordDate == key).toList();
  }

  void _showDayDetails(DateTime date) {
    final records = _getDayRecords(date);
    final l10n = L10nManager.l10n;
    final locale = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat.yMd(locale);
    final isToday = _isSameDate(date, DateTime.now());

    String title;
    if (isToday) {
      title = l10n.currentDay;
    } else {
      title = dateFormat.format(date);
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (records.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.activityItems(records.length),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const Divider(height: 24),

                // 内容
                if (records.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.activityNoRecordsForDay,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline.withAlpha(128),
                        ),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: records
                          .map((record) => _buildRecordTile(context, record))
                          .toList(),
                    ),
                  ),

                // 关闭按钮
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('关闭'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordTile(BuildContext context, ActivityRecordVO record) {
    final activityColor = _colorForActivity(record.activityName);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final time = DateTime.fromMillisecondsSinceEpoch(record.createdAt);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: activityColor,
            child: Text(
              record.activityName.isNotEmpty ? record.activityName[0] : '?',
              style: const TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading && _monthRecords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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
                    if (_hasInteracted) {
                      _showDayDetails(_selectedDate);
                    } else {
                      _hasInteracted = true;
                    }
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

        ],
      ),
    );
  }
}
