import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../drivers/driver_factory.dart';
import '../../events/event_bus.dart';
import '../../events/special/event_book.dart';
import '../../manager/app_config_manager.dart';
import '../../models/vo/activity_record_vo.dart';

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

class ActivityListView extends StatefulWidget {
  const ActivityListView({super.key});

  @override
  State<ActivityListView> createState() => ActivityListViewState();
}

class ActivityListViewState extends State<ActivityListView> {
  List<ActivityRecordVO> _records = [];
  bool _loading = false;
  StreamSubscription? _activityChangedSubscription;

  String? get _bookId => AppConfigManager.instance.defaultBookId;

  @override
  void initState() {
    super.initState();
    _loadRecords();
    _activityChangedSubscription =
        EventBus.instance.on<ActivityChangedEvent>((event) {
      _loadRecords();
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

  Future<void> _loadRecords() async {
    if (_loading || _bookId == null) return;
    _loading = true;
    try {
      final result = await DriverFactory.driver.listActivityRecordsByBook(
        AppConfigManager.instance.userId,
        _bookId!,
        limit: 200,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        if (result.ok) _records = result.data ?? [];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_loading && _records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_outlined, size: 64,
                color: colorScheme.outline.withAlpha(100)),
            const SizedBox(height: 16),
            Text('暂无活动记录',
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    // 按日期分组
    final grouped = <String, List<ActivityRecordVO>>{};
    for (final record in _records) {
      grouped.putIfAbsent(record.recordDate, () => []).add(record);
    }
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final records = grouped[date]!;
        final dateObj = DateTime.parse(date);
        final isToday = _isSameDate(dateObj, DateTime.now());
        final dateFormat = DateFormat.yMd(Localizations.localeOf(context).toString());

        String label;
        if (isToday) {
          label = '今天';
        } else {
          label = dateFormat.format(dateObj);
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期标题行
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isToday
                              ? [colorScheme.primary, colorScheme.primary.withAlpha(200)]
                              : [colorScheme.surfaceContainerHighest, colorScheme.surfaceContainerHighest],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(label,
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: isToday ? colorScheme.onPrimary : colorScheme.onSurface,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${records.length}',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              // 当天活动卡片
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: records.asMap().entries.map((entry) {
                    final i = entry.key;
                    final record = entry.value;
                    final isLast = i == records.length - 1;
                    return _buildRecordTile(record, theme, colorScheme, isLast);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordTile(ActivityRecordVO record, ThemeData theme,
      ColorScheme colorScheme, bool isLast) {
    final activityColor = _colorForActivity(record.activityName);
    final time = DateTime.fromMillisecondsSinceEpoch(record.createdAt);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, isLast ? 12 : 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 彩色圆点
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: activityColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: activityColor.withAlpha(80),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // 活动名称 + 地点
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.activityName,
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600)),
                    if (record.location != null) ...[
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 12, color: colorScheme.onSurfaceVariant.withAlpha(150)),
                          const SizedBox(width: 2),
                          Text(record.location!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant.withAlpha(180))),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // 时间
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(120),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 12,
                        color: colorScheme.onSurfaceVariant.withAlpha(150)),
                    const SizedBox(width: 3),
                    Text(timeStr,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 分隔线（除最后一条外）
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 38),
            child: Divider(height: 1, color: colorScheme.outline.withAlpha(25)),
          ),
      ],
    );
  }
}
