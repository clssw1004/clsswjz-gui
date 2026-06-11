import 'dart:async';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../enums/operate_type.dart';
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
  late final StreamSubscription _syncSubscription;
  late final StreamSubscription _defChangedSubscription;

  /// 所有活动定义
  List<ActivityDefinitionVO> _definitions = [];
  List<ActivityDefinitionVO> get definitions => _definitions;

  /// 今日打卡次数 (defId → count, 包含共享)
  Map<String, int> _todayCounts = {};
  Map<String, int> get todayCounts => _todayCounts;

  /// 我今日打卡次数 (defId → count, 仅我自己)
  Map<String, int> _myTodayCounts = {};
  Map<String, int> get myTodayCounts => _myTodayCounts;

  /// 累计打卡次数 (defId → count, 包含共享)
  Map<String, int> _totalCounts = {};
  Map<String, int> get totalCounts => _totalCounts;

  /// 累计打卡总次数
  int get totalAll => _totalCounts.values.fold(0, (sum, v) => sum + v);

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
      loadTotalCounts(),
    ]);
  }

  /// 加载所有活动定义
  Future<void> loadDefinitions() async {
    final result = await DriverFactory.driver.listActivityDefinitions(
      AppConfigManager.instance.userId,
    );
    if (result.ok) {
      _definitions = result.data ?? [];
      notifyListeners();
    }
  }

  /// 加载今日打卡计数
  Future<void> loadTodayCounts() async {
    final today = DateUtil.nowDate();
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.listActivityRecords(
      userId,
      startDate: today,
      endDate: today,
    );
    if (result.ok) {
      final counts = <String, int>{};
      final myCounts = <String, int>{};
      for (final record in result.data ?? []) {
        final defId = record.activityDefId;
        if (defId != null) {
          counts[defId] = (counts[defId] ?? 0) + 1;
          if (record.createdBy == userId) {
            myCounts[defId] = (myCounts[defId] ?? 0) + 1;
          }
        }
      }
      _todayCounts = counts;
      _myTodayCounts = myCounts;
      notifyListeners();
    }
  }

  /// 加载本周打卡记录
  Future<void> loadWeekCounts() async {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    final result = await DriverFactory.driver.listActivityRecords(
      AppConfigManager.instance.userId,
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
    final result = await DriverFactory.driver.listActivityRecords(
      AppConfigManager.instance.userId,
      limit: limit,
      offset: 0,
    );
    if (result.ok) {
      _recentRecords = result.data ?? [];
      notifyListeners();
    }
  }

  /// 加载累计打卡次数
  Future<void> loadTotalCounts() async {
    final result = await DriverFactory.driver.listActivityRecords(
      AppConfigManager.instance.userId,
      limit: 99999,
      offset: 0,
    );
    if (result.ok) {
      final counts = <String, int>{};
      for (final record in result.data ?? []) {
        final defId = record.activityDefId;
        if (defId != null) {
          counts[defId] = (counts[defId] ?? 0) + 1;
        }
      }
      _totalCounts = counts;
      notifyListeners();
    }
  }

  /// 加载指定活动的打卡记录
  List<ActivityRecordVO> _recordsByDefId = [];
  List<ActivityRecordVO> get recordsByDefId => _recordsByDefId;
  int _todayCountByDefId = 0;
  int get todayCountByDefId => _todayCountByDefId;

  Future<void> loadRecordsByDefId(String defId, {int limit = 50}) async {
    final today = DateUtil.nowDate();
    final result = await DriverFactory.driver.listActivityRecords(
      AppConfigManager.instance.userId,
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
  Future<bool> checkIn(String defId, {String? location, String? remark}) async {
    final def = _definitions.where((d) => d.id == defId).firstOrNull;
    if (def == null) return false;

    // 检查每日上限（按用户独立）
    if (def.maxDailyCount != null) {
      final myTodayCount = _myTodayCounts[defId] ?? 0;
      if (myTodayCount >= def.maxDailyCount!) {
        return false;
      }
    }

    final today = DateUtil.nowDate();
    final bookId = AppConfigManager.instance.defaultBookId!;
    final result = await DriverFactory.driver.createActivityRecord(
      AppConfigManager.instance.userId,
      bookId,
      activityName: def.name,
      recordDate: today,
      activityDefId: defId,
      location: location,
      maxDailyCount: def.maxDailyCount,
      remark: remark,
    );
    if (result.ok) {
      _todayCounts[defId] = (_todayCounts[defId] ?? 0) + 1;
      _myTodayCounts[defId] = (_myTodayCounts[defId] ?? 0) + 1;
      _totalCounts[defId] = (_totalCounts[defId] ?? 0) + 1;
      notifyListeners();
      final now = DateTime.now().millisecondsSinceEpoch;
      EventBus.instance.emit(ActivityChangedEvent(
        OperateType.create,
        ActivityRecordVO(
          id: result.data!,
          accountBookId: bookId,
          activityName: def.name,
          location: location,
          remark: remark,
          activityDefId: defId,
          maxDailyCount: def.maxDailyCount,
          recordDate: today,
          createdAt: now,
          updatedAt: now,
          createdBy: AppConfigManager.instance.userId,
          updatedBy: AppConfigManager.instance.userId,
        ),
      ));
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
      if (idx == -1) return result.ok;
      final now = DateTime.now().millisecondsSinceEpoch;
      final updated = ActivityRecordVO(
        id: _recordsByDefId[idx].id,
        accountBookId: _recordsByDefId[idx].accountBookId,
        activityName: _recordsByDefId[idx].activityName,
        location: _recordsByDefId[idx].location,
        remark: _recordsByDefId[idx].remark,
        activityDefId: _recordsByDefId[idx].activityDefId,
        maxDailyCount: _recordsByDefId[idx].maxDailyCount,
        recordDate: _recordsByDefId[idx].recordDate,
        createdAt: createdAt,
        updatedAt: now,
        createdBy: _recordsByDefId[idx].createdBy,
        updatedBy: _recordsByDefId[idx].updatedBy,
      );
      _recordsByDefId[idx] = updated;
      notifyListeners();
      EventBus.instance.emit(ActivityChangedEvent(OperateType.update, updated));
    }
    return result.ok;
  }

  /// 删除打卡记录
  Future<bool> deleteRecord(String recordId) async {
    final deleted = _recordsByDefId.where((r) => r.id == recordId).firstOrNull;
    final userId = AppConfigManager.instance.userId;
    final bookId = AppConfigManager.instance.defaultBookId!;
    final result = await DriverFactory.driver.deleteActivityRecord(
      AppConfigManager.instance.userId,
      bookId,
      recordId,
    );
    if (result.ok) {
      _recordsByDefId.removeWhere((r) => r.id == recordId);
      final today = DateUtil.nowDate();
      _todayCountByDefId = _recordsByDefId.where((r) => r.recordDate == today).length;
      // 同步更新今日计数缓存，否则 checkIn 仍按旧值拦截
      if (deleted != null && deleted.activityDefId != null) {
        final defId = deleted.activityDefId!;
        // 更新今日计数
        final c = _todayCounts[defId] ?? 0;
        if (c > 0) _todayCounts[defId] = c - 1;
        // 更新我今日计数
        if (deleted.createdBy == userId) {
          final mc = _myTodayCounts[defId] ?? 0;
          if (mc > 0) _myTodayCounts[defId] = mc - 1;
        }
        // 更新累计计数
        final tc = _totalCounts[defId] ?? 0;
        if (tc > 0) _totalCounts[defId] = tc - 1;
      }
      notifyListeners();
      if (deleted != null) {
        EventBus.instance.emit(ActivityChangedEvent(OperateType.delete, deleted));
      }
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
    final bookId = AppConfigManager.instance.defaultBookId!;
    final result = await DriverFactory.driver.createActivityDefinition(
      AppConfigManager.instance.userId,
      bookId,
      name: name,
      emoji: emoji,
      color: color,
      sortOrder: sortOrder,
      maxDailyCount: maxDailyCount,
    );
    if (result.ok) {
      await loadDefinitions();
      await loadTodayCounts();
      EventBus.instance.emit(ActivityDefinitionChangedEvent(
        OperateType.create,
        ActivityDefinitionVO(
          id: result.data!,
          accountBookId: bookId,
          name: name,
          emoji: emoji,
          color: color,
          sortOrder: sortOrder,
          maxDailyCount: maxDailyCount,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      ));
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
      EventBus.instance.emit(ActivityDefinitionChangedEvent(OperateType.update, vo));
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
      _myTodayCounts.remove(id);
      _totalCounts.remove(id);
      notifyListeners();
      EventBus.instance.emit(ActivityDefinitionChangedEvent(
        OperateType.delete,
        ActivityDefinitionVO(
          id: id,
          accountBookId: '',
          name: '',
          emoji: '',
          color: 0,
          sortOrder: 0,
          createdAt: 0,
          updatedAt: 0,
        ),
      ));
    }
    return result.ok;
  }

  /// 获取指定定义今日打卡总次数（含共享）
  int todayCountOf(String defId) => _todayCounts[defId] ?? 0;

  /// 获取指定定义我今日打卡次数（用于上限检测）
  int myTodayCountOf(String defId) => _myTodayCounts[defId] ?? 0;

  /// 获取指定定义累计打卡次数
  int totalCountOf(String defId) => _totalCounts[defId] ?? 0;
}
