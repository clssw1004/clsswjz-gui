import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 经期每日明细表
///
/// 可选的细节记录，用户主动记录才有，没有也不影响经期判断。
/// 关联到 period_cycle_table 的 cycleId。
@DataClassName('PeriodDailyRecord')
class PeriodDailyRecordTable extends BaseBusinessTable {
  /// 关联周期 ID
  TextColumn get cycleId => text().named('cycle_id')();

  /// 记录日期 (yyyy-MM-dd，同一周期内唯一)
  TextColumn get recordDate => text().named('record_date')();

  /// 流量: none, light, medium, heavy
  TextColumn get flowLevel =>
      text().named('flow_level').withDefault(const Constant('none'))();

  /// 症状标签 JSON 数组，如 ["headache","cramps","bloating"]
  TextColumn get symptoms =>
      text().named('symptoms').withDefault(const Constant('[]'))();

  /// 情绪: good, normal, bad, terrible
  TextColumn get mood =>
      text().named('mood').withDefault(const Constant('normal'))();

  /// 备注
  TextColumn get remark => text().nullable().named('remark')();

  @override
  List<Set<Column>> get uniqueKeys => [{cycleId, recordDate}];

  /// 创建 Companion
  static PeriodDailyRecordTableCompanion toCreateCompanion(
    String who, {
    required String cycleId,
    required String recordDate,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodDailyRecordTableCompanion(
      id: Value(IdUtil.genId()),
      cycleId: Value(cycleId),
      recordDate: Value(recordDate),
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

  /// 更新 Companion
  static PeriodDailyRecordTableCompanion toUpdateCompanion(
    String who, {
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodDailyRecordTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      flowLevel: Value.absentIfNull(flowLevel),
      symptoms: symptoms != null ? Value(jsonEncode(symptoms)) : const Value.absent(),
      mood: Value.absentIfNull(mood),
      remark: Value.absentIfNull(remark),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
      id: const Value.absent(),
      cycleId: const Value.absent(),
      recordDate: const Value.absent(),
    );
  }

  /// 转换为 JSON 字符串（用于日志同步）
  static String toJsonString(PeriodDailyRecordTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'cycleId', companion.cycleId);
    MapUtil.setIfPresent(map, 'recordDate', companion.recordDate);
    MapUtil.setIfPresent(map, 'flowLevel', companion.flowLevel);
    MapUtil.setIfPresent(map, 'symptoms', companion.symptoms);
    MapUtil.setIfPresent(map, 'mood', companion.mood);
    MapUtil.setIfPresent(map, 'remark', companion.remark);
    return jsonEncode(map);
  }

  /// 从 JSON 对象创建 Companion（用于日志恢复）
  static PeriodDailyRecordTableCompanion fromJson(Map<String, dynamic> json) {
    return PeriodDailyRecordTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      cycleId: json['cycleId'] != null ? Value(json['cycleId'] as String) : const Value.absent(),
      recordDate: json['recordDate'] != null ? Value(json['recordDate'] as String) : const Value.absent(),
      flowLevel: json['flowLevel'] != null ? Value(json['flowLevel'] as String) : const Value.absent(),
      symptoms: json['symptoms'] != null ? Value(json['symptoms'] as String) : const Value.absent(),
      mood: json['mood'] != null ? Value(json['mood'] as String) : const Value.absent(),
      remark: json['remark'] != null ? Value(json['remark'] as String) : const Value.absent(),
    );
  }
}
