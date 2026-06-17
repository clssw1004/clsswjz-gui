import 'dart:convert';

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
    } else if (operateType == OperateType.update) {
      await DaoManager.activityRecordDao.update(businessId!, data!);
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
          .withData(ActivityRecordTable.fromJson(jsonDecode(log.operateData))) as ActivityRecordCULog;
    } else if (operateType == OperateType.update) {
      return ActivityRecordCULog()
          .who(log.operatorId)
          .inBook(log.parentId)
          .target(log.businessId)
          .doUpdate()
          .withData(ActivityRecordTable.fromJson(jsonDecode(log.operateData))) as ActivityRecordCULog;
    }
    return ActivityRecordCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .target(log.businessId)
        .doDelete() as ActivityRecordCULog;
  }

  /// 创建
  static ActivityRecordCULog create({
    required String who,
    required String bookId,
    required String activityName,
    required String recordDate,
    String? activityDefId,
    String? location,
    int? createdAt,
    int? maxDailyCount,
    String? remark,
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
          activityDefId: activityDefId,
          location: location,
          createdAt: createdAt,
          maxDailyCount: maxDailyCount,
          remark: remark,
        )) as ActivityRecordCULog;
  }

  /// 更新记录（改时间/备注/地点）
  static ActivityRecordCULog update({
    required String who,
    required String id,
    int? createdAt,
    String? location,
    String? remark,
  }) {
    return ActivityRecordCULog()
        .who(who)
        .target(id)
        .doUpdate()
        .withData(ActivityRecordTable.toUpdateCompanion(
          who,
          createdAt: createdAt,
          location: location,
          remark: remark,
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
}
