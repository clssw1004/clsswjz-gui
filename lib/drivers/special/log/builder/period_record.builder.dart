import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/period_record_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

/// 经期记录日志构建器
class PeriodRecordCULog extends LogBuilder<PeriodRecordTableCompanion, String> {
  PeriodRecordCULog() : super() {
    doWith(BusinessType.periodRecord);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.periodRecordDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.periodRecordDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.periodRecordDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return PeriodRecordTable.toJsonString(data as PeriodRecordTableCompanion);
  }

  /// 从创建日志恢复
  static PeriodRecordCULog fromCreateLog(LogSync log) {
    return PeriodRecordCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as PeriodRecordCULog;
  }

  /// 从更新日志恢复
  static PeriodRecordCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return PeriodRecordCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doUpdate()
        .withData(PeriodRecordTable.toUpdateCompanion(
          log.operatorId,
          periodStatus: data['periodStatus'] as String?,
          flowLevel: data['flowLevel'] as String?,
          symptoms: data['symptoms'] != null
              ? List<String>.from(jsonDecode(data['symptoms'] as String))
              : null,
          mood: data['mood'] as String?,
          remark: data['remark'] as String?,
        )) as PeriodRecordCULog;
  }

  /// 从日志恢复
  static PeriodRecordCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => PeriodRecordCULog.fromCreateLog(log),
      OperateType.update => PeriodRecordCULog.fromUpdateLog(log),
      _ => throw ArgumentError('PeriodRecordCULog does not support ${log.operateType}'),
    };
  }

  /// 创建经期记录
  static PeriodRecordCULog create({
    required String who,
    required String recordDate,
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodRecordCULog()
        .who(who)
        .doCreate()
        .noParent()
        .withData(PeriodRecordTable.toCreateCompanion(
          who,
          recordDate: recordDate,
          periodStatus: periodStatus,
          flowLevel: flowLevel,
          symptoms: symptoms,
          mood: mood,
          remark: remark,
        )) as PeriodRecordCULog;
  }

  /// 更新经期记录
  static PeriodRecordCULog update({
    required String who,
    required String id,
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodRecordCULog()
        .who(who)
        .doUpdate()
        .noParent()
        .target(id)
        .withData(PeriodRecordTable.toUpdateCompanion(
          who,
          periodStatus: periodStatus,
          flowLevel: flowLevel,
          symptoms: symptoms,
          mood: mood,
          remark: remark,
        )) as PeriodRecordCULog;
  }

  /// 删除经期记录
  static PeriodRecordCULog delete({
    required String who,
    required String id,
  }) {
    return PeriodRecordCULog()
        .who(who)
        .doDelete()
        .noParent()
        .target(id) as PeriodRecordCULog;
  }

  /// 解析JSON为Companion
  static PeriodRecordTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return PeriodRecordTable.fromJson(json);
  }
}
