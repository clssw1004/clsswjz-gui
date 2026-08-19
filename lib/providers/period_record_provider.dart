import 'package:flutter/material.dart';
import 'package:clsswjz_gui/drivers/driver_factory.dart';
import 'package:clsswjz_gui/enums/operate_type.dart';
import 'package:clsswjz_gui/events/event_bus.dart';
import 'package:clsswjz_gui/events/special/event_period.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/models/vo/period_cycle_vo.dart';
import 'package:clsswjz_gui/models/vo/period_daily_record_vo.dart';
import 'package:clsswjz_gui/models/vo/period_statistics_vo.dart';
import '../constants/period_constants.dart';
import '../enums/period_status.dart';
import '../services/period_prediction_service.dart';
import '../utils/period_calc_util.dart';

/// 经期记录数据提供者（基于 cycle 表）
class PeriodRecordProvider extends ChangeNotifier {
  /// 当月 cycles
  List<PeriodCycleVO> _cycles = [];

  /// 近 60 天 cycles（用于跨月渲染）
  List<PeriodCycleVO> _recentCycles = [];

  /// 当前未结束的 cycle
  PeriodCycleVO? _activeCycle;

  /// 当前 cycle 的每日明细
  List<PeriodDailyRecordVO> _dailyRecords = [];

  /// 预测统计
  PeriodStatisticsVO _statistics = PeriodStatisticsVO.empty;

  bool _loading = false;
  bool _operating = false;
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  // ── Getters ──

  List<PeriodCycleVO> get cycles => _cycles;
  List<PeriodCycleVO> get recentCycles => _recentCycles;
  PeriodCycleVO? get activeCycle => _activeCycle;
  List<PeriodDailyRecordVO> get dailyRecords => _dailyRecords;
  PeriodStatisticsVO get statistics => _statistics;
  bool get loading => _loading;
  bool get operating => _operating;
  int get currentYear => _currentYear;
  int get currentMonth => _currentMonth;

  /// 是否在经期中（有未结束的周期）
  bool get isInPeriod => _activeCycle != null;

  /// 当前所处周期阶段
  PeriodPhase get currentPhase => PeriodCalcUtil.determinePhase(
        isInPeriod: isInPeriod,
        statistics: _statistics,
      );

  /// 当前是经期第几天（仅经期中有效）
  int? get currentPeriodDay {
    if (!isInPeriod || _activeCycle == null) return null;
    final start = DateTime.parse(_activeCycle!.startDate);
    final now = DateTime.now();
    return now.difference(start).inDays + 1;
  }

  /// 距下次经期天数
  int? get daysUntilNextPeriod => PeriodCalcUtil.calcDaysUntilNextPeriod(
        statistics: _statistics,
      );

  /// 本次经期开始日期
  String? get periodStartDate => _activeCycle?.startDate;

  /// 是否在排卵期（易孕窗口内）
  bool get isInFertileWindow => PeriodCalcUtil.isInFertileWindow(
        statistics: _statistics,
      );

  /// 是否在安全期
  bool get isInSafePeriod => PeriodCalcUtil.isInSafePeriod(
        isInPeriod: isInPeriod,
        statistics: _statistics,
      );

  /// 当前周期内的最后一条明细记录日期
  String? get lastDailyRecordDate {
    if (_dailyRecords.isEmpty) return null;
    _dailyRecords.sort((a, b) => a.recordDate.compareTo(b.recordDate));
    return _dailyRecords.last.recordDate;
  }

  // ── 数据加载 ──

  /// 加载指定月份的数据
  Future<void> loadRecords({int? year, int? month}) async {
    _loading = true;
    notifyListeners();

    if (year != null) _currentYear = year;
    if (month != null) _currentMonth = month;

    final userId = AppConfigManager.instance.userId;

    // 并行加载：当月 cycles + 近 60 天 cycles + 当前活跃周期 + 所有 cycles（用于统计）
    final results = await Future.wait([
      DriverFactory.driver.listPeriodCycles(userId, year: _currentYear, month: _currentMonth),
      DriverFactory.driver.listRecentPeriodCycles(userId, PeriodConstants.inPeriodLookbackDays * 2 + 30),
      DriverFactory.driver.getActivePeriodCycle(userId),
      DriverFactory.driver.listAllPeriodCycles(userId),
    ]);

    final monthResult = results[0] as dynamic;
    final recentResult = results[1] as dynamic;
    final activeResult = results[2] as dynamic;
    final allResult = results[3] as dynamic;

    if (monthResult.ok) {
      _cycles = monthResult.data ?? [];
    }
    if (recentResult.ok) {
      _recentCycles = recentResult.data ?? [];
    }
    if (activeResult.ok) {
      _activeCycle = activeResult.data;
    }
    if (allResult.ok) {
      final allCycles = (allResult.data as List<PeriodCycleVO>);
      _statistics = PeriodPredictionService.calculateFromCycles(allCycles);
    }

    // 加载当前活跃周期的每日明细
    if (_activeCycle != null) {
      final dailyResult = await DriverFactory.driver.listPeriodDailyRecords(
        userId, _activeCycle!.id,
      );
      if (dailyResult.ok) {
        _dailyRecords = dailyResult.data ?? [];
      }
    } else {
      _dailyRecords = [];
    }

    _loading = false;
    notifyListeners();
  }

  /// 切换月份
  Future<void> changeMonth(int year, int month) async {
    await loadRecords(year: year, month: month);
  }

  // ── 周期操作 ──

