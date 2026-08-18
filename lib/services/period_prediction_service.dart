import '../constants/period_constants.dart';
import '../enums/period_status.dart';
import '../models/vo/period_record_vo.dart';
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
  /// 从记录列表计算周期统计和预测
  static PeriodStatisticsVO calculate(List<PeriodRecordVO> allRecords) {
    if (allRecords.isEmpty) return PeriodStatisticsVO.empty;

    // 筛选 period 状态的记录，按日期排序
    final periodRecords = allRecords
        .where((r) => r.periodStatus == PeriodStatus.period)
        .toList()
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

    if (periodRecords.isEmpty) return PeriodStatisticsVO.empty;

    // 识别连续经期日（间隔<=1天视为同一经期）
    final cycles = _identifyCycles(periodRecords);

    if (cycles.isEmpty) return PeriodStatisticsVO.empty;

    // 计算周期长度
    final cycleLengths = <int>[];
    for (var i = 1; i < cycles.length; i++) {
      final diff = _daysBetween(cycles[i - 1].first.recordDate, cycles[i].first.recordDate);
      if (diff > PeriodConstants.minCycleLength && diff < PeriodConstants.maxCycleLength) {
        cycleLengths.add(diff);
      }
    }

    // 计算经期天数
    final periodLengths = cycles.map((c) => c.length).toList();

    final avgCycle = cycleLengths.isNotEmpty
        ? (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round()
        : 28;
    final avgPeriod = periodLengths.isNotEmpty
        ? (periodLengths.reduce((a, b) => a + b) / periodLengths.length).round()
        : 5;

    // 最近一次经期开始日
    final lastStart = cycles.last.first.recordDate;

    // 预测
    String? nextPeriodDate;
    String? ovulationDate;
    String? fertileStart;
    String? fertileEnd;

    if (cycleLengths.length >= 2) {
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

  /// 识别连续经期周期
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

  /// 获取某月各日期的类型标记
  static Map<String, DateType> getMonthDateTypes(
    List<PeriodRecordVO> monthRecords,
    PeriodStatisticsVO? statistics,
  ) {
    final result = <String, DateType>{};

    // 标记已记录的经期日
    for (final r in monthRecords) {
      if (r.periodStatus == PeriodStatus.period) {
        result[r.recordDate] = DateType.period;
      }
    }

    // 标记预测日期（仅标记未来日期，忽略已过期的预测）
    if (statistics != null && statistics.canPredict) {
      final todayStr = _todayStr();

      // 预测经期（仅未来）
      if (statistics.nextPeriodDate != null &&
          statistics.nextPeriodDate!.compareTo(todayStr) >= 0) {
        for (var i = 0; i < statistics.averagePeriodLength; i++) {
          final date = _addDays(statistics.nextPeriodDate!, i);
          result[date] ??= DateType.predictedPeriod;
        }
      }

      // 排卵日（仅未来）
      if (statistics.ovulationDate != null &&
          statistics.ovulationDate!.compareTo(todayStr) >= 0) {
        result[statistics.ovulationDate!] = DateType.ovulation;
      }

      // 危险期（仅未来）
      if (statistics.fertileWindowStart != null && statistics.fertileWindowEnd != null) {
        var date = statistics.fertileWindowStart!;
        while (date.compareTo(statistics.fertileWindowEnd!) <= 0) {
          if (date.compareTo(todayStr) >= 0) {
            if (result[date] == null || result[date] == DateType.safe) {
              result[date] = DateType.fertile;
            }
          }
          date = _addDays(date, 1);
        }
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
