import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../database/database.dart';
import '../../../../database/tables/recurring_config_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

/// 固定收支配置日志构建器
class RecurringConfigCULog extends LogBuilder<RecurringConfigTableCompanion, String> {
  RecurringConfigCULog() : super() {
    doWith(BusinessType.recurringConfig);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.recurringConfigDao.insertConfig(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.recurringConfigDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.recurringConfigDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return RecurringConfigTable.toJsonString(data as RecurringConfigTableCompanion);
  }

  /// 从创建日志恢复
  static RecurringConfigCULog fromCreateLog(LogSync log) {
    return RecurringConfigCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as RecurringConfigCULog;
  }

  /// 从更新日志恢复
  static RecurringConfigCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return RecurringConfigCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doUpdate()
        .withData(RecurringConfigTable.toUpdateCompanion(
          log.operatorId,
          type: data['type'] as String?,
          amount: data['amount'] as double?,
          description: data['description'] as String?,
          categoryCode: data['categoryCode'] as String?,
          fundId: data['fundId'] as String?,
          shopCode: data['shopCode'] as String?,
          tagCode: data['tagCode'] as String?,
          projectCode: data['projectCode'] as String?,
          frequencyType: data['frequencyType'] as String?,
          frequencyValue: data['frequencyValue'] as String?,
          startDate: data['startDate'] as String?,
          endType: data['endType'] as String?,
          endDate: data['endDate'] as String?,
          endCount: data['endCount'] as int?,
          isActive: data['isActive'] as bool?,
          generatedCount: data['generatedCount'] as int?,
          lastGeneratedAt: data['lastGeneratedAt'] as String?,
        )) as RecurringConfigCULog;
  }

  /// 从日志恢复
  static RecurringConfigCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => RecurringConfigCULog.fromCreateLog(log),
      OperateType.update => RecurringConfigCULog.fromUpdateLog(log),
      _ => RecurringConfigCULog.fromUpdateLog(log),
    };
  }

  /// 创建
  static RecurringConfigCULog create({
    required String who,
    required String bookId,
    required String type,
    required double amount,
    String? description,
    required String categoryCode,
    required String fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    required String frequencyType,
    required String frequencyValue,
    required String startDate,
    required String endType,
    String? endDate,
    int? endCount,
  }) {
    return RecurringConfigCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(RecurringConfigTable.toCreateCompanion(
          who,
          bookId,
          type: type,
          amount: amount,
          description: description,
          categoryCode: categoryCode,
          fundId: fundId,
          shopCode: shopCode,
          tagCode: tagCode,
          projectCode: projectCode,
          frequencyType: frequencyType,
          frequencyValue: frequencyValue,
          startDate: startDate,
          endType: endType,
          endDate: endDate,
          endCount: endCount,
        )) as RecurringConfigCULog;
  }

  /// 更新
  static RecurringConfigCULog update({
    required String who,
    required String id,
    String? type,
    double? amount,
    String? description,
    String? categoryCode,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    String? frequencyType,
    String? frequencyValue,
    String? startDate,
    String? endType,
    String? endDate,
    int? endCount,
    bool? isActive,
    int? generatedCount,
    String? lastGeneratedAt,
  }) {
    return RecurringConfigCULog()
        .who(who)
        .target(id)
        .doUpdate()
        .withData(RecurringConfigTable.toUpdateCompanion(
          who,
          type: type,
          amount: amount,
          description: description,
          categoryCode: categoryCode,
          fundId: fundId,
          shopCode: shopCode,
          tagCode: tagCode,
          projectCode: projectCode,
          frequencyType: frequencyType,
          frequencyValue: frequencyValue,
          startDate: startDate,
          endType: endType,
          endDate: endDate,
          endCount: endCount,
          isActive: isActive,
          generatedCount: generatedCount,
          lastGeneratedAt: lastGeneratedAt,
        )) as RecurringConfigCULog;
  }

  /// 删除
  static RecurringConfigCULog delete({
    required String who,
    required String id,
  }) {
    return RecurringConfigCULog()
        .who(who)
        .target(id)
        .doDelete() as RecurringConfigCULog;
  }

  /// 解析JSON为Companion
  static RecurringConfigTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return RecurringConfigTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      accountBookId: json['accountBookId'] != null ? Value(json['accountBookId'] as String) : const Value.absent(),
      type: json['type'] != null ? Value(json['type'] as String) : const Value.absent(),
      amount: json['amount'] != null ? Value(json['amount'] as double) : const Value.absent(),
      description: json['description'] != null ? Value(json['description'] as String) : const Value.absent(),
      categoryCode: json['categoryCode'] != null ? Value(json['categoryCode'] as String) : const Value.absent(),
      fundId: json['fundId'] != null ? Value(json['fundId'] as String) : const Value.absent(),
      shopCode: json['shopCode'] != null ? Value(json['shopCode'] as String) : const Value.absent(),
      tagCode: json['tagCode'] != null ? Value(json['tagCode'] as String) : const Value.absent(),
      projectCode: json['projectCode'] != null ? Value(json['projectCode'] as String) : const Value.absent(),
      frequencyType: json['frequencyType'] != null ? Value(json['frequencyType'] as String) : const Value.absent(),
      frequencyValue: json['frequencyValue'] != null ? Value(json['frequencyValue'] as String) : const Value.absent(),
      startDate: json['startDate'] != null ? Value(json['startDate'] as String) : const Value.absent(),
      endType: json['endType'] != null ? Value(json['endType'] as String) : const Value.absent(),
      endDate: json['endDate'] != null ? Value(json['endDate'] as String) : const Value.absent(),
      endCount: json['endCount'] != null ? Value(json['endCount'] as int) : const Value.absent(),
      generatedCount: json['generatedCount'] != null ? Value(json['generatedCount'] as int) : const Value.absent(),
      lastGeneratedAt: json['lastGeneratedAt'] != null ? Value(json['lastGeneratedAt'] as String) : const Value.absent(),
      isActive: json['isActive'] != null ? Value(json['isActive'] as bool) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
    );
  }
}
