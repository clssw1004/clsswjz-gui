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
    await Future.wait([loadDefinitions(), loadTodayCounts(), loadRecentRecords()]);
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

  /// 打卡 +1
  Future<bool> checkIn(String defId, {String? location}) async {
    if (_currentBookId == null) return false;
    final def = _definitions.where((d) => d.id == defId).firstOrNull;
    if (def == null) return false;
    final today = DateUtil.nowDate();
    final result = await DriverFactory.driver.createActivityRecord(
      AppConfigManager.instance.userId,
      _currentBookId!,
      activityName: def.name,
      recordDate: today,
      activityDefId: defId,
      location: location,
    );
    if (result.ok) {
      _todayCounts[defId] = (_todayCounts[defId] ?? 0) + 1;
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
