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

  /// 全量 cycles（用于统计与相邻周期查找）
  List<PeriodCycleVO> _allCycles = [];

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
  List<PeriodCycleVO> get allCycles => _allCycles;
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

  /// 预测经期是否已开始但未记录（今天处于预测经期窗口内）
  bool get isPredictedPeriodDue {
    if (!_statistics.canPredict || _statistics.nextPeriodDate == null) {
      return false;
    }
    final today = _todayStr();
    final next = _statistics.nextPeriodDate!;
    final windowEnd = _addDays(next, _statistics.averagePeriodLength - 1);
    return today.compareTo(next) >= 0 && today.compareTo(windowEnd) <= 0;
  }

  /// 预测经期窗口已完全过去但未记录（疑似延迟），返回推迟天数；未过期返回 null
  int? get periodOverdueDays {
    if (!_statistics.canPredict || _statistics.nextPeriodDate == null) {
      return null;
    }
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final windowEnd = DateTime.parse(
      _addDays(_statistics.nextPeriodDate!, _statistics.averagePeriodLength - 1),
    );
    if (todayOnly.isAfter(windowEnd)) {
      return todayOnly.difference(windowEnd).inDays;
    }
    return null;
  }

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
  ///
  /// [refreshStatistics] 为 false 时跳过全量周期与统计的刷新（仅切月时使用，
  /// 避免每次翻月都全表查询）。
  Future<void> loadRecords({
    int? year,
    int? month,
    bool refreshStatistics = true,
  }) async {
    _loading = true;
    notifyListeners();

    if (year != null) _currentYear = year;
    if (month != null) _currentMonth = month;

    final userId = AppConfigManager.instance.userId;

    // 并行加载：当月 cycles + 近 60 天 cycles + 当前活跃周期 (+ 全量 cycles 用于统计)
    final futures = <Future<dynamic>>[
      DriverFactory.driver.listPeriodCycles(userId, year: _currentYear, month: _currentMonth),
      DriverFactory.driver.listRecentPeriodCycles(userId, PeriodConstants.inPeriodLookbackDays * 2 + 30),
      DriverFactory.driver.getActivePeriodCycle(userId),
      if (refreshStatistics) DriverFactory.driver.listAllPeriodCycles(userId),
    ];
    final results = await Future.wait(futures);

    final monthResult = results[0] as dynamic;
    final recentResult = results[1] as dynamic;
    final activeResult = results[2] as dynamic;

    if (monthResult.ok) {
      _cycles = monthResult.data ?? [];
    }
    if (recentResult.ok) {
      _recentCycles = recentResult.data ?? [];
    }
    if (activeResult.ok) {
      _activeCycle = activeResult.data;
    }
    if (refreshStatistics && results.length > 3) {
      final allResult = results[3] as dynamic;
      if (allResult.ok) {
        final allCycles = (allResult.data as List<PeriodCycleVO>);
        _allCycles = allCycles;
        _statistics = PeriodPredictionService.calculateFromCycles(allCycles);
      }
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

  /// 切换月份（仅刷新当月数据，统计与全量周期保持不变）
  Future<void> changeMonth(int year, int month) async {
    await loadRecords(year: year, month: month, refreshStatistics: false);
  }

  // ── 周期操作 ──

  /// 标记经期开始
  ///
  /// 校验：不能为未来日期、不能与已有周期重叠、不能与活跃周期开始日相同。
  /// 如果有未结束周期，自动结束所有旧周期（endDate = 新开始日前一天）。
  Future<bool> startPeriod(String startDate) async {
    if (operating) return false;

    final start = DateTime.parse(startDate);
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);

    // 校验：不能是未来日期
    if (start.isAfter(todayOnly)) return false;

    // 校验：与活跃周期开始日相同
    if (_activeCycle != null && _activeCycle!.startDate == startDate) {
      return false;
    }

    // 校验：开始日不能落在任一已结束周期的 [startDate, endDate] 区间内
    for (final cycle in _allCycles) {
      final end = cycle.endDate;
      if (end == null) continue; // 活跃周期统一自动结束
      if (startDate.compareTo(cycle.startDate) >= 0 &&
          startDate.compareTo(end) <= 0) {
        return false;
      }
    }

    _operating = true;
    notifyListeners();

    final userId = AppConfigManager.instance.userId;

    // 结束所有未结束周期（覆盖多活跃周期异常场景），endDate = 新开始日前一天
    final autoEndStr = _dateStr(start.subtract(const Duration(days: 1)));
    for (final cycle in _allCycles) {
      if (cycle.endDate == null) {
        await DriverFactory.driver.updatePeriodCycleEndDate(
          userId, cycle.id, autoEndStr,
        );
      }
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
  /// 校验：endDate ≥ 周期开始日，endDate ≥ 最后一条明细记录日期，endDate ≤ 今天
  Future<bool> endPeriod(String endDate) async {
    if (operating || _activeCycle == null) return false;

    final end = DateTime.parse(endDate);
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    // 校验：不能超过今天
    if (end.isAfter(todayOnly)) return false;

    // 校验：不能早于周期开始日
    final startOnly = DateTime.parse(_activeCycle!.startDate);
    if (end.isBefore(startOnly)) return false;

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

  /// 补记历史周期
  ///
  /// [startDate] 必填，[endDate] 可为空（表示经期尚未结束/未知）。
  /// 校验：endDate ≥ startDate，endDate ≤ 今天，不与已有周期重叠。
  Future<void> backfillPeriod(
    String startDate,
    String? endDate, {
    int? typicalPeriodDays,
    int? typicalCycleDays,
  }) async {
    if (operating) return;

    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final start = DateTime.parse(startDate);

    // 校验：开始日不能是未来日期
    if (start.isAfter(todayOnly)) return;

    // 校验：结束日不能早于开始日、不能是未来日期
    if (endDate != null) {
      final end = DateTime.parse(endDate);
      if (end.isBefore(start)) return;
      if (end.isAfter(todayOnly)) return;
    }

    // 校验：补记区间不能与已有周期重叠（[start, end] 或 [start, ∞) 与任一周期相交）
    for (final cycle in _allCycles) {
      final cStart = cycle.startDate;
      final cEnd = cycle.endDate;
      // 新补记区间 [start, end或today] 与已有周期 [cStart, cEnd或∞] 是否有交集
      final newEnd = endDate ?? _todayStr();
      final isNewCoveringStart = startDate.compareTo(cStart) >= 0 &&
          startDate.compareTo(cEnd ?? newEnd) <= 0;
      final isNewCoveredByExisting = cStart.compareTo(startDate) >= 0 &&
          cStart.compareTo(newEnd) <= 0;
      if (isNewCoveringStart || isNewCoveredByExisting) {
        return;
      }
    }

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

  /// 删除指定周期内指定日期的每日明细
  Future<void> deleteDailyRecord(String cycleId, String recordDate) async {
    final userId = AppConfigManager.instance.userId;
    await DriverFactory.driver.deletePeriodDailyRecord(userId, cycleId, recordDate);

    // 重新加载该周期明细
    final dailyResult = await DriverFactory.driver.listPeriodDailyRecords(
      userId, cycleId,
    );
    if (dailyResult.ok) {
      _dailyRecords = dailyResult.data ?? [];
    }
    notifyListeners();
    EventBus.instance.emit(const PeriodRecordChangedEvent(OperateType.delete));
  }

  // ── 每日明细操作 ──

  /// 加载指定周期的每日明细（用于查看/编辑历史周期明细）
  ///
  /// 加载后 [_dailyRecords] 即为该周期的明细，[getDailyRecordByDate] 生效。
  Future<void> loadDailyRecordsForCycle(String cycleId) async {
    final userId = AppConfigManager.instance.userId;
    final dailyResult = await DriverFactory.driver.listPeriodDailyRecords(
      userId, cycleId,
    );
    if (dailyResult.ok) {
      _dailyRecords = dailyResult.data ?? [];
      notifyListeners();
    }
  }

  /// 添加或更新每日明细
  ///
  /// [cycleId] 缺省时使用当前活跃周期；传入时用于编辑历史周期明细。
  /// 校验：记录日期必须在周期 [startDate, endDate] 范围内。
  Future<void> upsertDailyRecord(
    String recordDate, {
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
    String? cycleId,
  }) async {
    PeriodCycleVO? targetCycle;
    if (cycleId != null) {
      for (final c in _allCycles) {
        if (c.id == cycleId) {
          targetCycle = c;
          break;
        }
      }
    } else {
      targetCycle = _activeCycle;
    }
    if (targetCycle == null) return;

    // 校验记录日期在周期范围内
    final start = DateTime.parse(targetCycle.startDate);
    final end = targetCycle.endDate != null
        ? DateTime.parse(targetCycle.endDate!)
        : DateTime.now();
    final d = DateTime.parse(recordDate);
    if (d.isBefore(start) || d.isAfter(end)) return;

    final userId = AppConfigManager.instance.userId;
    await DriverFactory.driver.upsertPeriodDailyRecord(
      userId,
      targetCycle.id,
      recordDate,
      flowLevel: flowLevel,
      symptoms: symptoms,
      mood: mood,
      remark: remark,
    );

    // 重新加载该周期明细
    final dailyResult = await DriverFactory.driver.listPeriodDailyRecords(
      userId, targetCycle.id,
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

  /// 查找指定日期所属的周期（基于全量周期，覆盖补记的历史周期）
  PeriodCycleVO? findCycleForDate(String date) {
    for (final cycle in _allCycles) {
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

  /// 查找指定日期的前一个周期（用于补记范围约束，基于全量周期）
  PeriodCycleVO? findPreviousCycle(String date) {
    PeriodCycleVO? prev;
    for (final cycle in _allCycles) {
      if (cycle.startDate.compareTo(date) < 0) {
        prev = cycle;
      } else {
        break;
      }
    }
    return prev;
  }

  /// 查找指定日期的后一个周期（用于补记范围约束，基于全量周期）
  PeriodCycleVO? findNextCycle(String date) {
    for (final cycle in _allCycles) {
      if (cycle.startDate.compareTo(date) > 0) {
        return cycle;
      }
    }
    return null;
  }

  String _dateStr(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _addDays(String date, int days) {
    final d = DateTime.parse(date).add(Duration(days: days));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
