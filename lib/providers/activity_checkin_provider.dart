import 'dart:async';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../events/event_bus.dart';
import '../events/special/event_book.dart';
import '../events/special/event_sync.dart';
import '../events/special/event_activity_checkin.dart';
import '../manager/app_config_manager.dart';
import '../models/common.dart';
import '../models/vo/activity_definition_vo.dart';
import '../models/vo/activity_record_vo.dart';
import '../utils/date_util.dart';

class ActivityCheckinProvider extends ChangeNotifier {
  late final StreamSubscription _bookSubscription;
  late final StreamSubscription _syncSubscription;
  late final StreamSubscription _defChangedSubscription;

  String? _currentBookId;

  /// 所有活动定义
  List<ActivityDefinitionVO> _definitions = [];
  List<ActivityDefinitionVO> get definitions => _definitions;

  /// 今日打卡次数 (defId → count)
  Map<String, int> _todayCounts = {};
  Map<String, int> get todayCounts => _todayCounts;

  /// 今日打卡总次数
  int get todayTotal =>
      _todayCounts.values.fold(0, (sum, v) => sum + v);

  /// 今日活跃活动数
  int get todayDistinctCount => _todayCounts.length;

  /// 本周累计打卡次数
  int _weekTotal = 0;
  int get weekTotal => _weekTotal;

  /// 最近打卡记录
  List<ActivityRecordVO> _recentRecords = [];
  List<ActivityRecordVO> get recentRecords => _recentRecords;

  bool loading = false;

  ActivityCheckinProvider() {
    _currentBookId = AppConfigManager.instance.defaultBookId;

    _bookSubscription = EventBus.instance.on<BookChangedEvent>((event) {
      _currentBookId = event.book.id;
      loadAll();
    });

    _syncSubscription = EventBus.instance.on<SyncCompletedEvent>((event) {
      loadAll();
    });

    _defChangedSubscription =
        EventBus.instance.on<ActivityDefinitionChangedEvent>((event) {
      loadDefinitions();
      loadTodayCounts();
    });
  }

  @override
  void dispose() {
    _bookSubscription.cancel();
    _syncSubscription.cancel();
    _defChangedSubscription.cancel();
    super.dispose();
  }

  /// 全量加载
  Future<void> loadAll() async {
    await Future.wait([
      loadDefinitions(),
      loadTodayCounts(),
      loadWeekCounts(),
      loadRecentRecords(),
    ]);
  }

  /// 加载所有活动定义
  Future<void> loadDefinitions() async {
    if (_currentBookId == null) return;
    final result = await DriverFactory.driver.listActivityDefinitions(
      AppConfigManager.instance.userId,
      _currentBookId!,
    );
    if (result.ok) {
      _definitions = result.data ?? [];
      notifyListeners();
    }
  }

  /// 加载今日打卡计数
  Future<void> loadTodayCounts() async {
    if (_currentBookId == null) return;
    final today = DateUtil.nowDate();
    final result = await DriverFactory.driver.listActivityRecordsByBook(
      AppConfigManager.instance.userId,
      _currentBookId!,
      startDate: today,
      endDate: today,
    );
    if (result.ok) {
      final counts = <String, int>{};
      for (final record in result.data ?? []) {
        final defId = record.activityDefId;
        if (defId != null) {
          counts[defId] = (counts[defId] ?? 0) + 1;
        }
      }
      _todayCounts = counts;
      notifyListeners();
    }
  }

  /// 加载本周打卡记录
  Future<void> loadWeekCounts() async {
    if (_currentBookId == null) return;
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final result = await DriverFactory.driver.listActivityRecordsByBook(
      AppConfigManager.instance.userId,
      _currentBookId!,
      startDate: DateUtil.formatDate(monday),
      endDate: DateUtil.formatDate(sunday),
    );
    if (result.ok) {
      _weekTotal = result.data?.length ?? 0;
      notifyListeners();
    }
  }

  /// 加载最近打卡记录
  Future<void> loadRecentRecords({int limit = 5}) async {
    if (_currentBookId == null) return;
    final result = await DriverFactory.driver.listActivityRecordsByBook(
      AppConfigManager.instance.userId,
      _currentBookId!,
      limit: limit,
      offset: 0,
    );
    if (result.ok) {
      _recentRecords = result.data ?? [];
      notifyListeners();
    }
  }

  /// 加载指定活动的打卡记录
  List<ActivityRecordVO> _recordsByDefId = [];
  List<ActivityRecordVO> get recordsByDefId => _recordsByDefId;
  int _todayCountByDefId = 0;
  int get todayCountByDefId => _todayCountByDefId;

  Future<void> loadRecordsByDefId(String defId, {int limit = 50}) async {
    if (_currentBookId == null) return;
    final today = DateUtil.nowDate();
    final result = await DriverFactory.driver.listActivityRecordsByBook(
      AppConfigManager.instance.userId,
      _currentBookId!,
      activityDefId: defId,
      limit: limit,
      offset: 0,
    );
    if (result.ok) {
      _recordsByDefId = result.data ?? [];
      _todayCountByDefId = _recordsByDefId.where((r) => r.recordDate == today).length;
      notifyListeners();
    }
  }

