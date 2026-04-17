import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../database/database.dart';
import '../../../../database/tables/gift_card_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

/// 礼物卡日志构建器
class GiftCardCULog extends LogBuilder<GiftCardTableCompanion, String> {
  GiftCardCULog() : super() {
    doWith(BusinessType.giftCard);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.giftCardDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.giftCardDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.giftCardDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return GiftCardTable.toJsonString(data as GiftCardTableCompanion);
  }

  /// 从创建日志恢复
  static GiftCardCULog fromCreateLog(LogSync log) {
    return GiftCardCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as GiftCardCULog;
  }

  /// 从更新日志恢复
  static GiftCardCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return GiftCardCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doUpdate()
        .withData(GiftCardTable.toUpdateCompanion(
          log.operatorId,
          fromUserId: data['fromUserId'] as String?,
          toUserId: data['toUserId'] as String?,
          description: data['description'] as String?,
          expiredTime: data['expiredTime'] as int?,
          sentTime: data['sentTime'] as int?,
          receivedTime: data['receivedTime'] as int?,
          status: data['status'] as String?,
        )) as GiftCardCULog;
  }

  /// 从日志恢复
  static GiftCardCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => GiftCardCULog.fromCreateLog(log),
      OperateType.update => GiftCardCULog.fromUpdateLog(log),
      _ => GiftCardCULog.fromUpdateLog(log),
    };
  }

  /// 创建礼物卡
  static GiftCardCULog create({
    required String who,
    required String fromUserId,
    required String toUserId,
    String? description,
    int? expiredTime,
  }) {
    return GiftCardCULog()
        .who(who)
        .doCreate()
        .noParent()
        .withData(GiftCardTable.toCreateCompanion(
          who,
          fromUserId: fromUserId,
          toUserId: toUserId,
          description: description,
          expiredTime: expiredTime,
        )) as GiftCardCULog;
  }

  /// 更新礼物卡
  static GiftCardCULog update({
    required String who,
    required String id,
    String? toUserId,
    String? description,
    int? expiredTime,
    int? sentTime,
    int? receivedTime,
    String? status,
  }) {
    return GiftCardCULog()
        .who(who)
        .doUpdate()
        .noParent()
        .target(id)
        .withData(GiftCardTable.toUpdateCompanion(
          who,
          toUserId: toUserId,
          description: description,
          expiredTime: expiredTime,
          sentTime: sentTime,
          receivedTime: receivedTime,
          status: status,
        )) as GiftCardCULog;
  }

  /// 删除礼物卡
  static GiftCardCULog delete({
    required String who,
    required String id,
  }) {
    return GiftCardCULog()
        .who(who)
        .doDelete()
        .noParent()
        .target(id) as GiftCardCULog;
  }

  /// 解析JSON为Companion
  static GiftCardTableCompanion _parseCompanion(Map<String, dynamic> json) {
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