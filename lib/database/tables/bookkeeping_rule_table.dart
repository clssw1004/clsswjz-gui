import 'dart:convert';

import 'package:drift/drift.dart';

import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 记账规则表
@DataClassName('BookkeepingRule')
class BookkeepingRuleTable extends BaseAccountBookTable {
  /// 规则名称
  TextColumn get name => text().named('name')();

  /// 启用开关
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();

  /// 优先级（数值越大约优先）
  IntColumn get priority =>
      integer().named('priority').withDefault(const Constant(0))();

  /// 树形递归条件 JSON
  TextColumn get conditionsJson => text().named('conditions_json')();

  /// 扁平操作 JSON
  TextColumn get actionsJson => text().named('actions_json')();

  /// 创建Companion
  static BookkeepingRuleTableCompanion toCreateCompanion(
    String who,
    String accountBookId, {
    required String name,
    bool isActive = true,
    int priority = 0,
    required String conditionsJson,
    required String actionsJson,
  }) {
    return BookkeepingRuleTableCompanion(
      id: Value(IdUtil.genId()),
      accountBookId: Value(accountBookId),
      name: Value(name),
      isActive: Value(isActive),
      priority: Value(priority),
      conditionsJson: Value(conditionsJson),
      actionsJson: Value(actionsJson),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 更新Companion
  static BookkeepingRuleTableCompanion toUpdateCompanion(
    String who, {
    String? name,
    bool? isActive,
    int? priority,
    String? conditionsJson,
    String? actionsJson,
  }) {
    return BookkeepingRuleTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      name: Value.absentIfNull(name),
      isActive: Value.absentIfNull(isActive),
      priority: Value.absentIfNull(priority),
      conditionsJson: Value.absentIfNull(conditionsJson),
      actionsJson: Value.absentIfNull(actionsJson),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
      accountBookId: const Value.absent(),
      id: const Value.absent(),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(BookkeepingRuleTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'name', companion.name);
    MapUtil.setIfPresent(map, 'isActive', companion.isActive);
    MapUtil.setIfPresent(map, 'priority', companion.priority);
    MapUtil.setIfPresent(map, 'conditionsJson', companion.conditionsJson);
    MapUtil.setIfPresent(map, 'actionsJson', companion.actionsJson);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    return jsonEncode(map);
  }

  /// 从JSON对象创建Companion（用于日志恢复）
  static BookkeepingRuleTableCompanion fromJson(Map<String, dynamic> json) {
    return BookkeepingRuleTableCompanion(
      id: json['id'] != null
          ? Value(json['id'] as String)
          : const Value.absent(),
      accountBookId: json['accountBookId'] != null
          ? Value(json['accountBookId'] as String)
          : const Value.absent(),
      name: json['name'] != null
          ? Value(json['name'] as String)
          : const Value.absent(),
      isActive: json['isActive'] != null
          ? Value(json['isActive'] as bool)
          : const Value.absent(),
      priority: json['priority'] != null
          ? Value(json['priority'] as int)
          : const Value.absent(),
      conditionsJson: json['conditionsJson'] != null
          ? Value(json['conditionsJson'] as String)
          : const Value.absent(),
      actionsJson: json['actionsJson'] != null
          ? Value(json['actionsJson'] as String)
          : const Value.absent(),
      createdBy: json['createdBy'] != null
          ? Value(json['createdBy'] as String)
          : const Value.absent(),
      updatedBy: json['updatedBy'] != null
          ? Value(json['updatedBy'] as String)
          : const Value.absent(),
      createdAt: json['createdAt'] != null
          ? Value(json['createdAt'] as int)
          : const Value.absent(),
      updatedAt: json['updatedAt'] != null
          ? Value(json['updatedAt'] as int)
          : const Value.absent(),
    );
  }
}