  /// 标记经期开始
  ///
  /// 如果有未结束周期，自动结束旧周期（endDate = 新开始日前一天）。
  /// 如果已在经期中且新日期 == startDate，拒绝操作。
  Future<bool> startPeriod(String startDate) async {
    if (operating) return false;

    // 如果已有相同开始日期的活跃周期，拒绝
    if (_activeCycle != null && _activeCycle!.startDate == startDate) {
      return false;
    }

    _operating = true;
    notifyListeners();

    final userId = AppConfigManager.instance.userId;

    // 如果有未结束周期，自动结束旧周期
    if (_activeCycle != null) {
      final newStart = DateTime.parse(startDate);
      final autoEndDate = newStart.subtract(const Duration(days: 1));
      final autoEndStr = _dateStr(autoEndDate);
      await DriverFactory.driver.updatePeriodCycleEndDate(
        userId, _activeCycle!.id, autoEndStr,
      );
    }

    // 创建新周期
    await DriverFactory.driver.createPeriodCycle(userId, startDate);

    await loadRecords();
    _operating = false;
    notifyListeners();
    EventBus.instance.emit(const PeriodRecordChangedEvent(OperateType.create));
    return true;
  }

  /// 结束经期（直接用点击日期作为 endDate）
  ///
  /// 校验：endDate ≥ 最后一条明细记录日期，endDate ≤ 今天
  Future<bool> endPeriod(String endDate) async {
    if (operating || _activeCycle == null) return false;

    final end = DateTime.parse(endDate);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // 校验：不能超过今天
    if (end.isAfter(todayOnly)) return false;

    // 校验：不能早于最后一条明细记录日期
    if (lastDailyRecordDate != null) {
      final lastRecord = DateTime.parse(lastDailyRecordDate!);
      if (end.isBefore(lastRecord)) return false;
    }

    _operating = true;
    notifyListeners();

    final userId = AppConfigManager.instance.userId;
    await DriverFactory.driver.updatePeriodCycleEndDate(
      userId, _activeCycle!.id, endDate,
    );

    await loadRecords();
    _operating = false;
    notifyListeners();
    EventBus.instance.emit(const PeriodRecordChangedEvent(OperateType.update));
    return true;
  }

  /// 补记历史周期（开始 + 结束日期都必填）
  ///
  /// 日期范围约束由调用方（UI）负责校验。
  Future<void> backfillPeriod(
    String startDate,
    String endDate, {
    int? typicalPeriodDays,
    int? typicalCycleDays,
  }) async {
    if (operating) return;

    _operating = true;
    notifyListeners();

    final userId = AppConfigManager.instance.userId;
    await DriverFactory.driver.createPeriodCycle(
      userId, startDate, endDate: endDate,
      typicalPeriodDays: typicalPeriodDays,
      typicalCycleDays: typicalCycleDays,
    );

    await loadRecords();
    _operating = false;
    notifyListeners();
    EventBus.instance.emit(const PeriodRecordChangedEvent(OperateType.create));
  }

  /// 删除周期及关联的每日明细
  Future<void> deleteCycle(String cycleId) async {
    _operating = true;
    notifyListeners();

    final userId = AppConfigManager.instance.userId;
    await DriverFactory.driver.deletePeriodCycle(userId, cycleId);

    await loadRecords();
    _operating = false;
    notifyListeners();
    EventBus.instance.emit(const PeriodRecordChangedEvent(OperateType.delete));
  }

  // ── 每日明细操作 ──

  /// 添加或更新每日明细
  Future<void> upsertDailyRecord(
    String recordDate, {
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) async {
    if (_activeCycle == null) return;

    final userId = AppConfigManager.instance.userId;
    await DriverFactory.driver.upsertPeriodDailyRecord(
      userId,
      _activeCycle!.id,
      recordDate,
      flowLevel: flowLevel,
      symptoms: symptoms,
      mood: mood,
      remark: remark,
    );

    // 重新加载明细
    final dailyResult = await DriverFactory.driver.listPeriodDailyRecords(
      userId, _activeCycle!.id,
    );
    if (dailyResult.ok) {
      _dailyRecords = dailyResult.data ?? [];
    }

    notifyListeners();
    EventBus.instance.emit(const PeriodRecordChangedEvent(OperateType.update));
  }

  /// 获取指定日期的每日明细
  PeriodDailyRecordVO? getDailyRecordByDate(String recordDate) {
    try {
      return _dailyRecords.firstWhere((r) => r.recordDate == recordDate);
    } catch (_) {
      return null;
    }
  }

  /// 查找指定日期所属的周期
  PeriodCycleVO? findCycleForDate(String date) {
    for (final cycle in _recentCycles) {
      final start = cycle.startDate;
      final end = cycle.endDate;
      if (end != null) {
        // 已结束的周期：date 在 [startDate, endDate] 范围内
        if (date.compareTo(start) >= 0 && date.compareTo(end) <= 0) {
          return cycle;
        }
      } else {
        // 未结束的周期：date >= startDate
        if (date.compareTo(start) >= 0) {
          return cycle;
        }
      }
    }
    return null;
  }

  /// 查找指定日期的前一个周期（用于补记范围约束）
  PeriodCycleVO? findPreviousCycle(String date) {
    PeriodCycleVO? prev;
    for (final cycle in _recentCycles) {
      if (cycle.startDate.compareTo(date) < 0) {
        prev = cycle;
      } else {
        break;
      }
    }
    return prev;
  }

  /// 查找指定日期的后一个周期（用于补记范围约束）
  PeriodCycleVO? findNextCycle(String date) {
    for (final cycle in _recentCycles) {
      if (cycle.startDate.compareTo(date) > 0) {
        return cycle;
      }
    }
    return null;
  }

  String _dateStr(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
