import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 经期日记录表
///
/// ⚠️ 已废弃，请使用 PeriodCycleTable + PeriodDailyRecordTable 替代。
@Deprecated('使用 PeriodCycleTable + PeriodDailyRecordTable 替代')
@DataClassName('PeriodRecord')
class PeriodRecordTable extends BaseBusinessTable {
  /// 记录日期 (yyyy-MM-dd，同一用户唯一)
  TextColumn get recordDate => text().named('record_date').withLength(min: 10, max: 10)();

  /// 经期状态: none(非经期), period(经期), spotting(少量出血)
  TextColumn get periodStatus =>
      text().named('period_status').withDefault(const Constant('none'))();

  /// 流量: none, light, medium, heavy
  TextColumn get flowLevel =>
      text().named('flow_level').withDefault(const Constant('none'))();

  /// 症状标签 JSON 数组，如 ["headache","cramps","bloating"]
  TextColumn get symptoms =>
      text().named('symptoms').withDefault(const Constant('[]'))();

  /// 情绪: good, normal, bad, terrible
  TextColumn get mood => text().named('mood').withDefault(const Constant('normal'))();

  /// 备注
  TextColumn get remark => text().nullable().named('remark')();

  /// 创建Companion
  static PeriodRecordTableCompanion toCreateCompanion(
    String who, {
    required String recordDate,
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodRecordTableCompanion(
      id: Value(IdUtil.genId()),
      recordDate: Value(recordDate),
      periodStatus: Value(periodStatus ?? 'none'),
      flowLevel: Value(flowLevel ?? 'none'),
      symptoms: Value(jsonEncode(symptoms ?? [])),
      mood: Value(mood ?? 'normal'),
      remark: Value.absentIfNull(remark),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 更新Companion
  static PeriodRecordTableCompanion toUpdateCompanion(
    String who, {
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodRecordTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      periodStatus: Value.absentIfNull(periodStatus),
      flowLevel: Value.absentIfNull(flowLevel),
      symptoms: symptoms != null ? Value(jsonEncode(symptoms)) : const Value.absent(),
      mood: Value.absentIfNull(mood),
      remark: Value.absentIfNull(remark),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
      id: const Value.absent(),
      recordDate: const Value.absent(),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(PeriodRecordTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'recordDate', companion.recordDate);
    MapUtil.setIfPresent(map, 'periodStatus', companion.periodStatus);
    MapUtil.setIfPresent(map, 'flowLevel', companion.flowLevel);
    MapUtil.setIfPresent(map, 'symptoms', companion.symptoms);
    MapUtil.setIfPresent(map, 'mood', companion.mood);
    MapUtil.setIfPresent(map, 'remark', companion.remark);
    return jsonEncode(map);
  }

  /// 从JSON对象创建Companion（用于日志恢复）
  static PeriodRecordTableCompanion fromJson(Map<String, dynamic> json) {
    return PeriodRecordTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      recordDate: json['recordDate'] != null ? Value(json['recordDate'] as String) : const Value.absent(),
      periodStatus: json['periodStatus'] != null ? Value(json['periodStatus'] as String) : const Value.absent(),
      flowLevel: json['flowLevel'] != null ? Value(json['flowLevel'] as String) : const Value.absent(),
      symptoms: json['symptoms'] != null ? Value(json['symptoms'] as String) : const Value.absent(),
      mood: json['mood'] != null ? Value(json['mood'] as String) : const Value.absent(),
      remark: json['remark'] != null ? Value(json['remark'] as String) : const Value.absent(),
    );
  }
}
