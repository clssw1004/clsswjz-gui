import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../database/database.dart';
import '../../../../database/tables/activity_record_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class ActivityRecordCULog extends LogBuilder<ActivityRecordTableCompanion, String> {
  ActivityRecordCULog() : super() {
    doWith(BusinessType.activity);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.activityRecordDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.delete) {
      await DaoManager.activityRecordDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return ActivityRecordTable.toJsonString(data as ActivityRecordTableCompanion);
  }

  /// 从日志恢复
  static ActivityRecordCULog fromLog(LogSync log) {
    final operateType = OperateType.fromCode(log.operateType);
    if (operateType == OperateType.create) {
      return ActivityRecordCULog()
          .who(log.operatorId)
          .inBook(log.parentId)
          .target(log.businessId)
          .doCreate()
          .withData(_parseCompanion(jsonDecode(log.operateData))) as ActivityRecordCULog;
    }
    return ActivityRecordCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doDelete() as ActivityRecordCULog;
  }

  /// 创建
  static ActivityRecordCULog create({
    required String who,
    required String bookId,
    required String activityName,
    required String recordDate,
    String? location,
    int? createdAt,
  }) {
    return ActivityRecordCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(ActivityRecordTable.toCreateCompanion(
          who,
          accountBookId: bookId,
          activityName: activityName,
          recordDate: recordDate,
          location: location,
          createdAt: createdAt,
        )) as ActivityRecordCULog;
  }

  /// 删除
  static ActivityRecordCULog delete({
    required String who,
    required String bookId,
    required String id,
  }) {
    return ActivityRecordCULog()
        .who(who)
        .inBook(bookId)
        .target(id)
        .doDelete() as ActivityRecordCULog;
  }

  /// 解析JSON为Companion
  static ActivityRecordTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return ActivityRecordTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      accountBookId: json['accountBookId'] != null ? Value(json['accountBookId'] as String) : const Value.absent(),
      activityName: json['activityName'] != null ? Value(json['activityName'] as String) : const Value.absent(),
      recordDate: json['recordDate'] != null ? Value(json['recordDate'] as String) : const Value.absent(),
      location: json['location'] != null ? Value(json['location'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
    );
  }
}
