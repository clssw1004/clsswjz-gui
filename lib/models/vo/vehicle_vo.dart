import '../../database/database.dart';

/// 车辆视图对象
class VehicleVO {
  /// ID
  final String id;

  /// 车牌号
  final String plateNumber;

  /// 品牌
  final String brand;

  /// 型号
  final String model;

  /// 备注
  final String? remark;

  /// 默认油号
  final String defaultFuelGrade;

  /// 是否启用
  final int isActive;

  /// 排序号
  final int sortOrder;

  const VehicleVO({
    required this.id,
    required this.plateNumber,
    required this.brand,
    required this.model,
    this.remark,
    required this.defaultFuelGrade,
    required this.isActive,
    required this.sortOrder,
  });

  /// 显示名称 (品牌 型号 (车牌号))
  String get displayName => '$brand $model ($plateNumber)';

  /// 显示油号
  String get displayFuelGrade => '$defaultFuelGrade号';

  /// 从数据库实体创建视图对象
  static VehicleVO fromVehicle(Vehicle vehicle) {
    return VehicleVO(
      id: vehicle.id,
      plateNumber: vehicle.plateNumber,
      brand: vehicle.brand,
      model: vehicle.model,
      remark: vehicle.remark,
      defaultFuelGrade: vehicle.defaultFuelGrade,
      isActive: vehicle.isActive,
      sortOrder: vehicle.sortOrder,
    );
  }
}
