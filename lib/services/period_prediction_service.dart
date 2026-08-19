import '../constants/period_constants.dart';
import '../models/vo/period_cycle_vo.dart';
import '../models/vo/period_statistics_vo.dart';

/// 日期类型标记
enum DateType {
  period,        // 经期
  ovulation,     // 排卵日
  fertile,       // 危险期（易孕期）
  safe,          // 安全区
  predictedPeriod, // 预测经期
}

/// 经期预测服务
class PeriodPredictionService {
  /// 从周期列表计算统计和预测
  ///
  /// - 周期长度：相邻已结束周期的 startDate 差值（15~60 天内有效）
  /// - 经期天数：已结束周期的 startDate ~ endDate 跨度（<15 天有效）
  /// - 无足够历史时回退到最近周期上的用户配置（typicalCycleDays/typicalPeriodDays），
  ///   支持单周期（仅 onboarding 填写典型参数）即可预测
  static PeriodStatisticsVO calculateFromCycles(List<PeriodCycleVO> cycles) {
    if (cycles.isEmpty) return PeriodStatisticsVO.empty;

    // 按开始日期排序
    final sorted = List<PeriodCycleVO>.from(cycles)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    // 计算周期长度（相邻两个周期的 startDate 差值）
    final cycleLengths = <int>[];
    for (var i = 1; i < sorted.length; i++) {
      final diff = _daysBetween(sorted[i - 1].startDate, sorted[i].startDate);
      if (diff > PeriodConstants.minCycleLength && diff < PeriodConstants.maxCycleLength) {
        cycleLengths.add(diff);
      }
    }

    // 计算经期天数（仅已结束的周期）
    final periodLengths = <int>[];
    for (final cycle in sorted) {
      if (cycle.endDate != null) {
        final days = _daysBetween(cycle.startDate, cycle.endDate!) + 1;
        if (days > 0 && days < 15) {
          periodLengths.add(days);
        }
      }
    }

    // 提取最近周期上的典型参数（校验合法范围）
    int? typicalCycle;
    int? typicalPeriod;
    for (final cycle in sorted.reversed) {
      if (typicalCycle == null &&
          cycle.typicalCycleDays != null &&
          cycle.typicalCycleDays! >= PeriodConstants.typicalCycleMin &&
          cycle.typicalCycleDays! <= PeriodConstants.typicalCycleMax) {
        typicalCycle = cycle.typicalCycleDays;
      }
      if (typicalPeriod == null &&
          cycle.typicalPeriodDays != null &&
          cycle.typicalPeriodDays! >= PeriodConstants.typicalPeriodMin &&
          cycle.typicalPeriodDays! <= PeriodConstants.typicalPeriodMax) {
        typicalPeriod = cycle.typicalPeriodDays;
      }
      if (typicalCycle != null && typicalPeriod != null) break;
    }

    final hasCycleData = cycleLengths.isNotEmpty;
    final avgCycle = hasCycleData
        ? (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round()
        : (typicalCycle ?? 28);
    final avgPeriod = periodLengths.isNotEmpty
        ? (periodLengths.reduce((a, b) => a + b) / periodLengths.length).round()
        : (typicalPeriod ?? 5);

    // 最近一次经期开始日
    final lastStart = sorted.last.startDate;

    // 预测
    final canPredict = hasCycleData || typicalCycle != null;
    String? nextPeriodDate;
    String? ovulationDate;
    String? fertileStart;
    String? fertileEnd;

    if (canPredict) {
      nextPeriodDate = _addDays(lastStart, avgCycle);
      ovulationDate = _addDays(nextPeriodDate, -PeriodConstants.lutealPhaseDays);
      fertileStart = _addDays(ovulationDate, -PeriodConstants.fertileWindowBeforeOvulation);
      fertileEnd = _addDays(ovulationDate, PeriodConstants.fertileWindowAfterOvulation);
    }

    return PeriodStatisticsVO(
      averageCycleLength: avgCycle,
      averagePeriodLength: avgPeriod,
      totalRecords: cycles.length,
      recentCycleLengths: cycleLengths,
      lastPeriodStart: lastStart,
      nextPeriodDate: nextPeriodDate,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
      typicalCycleDays: typicalCycle,
      typicalPeriodDays: typicalPeriod,
    );
  }

  /// 获取各日期的类型标记（从 cycles）
  ///
  /// 完整时期渲染：
  /// - 实际经期日：已结束周期 [startDate, endDate]、未结束周期 [startDate, 今天]
  /// - 进行中经期的预期延续日：今天之后至 开始日 + 平均经期 - 1，标记为预测经期
  ///   （避免把当前经期尚未结束的日期渲染成安全期）
  /// - 每个实际周期的排卵日与易孕窗：排卵日 = 下一周期开始日 - 14（黄体期），
  ///   最后一个周期用 开始日 + 平均周期 - 14；**含已过去的日期（回顾用途）**
  /// - 预测经期/排卵/易孕：从下次预测经期开始向前迭代 [predictIterations] 个周期，
  ///   仅标记尚未完全过去的预测窗口（已过期的预测不显示）
  /// - 安全期：可预测时，从最早周期开始日（进行中经期时从其预计结束日的下一天）
  ///   到最远预测日之间未标记的日期标记为安全期
  ///
  /// [today] 用于测试注入，缺省为系统当前日期。
  static Map<String, DateType> getMonthDateTypes(
    List<PeriodCycleVO> cycles,
    PeriodStatisticsVO? statistics, {
    String? today,
  }) {
    final result = <String, DateType>{};
    final todayStr = today ?? _todayStr();

    final sorted = List<PeriodCycleVO>.from(cycles)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    // 1. 标记实际经期日（startDate ~ endDate）
    PeriodCycleVO? activeCycle;
    for (final cycle in sorted) {
      if (cycle.endDate != null) {
        var date = cycle.startDate;
        final end = cycle.endDate!;
        while (date.compareTo(end) <= 0) {
          result[date] = DateType.period;
          date = _addDays(date, 1);
        }
      } else {
        // 未结束的周期：标记 startDate 到今天的经期日
        activeCycle = cycle;
        var date = cycle.startDate;
        while (date.compareTo(todayStr) <= 0) {
          result[date] = DateType.period;
          date = _addDays(date, 1);
        }
      }
    }

    // 1.5 进行中经期的预期延续日（今天之后 ~ 开始日 + 平均经期 - 1）标为预测经期，
    //     避免被安全期标记覆盖（安全期应从当前经期结束后才开始）
    if (activeCycle != null && statistics != null && statistics.canPredict) {
      final expectEnd =
          _addDays(activeCycle.startDate, statistics.averagePeriodLength - 1);
      if (expectEnd.compareTo(todayStr) > 0) {
        var date = _addDays(todayStr, 1);
        while (date.compareTo(expectEnd) <= 0) {
          result[date] ??= DateType.predictedPeriod;
          date = _addDays(date, 1);
        }
      }
    }

    // 2. 每个实际周期的排卵日 + 易孕窗（含已过去的日期，供回顾查看）
    for (var i = 0; i < sorted.length; i++) {
      final cycle = sorted[i];
      final String ovulation;
      if (i + 1 < sorted.length) {
        // 排卵日 ≈ 下一周期开始日 - 黄体期
        ovulation =
            _addDays(sorted[i + 1].startDate, -PeriodConstants.lutealPhaseDays);
      } else {
        // 最后一个周期：用预测周期长度推算下次经期
        final avgCycle = statistics?.averageCycleLength ?? 28;
        ovulation =
            _addDays(cycle.startDate, avgCycle - PeriodConstants.lutealPhaseDays);
      }

      result[ovulation] ??= DateType.ovulation;
      final fertileStart =
          _addDays(ovulation, -PeriodConstants.fertileWindowBeforeOvulation);
      final fertileEnd =
          _addDays(ovulation, PeriodConstants.fertileWindowAfterOvulation);
      var date = fertileStart;
      while (date.compareTo(fertileEnd) <= 0) {
        result[date] ??= DateType.fertile;
        date = _addDays(date, 1);
      }
    }

    // 3. 未来预测（多周期迭代）
    String? maxPredictedEnd;
    if (statistics != null && statistics.canPredict) {
      var predStart = statistics.nextPeriodDate;
      var iterations = 0;
      while (predStart != null && iterations < PeriodConstants.predictIterations) {
        final windowEnd = _addDays(predStart, statistics.averagePeriodLength - 1);
        if (windowEnd.compareTo(todayStr) >= 0) {
          // 该预测窗口尚未完全过去才标记（已过期的预测不显示）
          for (var i = 0; i < statistics.averagePeriodLength; i++) {
            final date = _addDays(predStart, i);
            if (date.compareTo(todayStr) >= 0) {
              result[date] ??= DateType.predictedPeriod;
            }
          }

          // 排卵日（仅未来）
          final ovulation = _addDays(predStart, -PeriodConstants.lutealPhaseDays);
          if (ovulation.compareTo(todayStr) >= 0) {
            result[ovulation] ??= DateType.ovulation;
          }

          // 易孕期（仅未来）
          final fertileStart =
              _addDays(ovulation, -PeriodConstants.fertileWindowBeforeOvulation);
          final fertileEnd =
              _addDays(ovulation, PeriodConstants.fertileWindowAfterOvulation);
          var date = fertileStart;
          while (date.compareTo(fertileEnd) <= 0) {
            if (date.compareTo(todayStr) >= 0) {
              result[date] ??= DateType.fertile;
            }
            date = _addDays(date, 1);
          }
        }
        maxPredictedEnd = windowEnd;
        iterations++;
        if (iterations >= PeriodConstants.predictIterations) break;
        predStart = _addDays(predStart, statistics.averageCycleLength);
      }
    }

    // 4. 安全期：到最远预测日之间无标记的日期标记为安全期（含过去日期，供回顾查看）。
    //    起点：存在进行中经期时从其预计结束日的下一天开始（避免把当前经期的
    //    延续日标成安全期）；否则从最早周期开始日（或今天）开始
    if (statistics != null && statistics.canPredict && maxPredictedEnd != null) {
      String safeStart;
      if (activeCycle != null) {
        final expectEnd =
            _addDays(activeCycle.startDate, statistics.averagePeriodLength - 1);
        // 已超期时从今天开始（今天已被 period 覆盖，实际从明天起生效）
        safeStart = expectEnd.compareTo(todayStr) >= 0
            ? _addDays(expectEnd, 1)
            : todayStr;
      } else {
        safeStart =
            sorted.isNotEmpty ? sorted.first.startDate : todayStr;
      }
      var date = safeStart;
      while (date.compareTo(maxPredictedEnd) <= 0) {
        result[date] ??= DateType.safe;
        date = _addDays(date, 1);
      }
    }

    return result;
  }

  static int _daysBetween(String date1, String date2) {
    final d1 = DateTime.parse(date1);
    final d2 = DateTime.parse(date2);
    return d2.difference(d1).inDays;
  }

  static String _addDays(String date, int days) {
    final d = DateTime.parse(date).add(Duration(days: days));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
