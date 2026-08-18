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
import '../utils/period_calc_util.dart';

/// 经期记录数据提供者
class PeriodRecordProvider extends ChangeNotifier {
  List<PeriodRecordVO> _records = [];
  /// 近 60 天所有记录（含跨月），用于 isInPeriod / endPeriod / 计算天数
  List<PeriodRecordVO> _recentRecords = [];
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

  /// 当前所处周期阶段
  PeriodPhase get currentPhase => PeriodCalcUtil.determinePhase(
        isInPeriod: isInPeriod,
        statistics: _statistics,
      );

  /// 当前是经期第几天（仅经期中有效）
  int? get currentPeriodDay => PeriodCalcUtil.calcCurrentPeriodDay(
        isInPeriod: isInPeriod,
        records: _recentRecords,
      );

  /// 距下次经期天数
  int? get daysUntilNextPeriod => PeriodCalcUtil.calcDaysUntilNextPeriod(
        statistics: _statistics,
      );

  /// 本次经期开始日期
  String? get periodStartDate => PeriodCalcUtil.calcPeriodStartDate(
        isInPeriod: isInPeriod,
        records: _recentRecords,
      );

  /// 是否在排卵期（易孕窗口内）
  bool get isInFertileWindow => PeriodCalcUtil.isInFertileWindow(
        statistics: _statistics,
      );

  /// 是否在安全期
  bool get isInSafePeriod => PeriodCalcUtil.isInSafePeriod(
        isInPeriod: isInPeriod,
        statistics: _statistics,
      );

  /// 加载指定月份的记录 + 近 60 天记录
  Future<void> loadRecords({int? year, int? month}) async {
    _loading = true;
    notifyListeners();

    if (year != null) _currentYear = year;
    if (month != null) _currentMonth = month;

    final userId = AppConfigManager.instance.userId;

    // 并行加载当月记录 + 近 60 天记录
    final results = await Future.wait([
      DriverFactory.driver.listPeriodRecords(userId, year: _currentYear, month: _currentMonth),
      DriverFactory.driver.listRecentPeriodRecords(userId, PeriodConstants.inPeriodLookbackDays * 2 + 30),
      DriverFactory.driver.getPeriodStatistics(userId),
    ]);

    final monthResult = results[0] as dynamic;
    final recentResult = results[1] as dynamic;
    final statsResult = results[2] as dynamic;

    if (monthResult.ok) {
      _records = monthResult.data ?? [];
    }
    if (recentResult.ok) {
      _recentRecords = recentResult.data ?? [];
    }
    if (statsResult.ok) {
      _statistics = statsResult.data ?? PeriodStatisticsVO.empty;
    }

    // 用最新数据刷新 isInPeriod 缓存
    _refreshInPeriodCache();

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

  /// 获取指定日期的记录（从当月数据中查找）
  PeriodRecordVO? getRecordByDate(String recordDate) {
    try {
      return _records.firstWhere((r) => r.recordDate == recordDate);
    } catch (_) {
      return null;
    }
  }

  /// 获取指定日期的记录（从近 60 天数据中查找，用于跨月场景）
  PeriodRecordVO? getRecentRecordByDate(String recordDate) {
    try {
      return _recentRecords.firstWhere((r) => r.recordDate == recordDate);
    } catch (_) {
      return null;
    }
  }

  // ── isInPeriod: 用 _recentRecords 做 7 天 lookback ──

  /// 是否正在经期中（最近 7 天内有 period 记录）
  bool get isInPeriod {
    final now = DateTime.now();
    for (var i = 0; i < PeriodConstants.inPeriodLookbackDays; i++) {
      final d = now.subtract(Duration(days: i));
      final ds = _dateStr(d);
      final r = getRecentRecordByDate(ds);
      if (r != null && r.periodStatus == PeriodStatus.period) return true;
    }
    return false;
  }

  String _dateStr(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  /// 刷新 isInPeriod 缓存（loadRecords 后调用）
  void _refreshInPeriodCache() {
    // _recentRecords 已经更新，isInPeriod 直接从 _recentRecords 计算
    // 不再需要 _cachedIsInPeriod
  }

  /// 标记经期开始：仅标记当天为 period
  ///
  /// 如果已在经期中，拒绝操作并返回 false。
  Future<bool> startPeriod(String startDate) async {
    if (isInPeriod) return false;
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
    return true;
  }

  /// 标记经期结束：从最近一次经期开始日到指定日期，全部填充为 period
  ///
  /// 从数据库查询最近记录以定位经期开始日（不依赖当月数据）。
  Future<void> endPeriod({String? endDate}) async {
    _operating = true;
    notifyListeners();
    final userId = AppConfigManager.instance.userId;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 确定结束日期：默认今天，不早于今天
    final endTarget = endDate != null ? DateTime.parse(endDate) : today;
    final actualEnd = endTarget.isAfter(today) ? today : endTarget;

    // 从数据库查询最近 60 天记录，定位经期开始日
    final recentResult = await DriverFactory.driver.listRecentPeriodRecords(userId, 60);
    final recentRecords = recentResult.ok ? (recentResult.data ?? []) : [];

    // 往前搜索连续 period 记录找到开始日
    String? startDate;
    for (var i = 0; i < PeriodConstants.endPeriodSearchMaxDays; i++) {
      final d = now.subtract(Duration(days: i));
      final ds = _dateStr(d);
      final r = recentRecords.where((r) => r.recordDate == ds && r.periodStatus == PeriodStatus.period);
      if (r.isNotEmpty) {
        startDate = ds;
      } else if (startDate != null) {
        break;
      }
    }

    if (startDate != null) {
      // 验证结束日期不早于开始日期
      final start = DateTime.parse(startDate);
      if (actualEnd.isBefore(start)) {
        await loadRecords();
        _operating = false;
        notifyListeners();
        return;
      }

      // 从开始日到结束日期全部填充为 period
      var current = start;
      while (!current.isAfter(actualEnd)) {
        final ds = _dateStr(current);
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
