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

/// 为不同活动名称分配不同颜色的调色板
final List<Color> _activityPalette = [
  const Color(0xFF5C6BC0), // indigo
  const Color(0xFF26A69A), // teal
  const Color(0xFFFF7043), // deep orange
  const Color(0xFFAB47BC), // purple
  const Color(0xFF42A5F5), // blue
  const Color(0xFF66BB6A), // green
  const Color(0xFFEC407A), // pink
  const Color(0xFFFFA726), // orange
  const Color(0xFF26C6DA), // cyan
  const Color(0xFF8D6E63), // brown
  const Color(0xFF78909C), // blue grey
  const Color(0xFFEF5350), // red
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

class ActivityCalendarViewState extends State<ActivityCalendarView>
    with SingleTickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  List<ActivityRecordVO> _monthRecords = [];
  List<ActivityStatisticVO> _monthStats = [];
  bool _loading = false;
  bool _showFloatingPanel = false;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  StreamSubscription? _activityChangedSubscription;

  String? get _bookId => AppConfigManager.instance.defaultBookId;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _loadMonthData();
    _activityChangedSubscription =
        EventBus.instance.on<ActivityChangedEvent>((event) {
      _loadMonthData();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
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

  void _handleDateSelected(DateTime date) {
    final sameDate = _isSameDate(date, _selectedDate);

    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      if (sameDate) {
        // 再次点击同一日期：切换面板显示
        _showFloatingPanel
            ? _animController.reverse()
            : _animController.forward();
        _showFloatingPanel = !_showFloatingPanel;
      } else {
        // 点击不同日期：显示面板
        _showFloatingPanel = true;
        _animController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading && _monthRecords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final locale = Localizations.localeOf(context).toString();
    final dayRecords = _getDayRecords(_selectedDate);

    return Stack(
      children: [
        // 主内容：日历 + 统计
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              // 日历卡片
              _buildCalendarCard(theme, colorScheme),
              // 本月活动统计
              if (_monthStats.isNotEmpty)
                _buildStatsCard(theme, colorScheme),
              // 底部占位，给悬浮面板留空间
              if (_showFloatingPanel)
                SizedBox(height: MediaQuery.of(context).size.height * 0.35),
            ],
          ),
        ),

        // 悬浮面板
        if (_showFloatingPanel)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildFloatingPanel(theme, colorScheme, locale, dayRecords),
            ),
          ),
      ],
    );
  }

  Widget _buildCalendarCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
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
              _handleDateSelected(date);
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
                  _showFloatingPanel = false;
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
    );
  }

  Widget _buildStatsCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
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
              Icon(Icons.bar_chart, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                L10nManager.l10n.activityMonthlyStats,
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
                  backgroundColor: _colorForActivity(stat.activityName),
                  child: Text(
                    stat.activityName.isNotEmpty
                        ? stat.activityName[0]
                        : '?',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
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
                    L10nManager.l10n.activityTimes(stat.count),
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
    );
  }

  Widget _buildFloatingPanel(ThemeData theme, ColorScheme colorScheme,
      String locale, List<ActivityRecordVO> records) {
    final dateFormat = DateFormat.yMd(locale);
    final isToday = _isSameDate(_selectedDate, DateTime.now());

    String title;
    if (isToday) {
      title = L10nManager.l10n.currentDay;
    } else {
      title = dateFormat.format(_selectedDate);
    }

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
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
                  if (records.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
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
                ],
              ),
            ),
            // 内容
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('暂无活动'),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: records
                      .map((record) => _buildRecordTile(record, theme, colorScheme))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTile(ActivityRecordVO record, ThemeData theme,
      ColorScheme colorScheme) {
    final activityColor = _colorForActivity(record.activityName);
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
}
