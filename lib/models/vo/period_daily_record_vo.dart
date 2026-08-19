import 'dart:convert';
import '../../database/database.dart';
import '../../enums/flow_level.dart';
import '../../enums/period_mood.dart';

/// 经期每日明细 VO
class PeriodDailyRecordVO {
  final String id;
  final String cycleId;
  final String recordDate;
  final FlowLevel flowLevel;
  final List<String> symptoms;
  final PeriodMood mood;
  final String? remark;
  final int createdAt;
  final int updatedAt;

  const PeriodDailyRecordVO({
    required this.id,
    required this.cycleId,
    required this.recordDate,
    required this.flowLevel,
    required this.symptoms,
    this.mood = PeriodMood.normal,
    this.remark,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PeriodDailyRecordVO.fromPeriodDailyRecord(PeriodDailyRecord record) {
    return PeriodDailyRecordVO(
      id: record.id,
      cycleId: record.cycleId,
      recordDate: record.recordDate,
      flowLevel: FlowLevel.fromCode(record.flowLevel),
      symptoms: List<String>.from(jsonDecode(record.symptoms)),
      mood: PeriodMood.fromCode(record.mood),
      remark: record.remark,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
