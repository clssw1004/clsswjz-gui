import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 礼物卡表
@DataClassName('GiftCard')
class GiftCardTable extends BaseBusinessTable {
  /// 赠送人用户ID
  TextColumn get fromUserId => text().named('from_user_id').withLength(min: 1, max: 64)();

  /// 接收人用户ID
  TextColumn get toUserId => text().named('to_user_id').withLength(min: 1, max: 64)();

  /// 礼品描述
  TextColumn get description => text().nullable().named('gift_description')();

  /// 过期时间 (毫秒时间戳，0表示永久有效)
  IntColumn get expiredTime => integer().named('expired_time').withDefault(const Constant(0))();

  /// 送出时间 (毫秒时间戳)
  IntColumn get sentTime => integer().named('sent_time').withDefault(const Constant(0))();

  /// 接收时间 (毫秒时间戳)
  IntColumn get receivedTime => integer().named('received_time').withDefault(const Constant(0))();

  /// 状态: draft(草稿), sent(已送出), received(已接收), used(已使用), expired(已过期), voided(已作废)
  TextColumn get status =>
      text().named('status').withDefault(const Constant('draft'))();

  /// 创建更新Companion
  static GiftCardTableCompanion toUpdateCompanion(
    String who, {
    String? fromUserId,
    String? toUserId,
    String? description,
    int? expiredTime,
    int? sentTime,
    int? receivedTime,
    String? status,
  }) {
    return GiftCardTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      fromUserId: Value.absentIfNull(fromUserId),
      toUserId: Value.absentIfNull(toUserId),
      description: Value.absentIfNull(description),
      expiredTime: Value.absentIfNull(expiredTime),
      sentTime: Value.absentIfNull(sentTime),
      receivedTime: Value.absentIfNull(receivedTime),
      status: Value.absentIfNull(status),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
      id: const Value.absent(),
    );
  }

  /// 创建Companion
  static GiftCardTableCompanion toCreateCompanion(
    String who, {
    required String fromUserId,
    required String toUserId,
    String? description,
    int? expiredTime,
  }) {
    return GiftCardTableCompanion(
      id: Value(IdUtil.genId()),
      fromUserId: Value(fromUserId),
      toUserId: Value(toUserId),
      description: Value.absentIfNull(description),
      expiredTime: Value.absentIfNull(expiredTime),
      sentTime: const Value(0),
      receivedTime: const Value(0),
      status: const Value('draft'),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(GiftCardTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'fromUserId', companion.fromUserId);
    MapUtil.setIfPresent(map, 'toUserId', companion.toUserId);
    MapUtil.setIfPresent(map, 'description', companion.description);
    MapUtil.setIfPresent(map, 'expiredTime', companion.expiredTime);
    MapUtil.setIfPresent(map, 'sentTime', companion.sentTime);
    MapUtil.setIfPresent(map, 'receivedTime', companion.receivedTime);
    MapUtil.setIfPresent(map, 'status', companion.status);
    return jsonEncode(map);
  }

  /// 从JSON对象创建Companion（用于日志恢复）
  static GiftCardTableCompanion fromJson(Map<String, dynamic> json) {
    return GiftCardTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      fromUserId: json['fromUserId'] != null ? Value(json['fromUserId'] as String) : const Value.absent(),
      toUserId: json['toUserId'] != null ? Value(json['toUserId'] as String) : const Value.absent(),
      description: json['description'] != null ? Value(json['description'] as String) : const Value.absent(),
      expiredTime: json['expiredTime'] != null ? Value(json['expiredTime'] as int) : const Value.absent(),
      sentTime: json['sentTime'] != null ? Value(json['sentTime'] as int) : const Value.absent(),
      receivedTime: json['receivedTime'] != null ? Value(json['receivedTime'] as int) : const Value.absent(),
      status: json['status'] != null ? Value(json['status'] as String) : const Value.absent(),
    );
  }
}