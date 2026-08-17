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
  });

  bool get canPredict => recentCycleLengths.length >= 2;

  static const empty = PeriodStatisticsVO(
    averageCycleLength: 0,
    averagePeriodLength: 0,
    totalRecords: 0,
    recentCycleLengths: [],
  );
}
