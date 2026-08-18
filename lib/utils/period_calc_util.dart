import '../constants/period_constants.dart';
import '../enums/period_status.dart';
import '../models/vo/period_record_vo.dart';
import '../models/vo/period_statistics_vo.dart';

/// 经期计算工具类
///
/// 纯函数集合，所有输入通过参数传入，无副作用。
/// Provider 和 Service 调用此类获取计算结果。
class PeriodCalcUtil {
  PeriodCalcUtil._();

  // ── 周期阶段判定 ──

  /// 判断当前所处周期阶段
  static PeriodPhase determinePhase({
    required bool isInPeriod,
    required PeriodStatisticsVO statistics,
    String? today,
  }) {
    if (isInPeriod) return PeriodPhase.period;
    if (!statistics.canPredict) return PeriodPhase.noData;

    final date = today ?? _todayStr();
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

  /// 计算当前是经期第几天
  ///
  /// 从 [today] 往前搜索连续的 period 记录，返回天数（1-indexed）。
  /// 非经期返回 null。
  static int? calcCurrentPeriodDay({
    required bool isInPeriod,
    required List<PeriodRecordVO> records,
    String? today,
  }) {
    if (!isInPeriod) return null;

    final now = today != null ? DateTime.parse(today) : DateTime.now();

    // 先从 records 中查找今天的记录
    PeriodRecordVO? getRecord(String date) {
      try {
        return records.firstWhere((r) => r.recordDate == date);
      } catch (_) {
        return null;
      }
    }

    for (var i = 0; i < PeriodConstants.endPeriodSearchMaxDays; i++) {
      final d = now.subtract(Duration(days: i));
      final ds = _dateStr(d);
      final r = getRecord(ds);
      if (r == null || r.periodStatus != PeriodStatus.period) {
        return i > 0 ? i : 1;
      }
    }
    return 1;
  }

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

  // ── 本次经期开始日期 ──

  /// 查找本次经期的开始日期
  ///
  /// 从 [today] 往前搜索，找到第一个非 period 记录的下一天。
  static String? calcPeriodStartDate({
    required bool isInPeriod,
    required List<PeriodRecordVO> records,
    String? today,
  }) {
    if (!isInPeriod) return null;

    final now = today != null ? DateTime.parse(today) : DateTime.now();

    PeriodRecordVO? getRecord(String date) {
      try {
        return records.firstWhere((r) => r.recordDate == date);
      } catch (_) {
        return null;
      }
    }

    for (var i = 0; i < PeriodConstants.endPeriodSearchMaxDays; i++) {
      final d = now.subtract(Duration(days: i));
      final ds = _dateStr(d);
      final r = getRecord(ds);
      if (r == null || r.periodStatus != PeriodStatus.period) {
        return _dateStr(now.subtract(Duration(days: i > 0 ? i - 1 : 0)));
      }
    }
    return null;
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

  static String _dateStr(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
