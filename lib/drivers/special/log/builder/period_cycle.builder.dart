import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/period_cycle_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

/// 经期周期日志构建器
class PeriodCycleCULog extends LogBuilder<PeriodCycleTableCompanion, String> {
  PeriodCycleCULog() : super() {
    doWith(BusinessType.periodCycle);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.periodCycleDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.periodCycleDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.periodCycleDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return PeriodCycleTable.toJsonString(data as PeriodCycleTableCompanion);
  }

  /// 从创建日志恢复
  static PeriodCycleCULog fromCreateLog(LogSync log) {
    return PeriodCycleCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as PeriodCycleCULog;
  }

  /// 从更新日志恢复
  static PeriodCycleCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return PeriodCycleCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doUpdate()
        .withData(PeriodCycleTable.toUpdateCompanion(
          log.operatorId,
          endDate: data['endDate'] as String?,
          typicalPeriodDays: data['typicalPeriodDays'] as int?,
          typicalCycleDays: data['typicalCycleDays'] as int?,
        )) as PeriodCycleCULog;
  }

  /// 从日志恢复
  static PeriodCycleCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => PeriodCycleCULog.fromCreateLog(log),
      OperateType.update => PeriodCycleCULog.fromUpdateLog(log),
      _ => throw ArgumentError('PeriodCycleCULog does not support ${log.operateType}'),
    };
  }

  /// 创建周期
  static PeriodCycleCULog create({
    required String who,
    required String startDate,
    String? endDate,
    int? typicalPeriodDays,
    int? typicalCycleDays,
  }) {
    return PeriodCycleCULog()
        .who(who)
        .doCreate()
        .noParent()
        .withData(PeriodCycleTable.toCreateCompanion(
          who,
          startDate: startDate,
          endDate: endDate,
          typicalPeriodDays: typicalPeriodDays,
          typicalCycleDays: typicalCycleDays,
        )) as PeriodCycleCULog;
  }

  /// 更新周期
  static PeriodCycleCULog update({
    required String who,
    required String id,
    String? endDate,
    int? typicalPeriodDays,
    int? typicalCycleDays,
  }) {
    return PeriodCycleCULog()
        .who(who)
        .doUpdate()
        .noParent()
        .target(id)
        .withData(PeriodCycleTable.toUpdateCompanion(
          who,
          endDate: endDate,
          typicalPeriodDays: typicalPeriodDays,
          typicalCycleDays: typicalCycleDays,
        )) as PeriodCycleCULog;
  }

  /// 删除周期
  static PeriodCycleCULog delete({
    required String who,
    required String id,
  }) {
    return PeriodCycleCULog()
        .who(who)
        .doDelete()
        .noParent()
        .target(id) as PeriodCycleCULog;
  }

  static PeriodCycleTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return PeriodCycleTable.fromJson(json);
  }
}
