import 'package:flutter/material.dart';
import 'package:clsswjz_gui/drivers/driver_factory.dart';
import 'package:clsswjz_gui/enums/operate_type.dart';
import 'package:clsswjz_gui/events/event_bus.dart';
import 'package:clsswjz_gui/events/special/event_period.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/models/vo/period_record_vo.dart';
import 'package:clsswjz_gui/models/vo/period_statistics_vo.dart';
import '../enums/period_status.dart';
import '../enums/flow_level.dart';
import '../constants/period_constants.dart';
import '../models/common.dart';

/// 经期记录数据提供者
class PeriodRecordProvider extends ChangeNotifier {
  List<PeriodRecordVO> _records = [];
  PeriodStatisticsVO _statistics = PeriodStatisticsVO.empty;
  bool _loading = false;
  bool _operating = false;
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  List<PeriodRecordVO> get records => _records;
  PeriodStatisticsVO get statistics => _statistics;
  bool get loading => _loading;
  bool get operating => _operating;
  int get currentYear => _currentYear;
  int get currentMonth => _currentMonth;

  /// 加载指定月份的记录
  Future<void> loadRecords({int? year, int? month}) async {
    _loading = true;
    notifyListeners();

    if (year != null) _currentYear = year;
    if (month != null) _currentMonth = month;

    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.listPeriodRecords(
      userId,
      year: _currentYear,
      month: _currentMonth,
    );
    if (result.ok) {
      _records = result.data ?? [];
    }

    // 加载统计数据
    final statsResult = await DriverFactory.driver.getPeriodStatistics(userId);
    if (statsResult.ok) {
      _statistics = statsResult.data ?? PeriodStatisticsVO.empty;
    }

    _loading = false;
    notifyListeners();
  }

  /// 切换月份
  Future<void> changeMonth(int year, int month) async {
    await loadRecords(year: year, month: month);
  }

  /// 记录/更新某日经期状态
  Future<OperateResult<void>> updatePeriodDay(
    String recordDate, {
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.updatePeriodDay(
      userId,
      recordDate,
      periodStatus: periodStatus,
      flowLevel: flowLevel,
      symptoms: symptoms,
      mood: mood,
      remark: remark,
    );
    if (result.ok) {
      await loadRecords();
      EventBus.instance.emit(PeriodRecordChangedEvent(
        periodStatus == null ? OperateType.update : OperateType.create,
      ));
    }
    return result;
  }

  /// 删除某日记录
  Future<OperateResult<void>> deletePeriodDay(String recordDate) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.deletePeriodDay(userId, recordDate);
    if (result.ok) {
      await loadRecords();
      EventBus.instance.emit(PeriodRecordChangedEvent(OperateType.delete));
    }
    return result;
  }

  /// 获取指定日期的记录
  PeriodRecordVO? getRecordByDate(String recordDate) {
    try {
      return _records.firstWhere((r) => r.recordDate == recordDate);
    } catch (_) {
      return null;
    }
  }

  /// 是否正在经期中（今天或最近7天内有 period 记录）
  bool get isInPeriod {
    final now = DateTime.now();
    // 先检查当前月数据
    for (var i = 0; i < PeriodConstants.inPeriodLookbackDays; i++) {
      final d = now.subtract(Duration(days: i));
      final ds = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final r = getRecordByDate(ds);
      if (r != null && r.periodStatus == PeriodStatus.period) return true;
    }
    // 当前月数据不包含今天时（比如在看上个月），直接查数据库
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    if (getRecordByDate(todayStr) == null) {
      // 异步查询标记（下次 rebuild 时生效）
      _checkInPeriodFromDb(now);
    }
    return _cachedIsInPeriod;
  }

  bool _cachedIsInPeriod = false;

  Future<void> _checkInPeriodFromDb(DateTime now) async {
    final userId = AppConfigManager.instance.userId;
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final result = await DriverFactory.driver.listPeriodRecords(
      userId, year: now.year, month: now.month,
    );
    if (result.ok) {
      final todayRecord = (result.data ?? []).where((r) => r.recordDate == todayStr && r.periodStatus == PeriodStatus.period);
      final wasInPeriod = _cachedIsInPeriod;
      _cachedIsInPeriod = todayRecord.isNotEmpty;
      if (wasInPeriod != _cachedIsInPeriod) notifyListeners();
    }
  }

  /// 标记经期开始：仅标记当天为 period，不自动填充后续
  Future<void> startPeriod(String startDate) async {
    _operating = true;
    notifyListeners();
    final userId = AppConfigManager.instance.userId;
    await DriverFactory.driver.updatePeriodDay(
      userId, startDate,
      periodStatus: PeriodStatus.period.code,
      flowLevel: FlowLevel.medium.code,
    );
    await loadRecords();
    _operating = false;
    notifyListeners();
    EventBus.instance.emit(const PeriodRecordChangedEvent(OperateType.create));
  }

  /// 标记经期结束：从最近一次经期开始日到今天，全部填充为 period
  Future<void> endPeriod() async {
    _operating = true;
    notifyListeners();
    final userId = AppConfigManager.instance.userId;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 往前找到最近一次经期开始日
    String? startDate;
    for (var i = 0; i < PeriodConstants.endPeriodSearchMaxDays; i++) {
      final d = now.subtract(Duration(days: i));
      final ds = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final r = getRecordByDate(ds);
      if (r != null && r.periodStatus == PeriodStatus.period) {
        startDate = ds;
      } else if (startDate != null) {
        // 找到了经期开始日的前一天，停止
        break;
      }
    }

    if (startDate != null) {
      // 从开始日到今天全部填充为 period
      var current = DateTime.parse(startDate);
      while (!current.isAfter(today)) {
        final ds = '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
        await DriverFactory.driver.updatePeriodDay(
          userId, ds,
          periodStatus: PeriodStatus.period.code,
          flowLevel: FlowLevel.medium.code,
        );
        current = current.add(const Duration(days: 1));
      }
    }

    await loadRecords();
    _operating = false;
    notifyListeners();
    EventBus.instance.emit(const PeriodRecordChangedEvent(OperateType.update));
  }
}
