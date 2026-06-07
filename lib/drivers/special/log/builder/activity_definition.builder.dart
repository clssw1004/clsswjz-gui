import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../database/database.dart';
import '../../../../database/tables/activity_definition_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class ActivityDefinitionCULog extends LogBuilder<ActivityDefinitionTableCompanion, String> {
  ActivityDefinitionCULog() : super() {
    doWith(BusinessType.activityDefinition);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.activityDefinitionDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.activityDefinitionDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.activityDefinitionDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return ActivityDefinitionTable.toJsonString(data as ActivityDefinitionTableCompanion);
  }

  static ActivityDefinitionCULog create({
    required String who,
    required String bookId,
    required String name,
    required String emoji,
    required int color,
    int sortOrder = 0,
  }) {
    return ActivityDefinitionCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(ActivityDefinitionTable.toCreateCompanion(
          who,
          accountBookId: bookId,
          name: name,
          emoji: emoji,
          color: color,
          sortOrder: sortOrder,
        )) as ActivityDefinitionCULog;
  }

  static ActivityDefinitionCULog update({
    required String who,
    required String id,
    String? name,
    String? emoji,
    int? color,
    int? sortOrder,
  }) {
    return ActivityDefinitionCULog()
        .who(who)
        .target(id)
        .doUpdate()
        .withData(ActivityDefinitionTable.toUpdateCompanion(
          who,
          name: name,
          emoji: emoji,
          color: color,
          sortOrder: sortOrder,
        )) as ActivityDefinitionCULog;
  }

  static ActivityDefinitionCULog delete({
    required String who,
    required String id,
  }) {
    return ActivityDefinitionCULog()
        .who(who)
        .target(id)
        .doDelete() as ActivityDefinitionCULog;
  }

  static ActivityDefinitionCULog fromLog(LogSync log) {
    final operateType = OperateType.fromCode(log.operateType);
    if (operateType == OperateType.create) {
      return ActivityDefinitionCULog()
          .who(log.operatorId)
          .inBook(log.parentId)
          .target(log.businessId)
          .doCreate()
          .withData(_parseCompanion(jsonDecode(log.operateData))) as ActivityDefinitionCULog;
    } else if (operateType == OperateType.update) {
      Map<String, dynamic> data = jsonDecode(log.operateData);
      return ActivityDefinitionCULog()
          .who(log.operatorId)
          .target(log.businessId)
          .doUpdate()
          .withData(ActivityDefinitionTable.toUpdateCompanion(
            log.operatorId,
            name: data['name'] as String?,
            emoji: data['emoji'] as String?,
            color: data['color'] as int?,
            sortOrder: data['sortOrder'] as int?,
          )) as ActivityDefinitionCULog;
    }
    return ActivityDefinitionCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doDelete() as ActivityDefinitionCULog;
  }

  static ActivityDefinitionTableCompanion _parseCompanion(Map<String, dynamic> json) {
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
