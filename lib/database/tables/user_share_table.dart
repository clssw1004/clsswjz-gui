import 'dart:convert';
import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 用户模块共享关系表
@DataClassName('UserShare')
class UserShareTable extends BaseTable {
  TextColumn get ownerUserId => text().named('owner_user_id')();
  TextColumn get targetUserId => text().named('target_user_id')();
  TextColumn get businessType => text().named('business_type')();
  BoolColumn get isEnabled =>
      boolean().named('is_enabled').withDefault(const Constant(true))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {ownerUserId, targetUserId, businessType},
      ];

  static UserShareTableCompanion toCreateCompanion({
    required String ownerUserId,
    required String targetUserId,
    required String businessType,
    bool isEnabled = true,
  }) {
    return UserShareTableCompanion(
      id: Value(IdUtil.genId()),
      ownerUserId: Value(ownerUserId),
      targetUserId: Value(targetUserId),
      businessType: Value(businessType),
      isEnabled: Value(isEnabled),
      createdAt: Value(DateUtil.now()),
      updatedAt: Value(DateUtil.now()),
    );
  }

  static UserShareTableCompanion toUpdateCompanion({bool? isEnabled}) {
    return UserShareTableCompanion(
      updatedAt: Value(DateUtil.now()),
      isEnabled: Value.absentIfNull(isEnabled),
    );
  }

  static String toJsonString(UserShareTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'ownerUserId', companion.ownerUserId);
    MapUtil.setIfPresent(map, 'targetUserId', companion.targetUserId);
    MapUtil.setIfPresent(map, 'businessType', companion.businessType);
    MapUtil.setIfPresent(map, 'isEnabled', companion.isEnabled);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    return jsonEncode(map);
  }

  static UserShareTableCompanion fromJson(Map<String, dynamic> json) {
    return UserShareTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      ownerUserId: json['ownerUserId'] != null ? Value(json['ownerUserId'] as String) : const Value.absent(),
      targetUserId: json['targetUserId'] != null ? Value(json['targetUserId'] as String) : const Value.absent(),
      businessType: json['businessType'] != null ? Value(json['businessType'] as String) : const Value.absent(),
      isEnabled: json['isEnabled'] != null ? Value(json['isEnabled'] as bool) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
    );
  }
}
