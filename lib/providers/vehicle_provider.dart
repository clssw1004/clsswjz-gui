import 'package:flutter/material.dart';

import '../drivers/driver_factory.dart';
import '../manager/app_config_manager.dart';
import '../models/common.dart';
import '../models/vo/vehicle_vo.dart';

/// 车辆数据提供者
class VehicleProvider extends ChangeNotifier {
  List<VehicleVO> _items = [];
  bool _loading = false;

  List<VehicleVO> get items => _items;
  bool get loading => _loading;

  /// 加载车辆列表
  Future<void> loadItems() async {
    _loading = true;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.listVehicles(
        AppConfigManager.instance.userId,
      );
      if (result.ok) {
        _items = result.data ?? [];
      }
    } catch (e) {
      // 忽略错误
    }

    _loading = false;
    notifyListeners();
  }

  /// 创建车辆
  Future<OperateResult<String>> createVehicle({
    required String plateNumber,
    required String brand,
    required String model,
    String? remark,
    String? defaultFuelGrade,
  }) async {
    final result = await DriverFactory.driver.createVehicle(
      AppConfigManager.instance.userId,
      plateNumber: plateNumber,
      brand: brand,
      model: model,
      remark: remark,
      defaultFuelGrade: defaultFuelGrade,
    );
    if (result.ok) {
      await loadItems();
    }
    return result;
  }

  /// 更新车辆
  Future<OperateResult<void>> updateVehicle(
    String vehicleId, {
    String? plateNumber,
    String? brand,
    String? model,
    String? remark,
    String? defaultFuelGrade,
    bool? isActive,
    int? sortOrder,
  }) async {
    final result = await DriverFactory.driver.updateVehicle(
      AppConfigManager.instance.userId,
      vehicleId,
      plateNumber: plateNumber,
      brand: brand,
      model: model,
      remark: remark,
      defaultFuelGrade: defaultFuelGrade,
      isActive: isActive,
      sortOrder: sortOrder,
    );
    if (result.ok) {
      await loadItems();
    }
    return result;
  }

  /// 删除车辆
  Future<OperateResult<void>> deleteVehicle(String vehicleId) async {
    final result = await DriverFactory.driver.deleteVehicle(
      AppConfigManager.instance.userId,
      vehicleId,
    );
    if (result.ok) {
      await loadItems();
    }
    return result;
  }
}
