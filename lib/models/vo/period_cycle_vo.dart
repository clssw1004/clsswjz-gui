import '../../database/database.dart';

/// 经期周期 VO
class PeriodCycleVO {
  final String id;
  final String startDate;
  final String? endDate;
  final int? typicalPeriodDays;
  final int? typicalCycleDays;
  final int createdAt;
  final int updatedAt;

  const PeriodCycleVO({
    required this.id,
    required this.startDate,
    this.endDate,
    this.typicalPeriodDays,
    this.typicalCycleDays,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 是否为未结束的周期
  bool get isActive => endDate == null;

  /// 经期天数（仅已结束的周期有效）
  int? get periodDays {
    if (endDate == null) return null;
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate!);
    return end.difference(start).inDays + 1;
  }

  factory PeriodCycleVO.fromPeriodCycle(PeriodCycle record) {
    return PeriodCycleVO(
      id: record.id,
      startDate: record.startDate,
      endDate: record.endDate,
      typicalPeriodDays: record.typicalPeriodDays,
      typicalCycleDays: record.typicalCycleDays,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
