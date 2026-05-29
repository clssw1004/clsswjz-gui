import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/fuel_record_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

/// 加油记录日志构建器
class FuelRecordCULog extends LogBuilder<FuelRecordTableCompanion, String> {
  FuelRecordCULog() : super() {
    doWith(BusinessType.fuelRecord);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.fuelRecordDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.fuelRecordDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.fuelRecordDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return FuelRecordTable.toJsonString(data as FuelRecordTableCompanion);
  }

  /// 从创建日志恢复
  static FuelRecordCULog fromCreateLog(LogSync log) {
    return FuelRecordCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as FuelRecordCULog;
  }

  /// 从更新日志恢复
  static FuelRecordCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return FuelRecordCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doUpdate()
        .withData(FuelRecordTable.toUpdateCompanion(
          log.operatorId,
          vehicleId: data['vehicleId'] as String?,
          mileage: data['mileage'] as int?,
          energyType: data['energyType'] as String?,
          fuelGrade: data['fuelGrade'] as String?,
          volume: data['volume'] as double?,
          unitPrice: data['unitPrice'] as double?,
          totalAmount: data['totalAmount'] as double?,
          isFullTank: data['isFullTank'] as int?,
          isFuelLightOn: data['isFuelLightOn'] as int?,
          station: data['station'] as String?,
          remark: data['remark'] as String?,
          refuelTime: data['refuelTime'] as int?,
          linkedBookId: data['linkedBookId'] as String?,
          linkedItemId: data['linkedItemId'] as String?,
        )) as FuelRecordCULog;
  }

  /// 从日志恢复
  static FuelRecordCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => FuelRecordCULog.fromCreateLog(log),
      OperateType.update => FuelRecordCULog.fromUpdateLog(log),
      _ => FuelRecordCULog.fromUpdateLog(log),
    };
  }

  /// 创建加油记录
  static FuelRecordCULog create({
    required String who,
    required String vehicleId,
    required int mileage,
    required String energyType,
    required String fuelGrade,
    required double volume,
    required double unitPrice,
    required double totalAmount,
    bool isFullTank = false,
    int? isFuelLightOn,
    String? station,
    String? remark,
    int? refuelTime,
  }) {
    return FuelRecordCULog()
        .who(who)
        .doCreate()
        .noParent()
        .withData(FuelRecordTable.toCreateCompanion(
          who,
          vehicleId: vehicleId,
          mileage: mileage,
          energyType: energyType,
          fuelGrade: fuelGrade,
          volume: volume,
          unitPrice: unitPrice,
          totalAmount: totalAmount,
          isFullTank: isFullTank ? 1 : 0,
          isFuelLightOn: isFuelLightOn,
          station: station,
          remark: remark,
          refuelTime: refuelTime ?? DateTime.now().millisecondsSinceEpoch,
        )) as FuelRecordCULog;
  }

  /// 更新加油记录
  static FuelRecordCULog update({
    required String who,
    required String id,
    int? mileage,
    String? energyType,
    String? fuelGrade,
    double? volume,
    double? unitPrice,
    double? totalAmount,
    bool? isFullTank,
    int? isFuelLightOn,
    String? station,
    String? remark,
    int? refuelTime,
    String? linkedBookId,
    String? linkedItemId,
  }) {
    return FuelRecordCULog()
        .who(who)
        .doUpdate()
        .noParent()
        .target(id)
        .withData(FuelRecordTable.toUpdateCompanion(
          who,
          mileage: mileage,
          energyType: energyType,
          fuelGrade: fuelGrade,
          volume: volume,
          unitPrice: unitPrice,
          totalAmount: totalAmount,
          isFullTank: isFullTank != null ? (isFullTank ? 1 : 0) : null,
          isFuelLightOn: isFuelLightOn,
          station: station,
          remark: remark,
          refuelTime: refuelTime,
          linkedBookId: linkedBookId,
          linkedItemId: linkedItemId,
        )) as FuelRecordCULog;
  }

  /// 删除加油记录
  static FuelRecordCULog delete({
    required String who,
    required String id,
  }) {
    return FuelRecordCULog()
        .who(who)
        .doDelete()
        .noParent()
        .target(id) as FuelRecordCULog;
  }

  /// 解析JSON为Companion
  static FuelRecordTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return FuelRecordTable.fromJson(json);
  }
}
