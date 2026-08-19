import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/period_daily_record_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

/// 经期每日明细日志构建器
class PeriodDailyRecordCULog extends LogBuilder<PeriodDailyRecordTableCompanion, String> {
  PeriodDailyRecordCULog() : super() {
    doWith(BusinessType.periodDailyRecord);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.periodDailyRecordDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.periodDailyRecordDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.periodDailyRecordDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return PeriodDailyRecordTable.toJsonString(data as PeriodDailyRecordTableCompanion);
  }

  /// 从创建日志恢复
  static PeriodDailyRecordCULog fromCreateLog(LogSync log) {
    return PeriodDailyRecordCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as PeriodDailyRecordCULog;
  }

  /// 从更新日志恢复
  static PeriodDailyRecordCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return PeriodDailyRecordCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doUpdate()
        .withData(PeriodDailyRecordTable.toUpdateCompanion(
          log.operatorId,
          flowLevel: data['flowLevel'] as String?,
          symptoms: data['symptoms'] != null
              ? List<String>.from(jsonDecode(data['symptoms'] as String))
              : null,
          mood: data['mood'] as String?,
          remark: data['remark'] as String?,
        )) as PeriodDailyRecordCULog;
  }

  /// 从日志恢复
  static PeriodDailyRecordCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => PeriodDailyRecordCULog.fromCreateLog(log),
      OperateType.update => PeriodDailyRecordCULog.fromUpdateLog(log),
      _ => throw ArgumentError('PeriodDailyRecordCULog does not support ${log.operateType}'),
    };
  }

  /// 创建每日明细
  static PeriodDailyRecordCULog create({
    required String who,
    required String cycleId,
    required String recordDate,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodDailyRecordCULog()
        .who(who)
        .doCreate()
        .noParent()
        .withData(PeriodDailyRecordTable.toCreateCompanion(
          who,
          cycleId: cycleId,
          recordDate: recordDate,
          flowLevel: flowLevel,
          symptoms: symptoms,
          mood: mood,
          remark: remark,
        )) as PeriodDailyRecordCULog;
  }

  /// 更新每日明细
  static PeriodDailyRecordCULog update({
    required String who,
    required String id,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodDailyRecordCULog()
        .who(who)
        .doUpdate()
        .noParent()
        .target(id)
        .withData(PeriodDailyRecordTable.toUpdateCompanion(
          who,
          flowLevel: flowLevel,
          symptoms: symptoms,
          mood: mood,
          remark: remark,
        )) as PeriodDailyRecordCULog;
  }

  /// 删除每日明细
  static PeriodDailyRecordCULog delete({
    required String who,
    required String id,
  }) {
    return PeriodDailyRecordCULog()
        .who(who)
        .doDelete()
        .noParent()
        .target(id) as PeriodDailyRecordCULog;
  }

  static PeriodDailyRecordTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return PeriodDailyRecordTable.fromJson(json);
  }
}
