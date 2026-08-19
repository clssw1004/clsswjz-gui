class PeriodStatisticsVO {
  final int averageCycleLength;
  final int averagePeriodLength;
  final int totalRecords;
  final List<int> recentCycleLengths;
  final String? lastPeriodStart;
  final String? nextPeriodDate;
  final String? ovulationDate;
  final String? fertileWindowStart;
  final String? fertileWindowEnd;

  /// 用户配置的典型周期天数（单周期时用于预测）
  final int? typicalCycleDays;

  /// 用户配置的典型经期天数
  final int? typicalPeriodDays;

  const PeriodStatisticsVO({
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.totalRecords,
    required this.recentCycleLengths,
    this.lastPeriodStart,
    this.nextPeriodDate,
    this.ovulationDate,
    this.fertileWindowStart,
    this.fertileWindowEnd,
    this.typicalCycleDays,
    this.typicalPeriodDays,
  });

  /// 是否可预测：有足够历史周期，或用户配置了典型周期天数
  bool get canPredict =>
      recentCycleLengths.isNotEmpty || typicalCycleDays != null;

  static const empty = PeriodStatisticsVO(
    averageCycleLength: 0,
    averagePeriodLength: 0,
    totalRecords: 0,
    recentCycleLengths: [],
  );
}
