import 'dart:convert';
import '../../database/database.dart';
import '../../enums/flow_level.dart';
import '../../enums/period_status.dart';

class PeriodRecordVO {
  final String id;
  final String recordDate;
  final PeriodStatus periodStatus;
  final FlowLevel flowLevel;
  final List<String> symptoms;
  final String? mood;
  final String? remark;
  final int createdAt;
  final int updatedAt;

  const PeriodRecordVO({
    required this.id,
    required this.recordDate,
    required this.periodStatus,
    required this.flowLevel,
    required this.symptoms,
    this.mood,
    this.remark,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PeriodRecordVO.fromPeriodRecord(PeriodRecord record) {
    return PeriodRecordVO(
      id: record.id,
      recordDate: record.recordDate,
      periodStatus: PeriodStatus.fromCode(record.periodStatus),
      flowLevel: FlowLevel.fromCode(record.flowLevel),
      symptoms: List<String>.from(jsonDecode(record.symptoms)),
      mood: record.mood,
      remark: record.remark,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
