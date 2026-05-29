import 'package:flutter/material.dart';

import '../drivers/driver_factory.dart';
import '../manager/app_config_manager.dart';
import '../models/common.dart';
import '../models/dto/fuel_record_filter_dto.dart';
import '../models/vo/fuel_record_vo.dart';

/// 加油记录数据提供者
class FuelRecordProvider extends ChangeNotifier {
  List<FuelRecordVO> _items = [];
  bool _loading = false;

  List<FuelRecordVO> get items => _items;
  bool get loading => _loading;

  /// 加载加油记录列表
  Future<void> loadItems(
    String vehicleId, {
    int limit = 20,
    int offset = 0,
    FuelRecordFilterDTO? filter,
  }) async {
    _loading = true;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.listFuelRecords(
        AppConfigManager.instance.userId,
        vehicleId,
        limit: limit,
        offset: offset,
        filter: filter,
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

  /// 创建加油记录
  Future<OperateResult<String>> createFuelRecord({
    required String vehicleId,
    required int mileage,
    required String energyType,
    required String fuelGrade,
    required double volume,
    required double unitPrice,
    required double totalAmount,
    bool isFullTank = false,
    String? station,
    String? remark,
    int? refuelTime,
  }) async {
    final result = await DriverFactory.driver.createFuelRecord(
      AppConfigManager.instance.userId,
      vehicleId: vehicleId,
      mileage: mileage,
      energyType: energyType,
      fuelGrade: fuelGrade,
      volume: volume,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      isFullTank: isFullTank,
      station: station,
      remark: remark,
      refuelTime: refuelTime,
    );
    return result;
  }

  /// 更新加油记录
  Future<OperateResult<void>> updateFuelRecord(
    String recordId, {
    int? mileage,
    String? energyType,
    String? fuelGrade,
    double? volume,
    double? unitPrice,
    double? totalAmount,
    bool? isFullTank,
    String? station,
    String? remark,
    int? refuelTime,
    String? linkedBookId,
    String? linkedItemId,
  }) async {
    final result = await DriverFactory.driver.updateFuelRecord(
      AppConfigManager.instance.userId,
      recordId,
      mileage: mileage,
      energyType: energyType,
      fuelGrade: fuelGrade,
      volume: volume,
      unitPrice: unitPrice,
      totalAmount: totalAmount,
      isFullTank: isFullTank,
      station: station,
      remark: remark,
      refuelTime: refuelTime,
      linkedBookId: linkedBookId,
      linkedItemId: linkedItemId,
    );
    return result;
  }

  /// 删除加油记录
  Future<OperateResult<void>> deleteFuelRecord(String recordId) async {
    final result = await DriverFactory.driver.deleteFuelRecord(
      AppConfigManager.instance.userId,
      recordId,
    );
    return result;
  }

  /// 获取加油记录详情
  Future<FuelRecordVO?> getFuelRecord(String recordId) async {
    final result = await DriverFactory.driver.getFuelRecord(
      AppConfigManager.instance.userId,
      recordId,
    );
    return result.data;
  }
}
