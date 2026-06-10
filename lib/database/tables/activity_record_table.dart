import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 活动记录表
@DataClassName('ActivityRecord')
class ActivityRecordTable extends BaseAccountBookTable {
  /// 活动名称 (如：跑步、看书)
  TextColumn get activityName => text().named('activity_name')();

  /// 地点 (可选)
  TextColumn get location => text().named('location').nullable()();

  /// 活动日期 (yyyy-MM-dd)
  TextColumn get recordDate => text().named('record_date')();

  /// 关联的活动定义ID (可选)
  TextColumn get activityDefId => text().named('activity_def_id').nullable()();

  /// 每日最大打卡次数 (null=不限制)
  IntColumn get maxDailyCount => integer().named('max_daily_count').nullable()();

  /// 创建Companion
  static ActivityRecordTableCompanion toCreateCompanion(
    String who, {
    required String accountBookId,
    required String activityName,
    required String recordDate,
    String? activityDefId,
    String? location,
    int? createdAt,
    int? maxDailyCount,
  }) {
    final now = createdAt ?? DateUtil.now();
    return ActivityRecordTableCompanion(
      id: Value(IdUtil.genId()),
      accountBookId: Value(accountBookId),
      activityName: Value(activityName),
      recordDate: Value(recordDate),
      activityDefId: Value.absentIfNull(activityDefId),
      location: Value.absentIfNull(location),
      maxDailyCount: Value.absentIfNull(maxDailyCount),
      createdBy: Value(who),
      createdAt: Value(now),
      updatedBy: Value(who),
      updatedAt: Value(now),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(ActivityRecordTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'activityName', companion.activityName);
    MapUtil.setIfPresent(map, 'recordDate', companion.recordDate);
    MapUtil.setIfPresent(map, 'activityDefId', companion.activityDefId);
    MapUtil.setIfPresent(map, 'location', companion.location);
    MapUtil.setIfPresent(map, 'maxDailyCount', companion.maxDailyCount);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    return jsonEncode(map);
  }

  /// 从JSON对象创建Companion（用于日志恢复）
  static ActivityRecordTableCompanion fromJson(Map<String, dynamic> json) {
    return ActivityRecordTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      accountBookId: json['accountBookId'] != null ? Value(json['accountBookId'] as String) : const Value.absent(),
      activityName: json['activityName'] != null ? Value(json['activityName'] as String) : const Value.absent(),
      recordDate: json['recordDate'] != null ? Value(json['recordDate'] as String) : const Value.absent(),
      activityDefId: json['activityDefId'] != null ? Value(json['activityDefId'] as String) : const Value.absent(),
      location: json['location'] != null ? Value(json['location'] as String) : const Value.absent(),
      maxDailyCount: json['maxDailyCount'] != null ? Value(json['maxDailyCount'] as int) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
    );
  }
}