  /// 打卡 +1
  Future<bool> checkIn(String defId, {String? location}) async {
    if (_currentBookId == null) return false;
    final def = _definitions.where((d) => d.id == defId).firstOrNull;
    if (def == null) return false;

    // 检查每日上限
    if (def.maxDailyCount != null) {
      final todayCount = _todayCounts[defId] ?? 0;
      if (todayCount >= def.maxDailyCount!) {
        return false;
      }
    }

    final today = DateUtil.nowDate();
    final result = await DriverFactory.driver.createActivityRecord(
      AppConfigManager.instance.userId,
      _currentBookId!,
      activityName: def.name,
      recordDate: today,
      activityDefId: defId,
      location: location,
      maxDailyCount: def.maxDailyCount,
    );
    if (result.ok) {
      _todayCounts[defId] = (_todayCounts[defId] ?? 0) + 1;
      notifyListeners();
    }
    return result.ok;
  }

  /// 更新记录时间
  Future<bool> updateRecordTime(String recordId, {required int createdAt}) async {
    final result = await DriverFactory.driver.updateActivityRecordTime(
      AppConfigManager.instance.userId,
      recordId,
      createdAt: createdAt,
    );
    if (result.ok) {
      final idx = _recordsByDefId.indexWhere((r) => r.id == recordId);
      if (idx != -1) {
        _recordsByDefId[idx] = ActivityRecordVO(
          id: _recordsByDefId[idx].id,
          accountBookId: _recordsByDefId[idx].accountBookId,
          activityName: _recordsByDefId[idx].activityName,
          location: _recordsByDefId[idx].location,
          activityDefId: _recordsByDefId[idx].activityDefId,
          maxDailyCount: _recordsByDefId[idx].maxDailyCount,
          recordDate: _recordsByDefId[idx].recordDate,
          createdAt: createdAt,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          createdBy: _recordsByDefId[idx].createdBy,
          updatedBy: _recordsByDefId[idx].updatedBy,
        );
        notifyListeners();
      }
    }
    return result.ok;
  }

  /// 删除打卡记录
  Future<bool> deleteRecord(String recordId) async {
    if (_currentBookId == null) return false;
    final deleted = _recordsByDefId.where((r) => r.id == recordId).firstOrNull;
    final result = await DriverFactory.driver.deleteActivityRecord(
      AppConfigManager.instance.userId,
      _currentBookId!,
      recordId,
    );
    if (result.ok) {
      _recordsByDefId.removeWhere((r) => r.id == recordId);
      final today = DateUtil.nowDate();
      _todayCountByDefId = _recordsByDefId.where((r) => r.recordDate == today).length;
      // 同步更新今日计数缓存，否则 checkIn 仍按旧值拦截
      if (deleted != null && deleted.recordDate == today && deleted.activityDefId != null) {
        final c = _todayCounts[deleted.activityDefId] ?? 0;
        if (c > 0) _todayCounts[deleted.activityDefId!] = c - 1;
      }
      notifyListeners();
    }
    return result.ok;
  }

  /// 创建活动定义
  Future<OperateResult<String>> createDefinition({
    required String name,
    required String emoji,
    required int color,
    int sortOrder = 0,
    int? maxDailyCount,
  }) async {
    if (_currentBookId == null) {
      return OperateResult.failWithMessage(message: '请先选择账本');
    }
    final result = await DriverFactory.driver.createActivityDefinition(
      AppConfigManager.instance.userId,
      _currentBookId!,
      name: name,
      emoji: emoji,
      color: color,
      sortOrder: sortOrder,
      maxDailyCount: maxDailyCount,
    );
    if (result.ok) {
      await loadDefinitions();
      await loadTodayCounts();
    }
    return result;
  }

  /// 更新活动定义
  Future<bool> updateDefinition(ActivityDefinitionVO vo) async {
    final result = await DriverFactory.driver.updateActivityDefinition(
      AppConfigManager.instance.userId,
      vo.id,
      name: vo.name,
      emoji: vo.emoji,
      color: vo.color,
      sortOrder: vo.sortOrder,
      maxDailyCount: vo.maxDailyCount,
    );
    if (result.ok) {
      await loadDefinitions();
    }
    return result.ok;
  }

  /// 删除活动定义
  Future<bool> deleteDefinition(String id) async {
    final result = await DriverFactory.driver.deleteActivityDefinition(
      AppConfigManager.instance.userId,
      id,
    );
    if (result.ok) {
      _definitions.removeWhere((d) => d.id == id);
      _todayCounts.remove(id);
      notifyListeners();
    }
    return result.ok;
  }

  /// 获取今日指定定义的打卡次数
  int todayCountOf(String defId) => _todayCounts[defId] ?? 0;
}
