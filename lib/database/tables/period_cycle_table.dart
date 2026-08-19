import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 经期周期表
///
/// 一个周期一条记录，决定经期范围（startDate → endDate）。
/// endDate 为 null 表示经期未结束。
@DataClassName('PeriodCycle')
class PeriodCycleTable extends BaseBusinessTable {
  /// 经期开始日 (yyyy-MM-dd，同一用户唯一)
  TextColumn get startDate => text().named('start_date')();

  /// 经期结束日 (yyyy-MM-dd，null = 未结束)
  TextColumn get endDate => text().nullable().named('end_date')();

  /// 用户配置的典型经期持续天数（可选，用于单周期预测）
  IntColumn get typicalPeriodDays =>
      integer().nullable().named('typical_period_days')();

  /// 用户配置的典型周期间隔天数（可选，用于单周期预测）
  IntColumn get typicalCycleDays =>
      integer().nullable().named('typical_cycle_days')();

  @override
  List<Set<Column>> get uniqueKeys => [{createdBy, startDate}];

  /// 创建 Companion
  static PeriodCycleTableCompanion toCreateCompanion(
    String who, {
    required String startDate,
    String? endDate,
    int? typicalPeriodDays,
    int? typicalCycleDays,
  }) {
    return PeriodCycleTableCompanion(
      id: Value(IdUtil.genId()),
      startDate: Value(startDate),
      endDate: Value.absentIfNull(endDate),
      typicalPeriodDays: Value.absentIfNull(typicalPeriodDays),
      typicalCycleDays: Value.absentIfNull(typicalCycleDays),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 更新 Companion（仅更新 endDate 和典型天数）
  static PeriodCycleTableCompanion toUpdateCompanion(
    String who, {
    String? endDate,
    int? typicalPeriodDays,
    int? typicalCycleDays,
  }) {
    return PeriodCycleTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      endDate: Value.absentIfNull(endDate),
      typicalPeriodDays: Value.absentIfNull(typicalPeriodDays),
      typicalCycleDays: Value.absentIfNull(typicalCycleDays),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
      id: const Value.absent(),
      startDate: const Value.absent(),
    );
  }

  /// 转换为 JSON 字符串（用于日志同步）
  static String toJsonString(PeriodCycleTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'startDate', companion.startDate);
    MapUtil.setIfPresent(map, 'endDate', companion.endDate);
    MapUtil.setIfPresent(map, 'typicalPeriodDays', companion.typicalPeriodDays);
    MapUtil.setIfPresent(map, 'typicalCycleDays', companion.typicalCycleDays);
    return jsonEncode(map);
  }

  /// 从 JSON 对象创建 Companion（用于日志恢复）
  static PeriodCycleTableCompanion fromJson(Map<String, dynamic> json) {
    return PeriodCycleTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      startDate: json['startDate'] != null ? Value(json['startDate'] as String) : const Value.absent(),
      endDate: json['endDate'] != null ? Value(json['endDate'] as String) : const Value.absent(),
      typicalPeriodDays: json['typicalPeriodDays'] != null ? Value(json['typicalPeriodDays'] as int) : const Value.absent(),
      typicalCycleDays: json['typicalCycleDays'] != null ? Value(json['typicalCycleDays'] as int) : const Value.absent(),
    );
  }
}
