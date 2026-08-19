import '../enums/period_status.dart';
import '../models/vo/period_statistics_vo.dart';

/// 经期计算工具类
///
/// 纯函数集合，所有输入通过参数传入，无副作用。
/// Provider 和 Service 调用此类获取计算结果。
class PeriodCalcUtil {
  PeriodCalcUtil._();

  // ── 周期阶段判定 ──

  /// 判断当前所处周期阶段
  ///
  /// 顺序：经期中 → 预测经期窗口内（今天处于 [nextPeriodDate, nextPeriodDate+avgPeriod)）
  /// → 易孕窗口内 → 安全期 → 无数据。
  static PeriodPhase determinePhase({
    required bool isInPeriod,
    required PeriodStatisticsVO statistics,
    String? today,
  }) {
    if (isInPeriod) return PeriodPhase.period;
    // 有记录但不足以预测
    if (statistics.totalRecords > 0 && !statistics.canPredict) {
      return PeriodPhase.noData; // 复用 noData 但 UI 层会区分
    }
    if (!statistics.canPredict) return PeriodPhase.noData;

    final date = today ?? _todayStr();

    // 预测经期窗口内
    final next = statistics.nextPeriodDate;
    if (next != null) {
      final windowEnd = _addDays(next, statistics.averagePeriodLength - 1);
      if (date.compareTo(next) >= 0 && date.compareTo(windowEnd) <= 0) {
        return PeriodPhase.predicted;
      }
    }

    final fertileStart = statistics.fertileWindowStart;
    final fertileEnd = statistics.fertileWindowEnd;

    if (fertileStart != null && fertileEnd != null) {
      if (date.compareTo(fertileStart) >= 0 &&
          date.compareTo(fertileEnd) <= 0) {
        return PeriodPhase.ovulation;
      }
    }

    return PeriodPhase.safe;
  }

  // ── 经期天数计算 ──

  // ── 距下次经期天数 ──

  /// 计算距下次经期的天数
  ///
  /// 无法预测时返回 null，已过预测日也返回 null。
  static int? calcDaysUntilNextPeriod({
    required PeriodStatisticsVO statistics,
    String? today,
  }) {
    if (!statistics.canPredict || statistics.nextPeriodDate == null) {
      return null;
    }
    final next = DateTime.parse(statistics.nextPeriodDate!);
    final todayDate = today != null
        ? DateTime.parse(today)
        : DateTime.now();
    final todayOnly = DateTime(todayDate.year, todayDate.month, todayDate.day);
    final diff = next.difference(todayOnly).inDays;
    return diff >= 0 ? diff : null;
  }

  // ── 易孕期 / 安全期判定 ──

  /// 是否在排卵期（易孕窗口内）
  static bool isInFertileWindow({
    required PeriodStatisticsVO statistics,
    String? today,
  }) {
    if (!statistics.canPredict) return false;
    final date = today ?? _todayStr();
    final start = statistics.fertileWindowStart;
    final end = statistics.fertileWindowEnd;
    if (start == null || end == null) return false;
    return date.compareTo(start) >= 0 && date.compareTo(end) <= 0;
  }

  /// 是否在安全期
  static bool isInSafePeriod({
    required bool isInPeriod,
    required PeriodStatisticsVO statistics,
    String? today,
  }) {
    if (!isInPeriod &&
        statistics.canPredict &&
        !isInFertileWindow(statistics: statistics, today: today)) {
      return true;
    }
    return false;
  }

  // ── 工具方法 ──

  static String _todayStr() => _dateStr(DateTime.now());

  static String _addDays(String date, int days) {
    final d = DateTime.parse(date).add(Duration(days: days));
    return _dateStr(d);
  }

  static String _dateStr(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
