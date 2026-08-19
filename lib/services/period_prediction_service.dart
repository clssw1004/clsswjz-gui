import '../constants/period_constants.dart';
import '../enums/period_status.dart';
import '../models/vo/period_record_vo.dart';
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
  /// 从周期列表计算统计和预测（新方法）
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

    final avgCycle = cycleLengths.isNotEmpty
        ? (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round()
        : 28;
    final avgPeriod = periodLengths.isNotEmpty
        ? (periodLengths.reduce((a, b) => a + b) / periodLengths.length).round()
        : 5;

    // 最近一次经期开始日
    final lastStart = sorted.last.startDate;

    // 预测
    String? nextPeriodDate;
    String? ovulationDate;
    String? fertileStart;
    String? fertileEnd;

    if (cycleLengths.isNotEmpty) {
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
    );
  }

  /// 获取某月各日期的类型标记（从 cycles）
  static Map<String, DateType> getMonthDateTypes(
    List<PeriodCycleVO> cycles,
    PeriodStatisticsVO? statistics,
  ) {
    final result = <String, DateType>{};

    // 标记实际经期日（startDate ~ endDate）
    for (final cycle in cycles) {
      if (cycle.endDate != null) {
        var date = cycle.startDate;
        final end = cycle.endDate!;
        while (date.compareTo(end) <= 0) {
          result[date] = DateType.period;
          date = _addDays(date, 1);
        }
      } else {
        // 未结束的周期：标记 startDate 到今天的经期日
        final todayStr = _todayStr();
        var date = cycle.startDate;
        while (date.compareTo(todayStr) <= 0) {
          result[date] = DateType.period;
          date = _addDays(date, 1);
        }
      }
    }

    // 标记基于历史的预测日期（仅未来）
    if (statistics != null && statistics.canPredict) {
      final todayStr = _todayStr();

      // 预测经期
      if (statistics.nextPeriodDate != null &&
          statistics.nextPeriodDate!.compareTo(todayStr) >= 0) {
        for (var i = 0; i < statistics.averagePeriodLength; i++) {
          final date = _addDays(statistics.nextPeriodDate!, i);
          result[date] ??= DateType.predictedPeriod;
        }
      }

      // 排卵日
      if (statistics.ovulationDate != null &&
          statistics.ovulationDate!.compareTo(todayStr) >= 0) {
        result[statistics.ovulationDate!] = DateType.ovulation;
      }

      // 易孕期
      if (statistics.fertileWindowStart != null && statistics.fertileWindowEnd != null) {
        var date = statistics.fertileWindowStart!;
        while (date.compareTo(statistics.fertileWindowEnd!) <= 0) {
          if (date.compareTo(todayStr) >= 0) {
            if (result[date] == null) {
              result[date] = DateType.fertile;
            }
          }
          date = _addDays(date, 1);
        }
      }
    }

    return result;
  }

  /// 从记录列表计算周期统计和预测（旧方法，保留兼容）
  @Deprecated('使用 calculateFromCycles 替代')
  static PeriodStatisticsVO calculate(List<PeriodRecordVO> allRecords) {
    if (allRecords.isEmpty) return PeriodStatisticsVO.empty;

    final periodRecords = allRecords
        .where((r) => r.periodStatus == PeriodStatus.period)
        .toList()
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

    if (periodRecords.isEmpty) return PeriodStatisticsVO.empty;

    final cycles = _identifyCycles(periodRecords);
    if (cycles.isEmpty) return PeriodStatisticsVO.empty;

    final cycleLengths = <int>[];
    for (var i = 1; i < cycles.length; i++) {
      final diff = _daysBetween(cycles[i - 1].first.recordDate, cycles[i].first.recordDate);
      if (diff > PeriodConstants.minCycleLength && diff < PeriodConstants.maxCycleLength) {
        cycleLengths.add(diff);
      }
    }

    final periodLengths = cycles.map((c) => c.length).toList();

    final avgCycle = cycleLengths.isNotEmpty
        ? (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round()
        : 28;
    final avgPeriod = periodLengths.isNotEmpty
        ? (periodLengths.reduce((a, b) => a + b) / periodLengths.length).round()
        : 5;

    final lastStart = cycles.last.first.recordDate;

    String? nextPeriodDate;
    String? ovulationDate;
    String? fertileStart;
    String? fertileEnd;

    if (cycleLengths.isNotEmpty) {
      nextPeriodDate = _addDays(lastStart, avgCycle);
      ovulationDate = _addDays(nextPeriodDate, -PeriodConstants.lutealPhaseDays);
      fertileStart = _addDays(ovulationDate, -PeriodConstants.fertileWindowBeforeOvulation);
      fertileEnd = _addDays(ovulationDate, PeriodConstants.fertileWindowAfterOvulation);
    }

    return PeriodStatisticsVO(
      averageCycleLength: avgCycle,
      averagePeriodLength: avgPeriod,
      totalRecords: allRecords.length,
      recentCycleLengths: cycleLengths,
      lastPeriodStart: lastStart,
      nextPeriodDate: nextPeriodDate,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
    );
  }

  @Deprecated('使用 getMonthDateTypes(List<PeriodCycleVO>) 替代')
  static List<List<PeriodRecordVO>> _identifyCycles(List<PeriodRecordVO> sorted) {
    if (sorted.isEmpty) return [];
    final cycles = <List<PeriodRecordVO>>[];
    var current = [sorted.first];
    for (var i = 1; i < sorted.length; i++) {
      final gap = _daysBetween(sorted[i - 1].recordDate, sorted[i].recordDate);
      if (gap <= 1) {
        current.add(sorted[i]);
      } else {
        cycles.add(current);
        current = [sorted[i]];
      }
    }
    cycles.add(current);
    return cycles;
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
