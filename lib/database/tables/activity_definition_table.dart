import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 活动定义表
@DataClassName('ActivityDefinition')
class ActivityDefinitionTable extends BaseAccountBookTable {
  /// 活动名称
  TextColumn get name => text().named('name')();

  /// 活动图标
  TextColumn get emoji => text().named('emoji')();

  /// 活动颜色
  IntColumn get color => integer().named('color')();

  /// 排序序号
  IntColumn get sortOrder => integer().named('sort_order').withDefault(const Constant(0))();

  /// 创建Companion
  static ActivityDefinitionTableCompanion toCreateCompanion(
    String who, {
    required String accountBookId,
    required String name,
    required String emoji,
    required int color,
    int sortOrder = 0,
  }) {
    final now = DateUtil.now();
    return ActivityDefinitionTableCompanion(
      id: Value(IdUtil.genId()),
      accountBookId: Value(accountBookId),
      name: Value(name),
      emoji: Value(emoji),
      color: Value(color),
      sortOrder: Value(sortOrder),
      createdBy: Value(who),
      createdAt: Value(now),
      updatedBy: Value(who),
      updatedAt: Value(now),
    );
  }

  /// 更新Companion
  static ActivityDefinitionTableCompanion toUpdateCompanion(
    String who, {
    String? name,
    String? emoji,
    int? color,
    int? sortOrder,
  }) {
    return ActivityDefinitionTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      name: Value.absentIfNull(name),
      emoji: Value.absentIfNull(emoji),
      color: Value.absentIfNull(color),
      sortOrder: Value.absentIfNull(sortOrder),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(ActivityDefinitionTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'name', companion.name);
    MapUtil.setIfPresent(map, 'emoji', companion.emoji);
    MapUtil.setIfPresent(map, 'color', companion.color);
    MapUtil.setIfPresent(map, 'sortOrder', companion.sortOrder);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    return jsonEncode(map);
  }

  /// 从JSON对象创建Companion（用于日志恢复）
  static ActivityDefinitionTableCompanion fromJson(Map<String, dynamic> json) {
    return ActivityDefinitionTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      accountBookId: json['accountBookId'] != null ? Value(json['accountBookId'] as String) : const Value.absent(),
      name: json['name'] != null ? Value(json['name'] as String) : const Value.absent(),
      emoji: json['emoji'] != null ? Value(json['emoji'] as String) : const Value.absent(),
      color: json['color'] != null ? Value(json['color'] as int) : const Value.absent(),
      sortOrder: json['sortOrder'] != null ? Value(json['sortOrder'] as int) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
    );
  }
}
