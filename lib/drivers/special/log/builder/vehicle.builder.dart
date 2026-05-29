import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/vehicle_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

/// 车辆日志构建器
class VehicleCULog extends LogBuilder<VehicleTableCompanion, String> {
  VehicleCULog() : super() {
    doWith(BusinessType.vehicle);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.vehicleDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.vehicleDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.vehicleDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return VehicleTable.toJsonString(data as VehicleTableCompanion);
  }

  /// 从创建日志恢复
  static VehicleCULog fromCreateLog(LogSync log) {
    return VehicleCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as VehicleCULog;
  }

  /// 从更新日志恢复
  static VehicleCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return VehicleCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doUpdate()
        .withData(VehicleTable.toUpdateCompanion(
          log.operatorId,
          plateNumber: data['plateNumber'] as String?,
          brand: data['brand'] as String?,
          model: data['model'] as String?,
          remark: data['remark'] as String?,
          defaultFuelGrade: data['defaultFuelGrade'] as String?,
          isActive: data['isActive'] as int?,
          sortOrder: data['sortOrder'] as int?,
        )) as VehicleCULog;
  }

  /// 从日志恢复
  static VehicleCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => VehicleCULog.fromCreateLog(log),
      OperateType.update => VehicleCULog.fromUpdateLog(log),
      _ => VehicleCULog.fromUpdateLog(log),
    };
  }

  /// 创建车辆
  static VehicleCULog create({
    required String who,
    required String plateNumber,
    required String brand,
    required String model,
    String? remark,
    String? defaultFuelGrade,
  }) {
    return VehicleCULog()
        .who(who)
        .doCreate()
        .noParent()
        .withData(VehicleTable.toCreateCompanion(
          who,
          plateNumber: plateNumber,
          brand: brand,
          model: model,
          remark: remark,
          defaultFuelGrade: defaultFuelGrade,
        )) as VehicleCULog;
  }

  /// 更新车辆
  static VehicleCULog update({
    required String who,
    required String id,
    String? plateNumber,
    String? brand,
    String? model,
    String? remark,
    String? defaultFuelGrade,
    int? isActive,
    int? sortOrder,
  }) {
    return VehicleCULog()
        .who(who)
        .doUpdate()
        .noParent()
        .target(id)
        .withData(VehicleTable.toUpdateCompanion(
          who,
          plateNumber: plateNumber,
          brand: brand,
          model: model,
          remark: remark,
          defaultFuelGrade: defaultFuelGrade,
          isActive: isActive,
          sortOrder: sortOrder,
        )) as VehicleCULog;
  }

  /// 删除车辆
  static VehicleCULog delete({
    required String who,
    required String id,
  }) {
    return VehicleCULog()
        .who(who)
        .doDelete()
        .noParent()
        .target(id) as VehicleCULog;
  }

  /// 解析JSON为Companion
  static VehicleTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return VehicleTable.fromJson(json);
  }
}
