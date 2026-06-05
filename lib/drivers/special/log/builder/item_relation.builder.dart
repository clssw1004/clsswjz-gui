import 'dart:convert';

import 'package:drift/drift.dart';
import '../../../../database/database.dart';
import '../../../../database/tables/item_relation_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class ItemRelationCULog extends LogBuilder<ItemRelationTableCompanion, String> {
  ItemRelationCULog() : super() {
    doWith(BusinessType.itemRelation);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.itemRelationDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.delete) {
      await DaoManager.itemRelationDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return ItemRelationTable.toJsonString(data as ItemRelationTableCompanion);
  }

  static ItemRelationCULog create(String who, {
    required String itemId,
    required String accountBookId,
    required String relationCode,
    required String relationId,
  }) {
    return ItemRelationCULog()
        .who(who)
        .inBook(accountBookId)
        .doCreate()
        .withData(ItemRelationTable.toCreateCompanion(
          who,
          itemId: itemId,
          accountBookId: accountBookId,
          relationCode: relationCode,
          relationId: relationId,
        )) as ItemRelationCULog;
  }

  static ItemRelationCULog delete(String who, String relationId) {
    return ItemRelationCULog()
        .who(who)
        .target(relationId)
        .doDelete() as ItemRelationCULog;
  }

  static ItemRelationCULog fromCreateLog(LogSync log) {
    final data = jsonDecode(log.operateData);
    return ItemRelationCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(data)) as ItemRelationCULog;
  }

  static ItemRelationCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => ItemRelationCULog.fromCreateLog(log),
      _ => ItemRelationCULog()
          .who(log.operatorId)
          .target(log.businessId)
          .doDelete() as ItemRelationCULog,
    };
  }

  static ItemRelationTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return ItemRelationTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      itemId: json['itemId'] != null ? Value(json['itemId'] as String) : const Value.absent(),
      accountBookId: json['accountBookId'] != null ? Value(json['accountBookId'] as String) : const Value.absent(),
      relationCode: json['relationCode'] != null ? Value(json['relationCode'] as String) : const Value.absent(),
      relationId: json['relationId'] != null ? Value(json['relationId'] as String) : const Value.absent(),
    );
  }
}
