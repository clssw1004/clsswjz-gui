import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 车辆表
@DataClassName('Vehicle')
class VehicleTable extends BaseBusinessTable {
  /// 车牌号
  TextColumn get plateNumber => text().named('plate_number')();

  /// 品牌
  TextColumn get brand => text().named('brand')();

  /// 型号
  TextColumn get model => text().named('model')();

  /// 备注
  TextColumn get remark => text().nullable().named('remark')();

  /// 默认油号
  TextColumn get defaultFuelGrade =>
      text().named('default_fuel_grade').withDefault(const Constant('92'))();

  /// 是否启用 (1:启用, 0:停用)
  IntColumn get isActive => integer().named('is_active').withDefault(const Constant(1))();

  /// 排序号
  IntColumn get sortOrder => integer().named('sort_order').withDefault(const Constant(0))();

  /// 创建Companion
  static VehicleTableCompanion toCreateCompanion(
    String who, {
    required String plateNumber,
    required String brand,
    required String model,
    String? remark,
    String? defaultFuelGrade,
    int? isActive,
    int? sortOrder,
  }) {
    return VehicleTableCompanion(
      id: Value(IdUtil.genId()),
      plateNumber: Value(plateNumber),
      brand: Value(brand),
      model: Value(model),
      remark: Value.absentIfNull(remark),
      defaultFuelGrade: Value(defaultFuelGrade ?? '92'),
      isActive: Value(isActive ?? 1),
      sortOrder: Value(sortOrder ?? 0),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 更新Companion
  static VehicleTableCompanion toUpdateCompanion(
    String who, {
    String? plateNumber,
    String? brand,
    String? model,
    String? remark,
    String? defaultFuelGrade,
    int? isActive,
    int? sortOrder,
  }) {
    return VehicleTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      plateNumber: Value.absentIfNull(plateNumber),
      brand: Value.absentIfNull(brand),
      model: Value.absentIfNull(model),
      remark: Value.absentIfNull(remark),
      defaultFuelGrade: Value.absentIfNull(defaultFuelGrade),
      isActive: Value.absentIfNull(isActive),
      sortOrder: Value.absentIfNull(sortOrder),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
      id: const Value.absent(),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(VehicleTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'plateNumber', companion.plateNumber);
    MapUtil.setIfPresent(map, 'brand', companion.brand);
    MapUtil.setIfPresent(map, 'model', companion.model);
    MapUtil.setIfPresent(map, 'remark', companion.remark);
    MapUtil.setIfPresent(map, 'defaultFuelGrade', companion.defaultFuelGrade);
    MapUtil.setIfPresent(map, 'isActive', companion.isActive);
    MapUtil.setIfPresent(map, 'sortOrder', companion.sortOrder);
    return jsonEncode(map);
  }

  /// 从JSON对象创建Companion（用于日志恢复）
  static VehicleTableCompanion fromJson(Map<String, dynamic> json) {
    return VehicleTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      plateNumber: json['plateNumber'] != null ? Value(json['plateNumber'] as String) : const Value.absent(),
      brand: json['brand'] != null ? Value(json['brand'] as String) : const Value.absent(),
      model: json['model'] != null ? Value(json['model'] as String) : const Value.absent(),
      remark: json['remark'] != null ? Value(json['remark'] as String) : const Value.absent(),
      defaultFuelGrade: json['defaultFuelGrade'] != null ? Value(json['defaultFuelGrade'] as String) : const Value.absent(),
      isActive: json['isActive'] != null ? Value(json['isActive'] as int) : const Value.absent(),
      sortOrder: json['sortOrder'] != null ? Value(json['sortOrder'] as int) : const Value.absent(),
    );
  }
}
