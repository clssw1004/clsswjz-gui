import 'dart:async';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../events/event_bus.dart';
import '../events/special/event_book.dart';
import '../events/special/event_sync.dart';
import '../manager/app_config_manager.dart';
import '../models/common.dart';
import '../models/vo/activity_record_vo.dart';
import '../models/vo/activity_statistic_vo.dart';
import '../enums/operate_type.dart';

class ActivityProvider extends ChangeNotifier {
  late final StreamSubscription _bookSubscription;
  late final StreamSubscription _syncSubscription;
  late final StreamSubscription _activityChangedSubscription;

  /// 活动记录列表
  final List<ActivityRecordVO> _records = [];
  List<ActivityRecordVO> get records => _records;

  /// 是否加载中
  bool _loading = false;
  bool get loading => _loading;

  /// 统计结果
  List<ActivityStatisticVO> _statistics = [];
  List<ActivityStatisticVO> get statistics => _statistics;

  bool _statisticsLoading = false;
  bool get statisticsLoading => _statisticsLoading;

  /// 统计模式: week / month
  String _statMode = 'week';
  String get statMode => _statMode;

  /// 当前统计的偏移（0=本周/月，-1=上周/上月）
  int _statOffset = 0;
  int get statOffset => _statOffset;

  /// 自动补全的活动名称列表
  List<String> _activityNames = [];
  List<String> get activityNames => _activityNames;

  /// 活动每日打卡上限缓存 (activityName -> maxDailyCount)
  final Map<String, int> _dailyLimits = {};

  String? _currentBookId;

  ActivityProvider() {
    _currentBookId = AppConfigManager.instance.defaultBookId;

    _bookSubscription = EventBus.instance.on<BookChangedEvent>((event) {
      _currentBookId = event.book.id;
      loadRecords();
      loadActivityNames();
    });

    _syncSubscription = EventBus.instance.on<SyncCompletedEvent>((event) {
      loadRecords();
      loadActivityNames();
    });

    _activityChangedSubscription = EventBus.instance.on<ActivityChangedEvent>((event) {
      loadRecords();
    });
  }

  @override
  void dispose() {
    _bookSubscription.cancel();
    _syncSubscription.cancel();
    _activityChangedSubscription.cancel();
    super.dispose();
  }

  /// 计算周一起始/周日结束日期
  static ({String start, String end}) _getWeekRange(int offset) {
    final now = DateTime.now();
    // 计算当前周周一
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final targetMonday = monday.add(Duration(days: 7 * offset));
    final targetSunday = targetMonday.add(const Duration(days: 6));
    return (
      start: '${targetMonday.year}-${targetMonday.month.toString().padLeft(2, '0')}-${targetMonday.day.toString().padLeft(2, '0')}',
      end: '${targetSunday.year}-${targetSunday.month.toString().padLeft(2, '0')}-${targetSunday.day.toString().padLeft(2, '0')}',
    );
  }

  /// 计算月起始/月末日期
  static ({String start, String end}) _getMonthRange(int offset) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month + offset, 1);
    final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
    return (
      start: '${targetMonth.year}-${targetMonth.month.toString().padLeft(2, '0')}-01',
      end: '${targetMonth.year}-${targetMonth.month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}',
    );
  }

  /// 获取当前统计的日期范围标签
  String getStatDateLabel() {
    final range = _statMode == 'week' ? _getWeekRange(_statOffset) : _getMonthRange(_statOffset);
    return '${range.start} ~ ${range.end}';
  }

  /// 设置统计模式
  void setStatMode(String mode) {
    if (_statMode != mode) {
      _statMode = mode;
      _statOffset = 0;
      loadStatistics();
    }
  }

  /// 切换统计偏移（上一周/月或下一周/月）
  void setStatOffset(int offset) {
    _statOffset = offset;
    loadStatistics();
  }

  /// 加载活动记录
  Future<void> loadRecords() async {
    if (_loading || _currentBookId == null) return;
    _loading = true;
    try {
      final result = await DriverFactory.driver.listActivityRecordsByBook(
        AppConfigManager.instance.userId,
        _currentBookId!,
        limit: 200,
        offset: 0,
      );
      if (result.ok) {
        _records.clear();
        _records.addAll(result.data ?? []);
        // 刷新每日上限缓存
        _dailyLimits.clear();
        for (final r in _records) {
          if (r.maxDailyCount != null && !_dailyLimits.containsKey(r.activityName)) {
            _dailyLimits[r.activityName] = r.maxDailyCount!;
          }
        }
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 加载统计
  Future<void> loadStatistics() async {
    if (_currentBookId == null) return;
    _statisticsLoading = true;
    notifyListeners();
    try {
      final range = _statMode == 'week' ? _getWeekRange(_statOffset) : _getMonthRange(_statOffset);
      final result = await DriverFactory.driver.getActivityStatistics(
        AppConfigManager.instance.userId,
        _currentBookId!,
        startDate: range.start,
        endDate: range.end,
      );
      if (result.ok) {
        _statistics = result.data ?? [];
      }
    } finally {
      _statisticsLoading = false;
      notifyListeners();
    }
  }

  /// 加载活动名称列表（用于自动补全）
  Future<void> loadActivityNames() async {
    if (_currentBookId == null) return;
    final result = await DriverFactory.driver.listDistinctActivityNames(
      AppConfigManager.instance.userId,
      _currentBookId!,
    );
    if (result.ok) {
      _activityNames = result.data ?? [];
      notifyListeners();
    }
  }

  /// 创建活动记录
  Future<OperateResult<String>> createRecord({
    required String activityName,
    required String recordDate,
    String? location,
    int? createdAt,
    int? maxDailyCount,
  }) async {
    if (_currentBookId == null) {
      return OperateResult.failWithMessage(message: '请先选择账本');
    }

    // 校验每日上限
    final limit = maxDailyCount ?? _dailyLimits[activityName];
    if (limit != null) {
      final todayCount = _records.where((r) =>
          r.activityName == activityName && r.recordDate == recordDate).length;
      if (todayCount >= limit) {
        return OperateResult.failWithMessage(
          message: '已达每日打卡上限 ($limit 次)',
        );
      }
    }

    final result = await DriverFactory.driver.createActivityRecord(
      AppConfigManager.instance.userId,
      _currentBookId!,
      activityName: activityName,
      recordDate: recordDate,
      location: location,
      createdAt: createdAt,
      maxDailyCount: maxDailyCount,
    );
    if (result.ok) {
      if (maxDailyCount != null) {
        _dailyLimits[activityName] = maxDailyCount;
      }
      await loadRecords();
      await loadActivityNames();
      final vo = ActivityRecordVO(
        id: result.data!,
        accountBookId: _currentBookId!,
        activityName: activityName,
        location: location,
        maxDailyCount: maxDailyCount,
        recordDate: recordDate,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        createdBy: AppConfigManager.instance.userId,
        updatedBy: AppConfigManager.instance.userId,
      );
      EventBus.instance.emit(ActivityChangedEvent(OperateType.create, vo));
    }
    return result;
  }

  /// 检查某活动某日是否已达打卡上限
  Future<bool> isDailyLimitReached(String activityName, String date) async {
    final limit = _dailyLimits[activityName];
    if (limit == null) return false;
    final todayCount = _records
        .where((r) => r.activityName == activityName && r.recordDate == date)
        .length;
    return todayCount >= limit;
  }

  /// 获取某活动的每日上限
  int? getActivityDailyLimit(String activityName) {
    return _dailyLimits[activityName];
  }

  /// 删除活动记录
  Future<bool> deleteRecord(ActivityRecordVO record) async {
    if (_currentBookId == null) return false;
    final result = await DriverFactory.driver.deleteActivityRecord(
      AppConfigManager.instance.userId,
      _currentBookId!,
      record.id,
    );
    if (result.ok) {
      _records.remove(record);
      notifyListeners();
      EventBus.instance.emit(ActivityChangedEvent(OperateType.delete, record));
    }
    return result.ok;
  }
}
