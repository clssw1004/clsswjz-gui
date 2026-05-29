import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 加油记录表
@DataClassName('FuelRecord')
class FuelRecordTable extends BaseBusinessTable {
  /// 车辆ID
  TextColumn get vehicleId => text().named('vehicle_id')();

  /// 里程数
  IntColumn get mileage => integer().named('mileage')();

  /// 能源类型 (gasoline: 汽油, diesel: 柴油)
  TextColumn get energyType =>
      text().named('energy_type').withDefault(const Constant('gasoline'))();

  /// 油号
  TextColumn get fuelGrade =>
      text().named('fuel_grade').withDefault(const Constant('92'))();

  /// 加油量 (升)
  RealColumn get volume => real().named('volume')();

  /// 单价 (元/升)
  RealColumn get unitPrice => real().named('unit_price')();

  /// 总金额 (元)
  RealColumn get totalAmount => real().named('total_amount')();

  /// 是否跳枪 (1:跳枪, 0:未跳枪)
  IntColumn get isFullTank =>
      integer().named('is_full_tank').withDefault(const Constant(0))();

  /// 油灯是否亮起 (1:亮起, 0:未亮)
  IntColumn get isFuelLightOn =>
      integer().named('is_fuel_light_on').withDefault(const Constant(0))();

  /// 加油站
  TextColumn get station => text().nullable().named('station')();

  /// 备注
  TextColumn get remark => text().nullable().named('remark')();

  /// 加油时间 (毫秒时间戳)
  IntColumn get refuelTime => integer().named('refuel_time')();

  /// 关联账本ID
  TextColumn get linkedBookId => text().nullable().named('linked_book_id')();

  /// 关联账目ID
  TextColumn get linkedItemId => text().nullable().named('linked_item_id')();

  /// 创建Companion
  static FuelRecordTableCompanion toCreateCompanion(
    String who, {
    required String vehicleId,
    required int mileage,
    String? energyType,
    String? fuelGrade,
    required double volume,
    required double unitPrice,
    required double totalAmount,
    int? isFullTank,
    int? isFuelLightOn,
    String? station,
    String? remark,
    required int refuelTime,
    String? linkedBookId,
    String? linkedItemId,
  }) {
    return FuelRecordTableCompanion(
      id: Value(IdUtil.genId()),
      vehicleId: Value(vehicleId),
      mileage: Value(mileage),
      energyType: Value(energyType ?? 'gasoline'),
      fuelGrade: Value(fuelGrade ?? '92'),
      volume: Value(volume),
      unitPrice: Value(unitPrice),
      totalAmount: Value(totalAmount),
      isFullTank: Value(isFullTank ?? 0),
      isFuelLightOn: Value(isFuelLightOn ?? 0),
      station: Value.absentIfNull(station),
      remark: Value.absentIfNull(remark),
      refuelTime: Value(refuelTime),
      linkedBookId: Value.absentIfNull(linkedBookId),
      linkedItemId: Value.absentIfNull(linkedItemId),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 更新Companion
  static FuelRecordTableCompanion toUpdateCompanion(
    String who, {
    String? vehicleId,
    int? mileage,
    String? energyType,
    String? fuelGrade,
    double? volume,
    double? unitPrice,
    double? totalAmount,
    int? isFullTank,
    int? isFuelLightOn,
    String? station,
    String? remark,
    int? refuelTime,
    String? linkedBookId,
    String? linkedItemId,
  }) {
    return FuelRecordTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      vehicleId: Value.absentIfNull(vehicleId),
      mileage: Value.absentIfNull(mileage),
      energyType: Value.absentIfNull(energyType),
      fuelGrade: Value.absentIfNull(fuelGrade),
      volume: Value.absentIfNull(volume),
      unitPrice: Value.absentIfNull(unitPrice),
      totalAmount: Value.absentIfNull(totalAmount),
      isFullTank: Value.absentIfNull(isFullTank),
      isFuelLightOn: Value.absentIfNull(isFuelLightOn),
      station: Value.absentIfNull(station),
      remark: Value.absentIfNull(remark),
      refuelTime: Value.absentIfNull(refuelTime),
      linkedBookId: Value.absentIfNull(linkedBookId),
      linkedItemId: Value.absentIfNull(linkedItemId),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
      id: const Value.absent(),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(FuelRecordTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'vehicleId', companion.vehicleId);
    MapUtil.setIfPresent(map, 'mileage', companion.mileage);
    MapUtil.setIfPresent(map, 'energyType', companion.energyType);
    MapUtil.setIfPresent(map, 'fuelGrade', companion.fuelGrade);
    MapUtil.setIfPresent(map, 'volume', companion.volume);
    MapUtil.setIfPresent(map, 'unitPrice', companion.unitPrice);
    MapUtil.setIfPresent(map, 'totalAmount', companion.totalAmount);
    MapUtil.setIfPresent(map, 'isFullTank', companion.isFullTank);
    MapUtil.setIfPresent(map, 'isFuelLightOn', companion.isFuelLightOn);
    MapUtil.setIfPresent(map, 'station', companion.station);
    MapUtil.setIfPresent(map, 'remark', companion.remark);
    MapUtil.setIfPresent(map, 'refuelTime', companion.refuelTime);
    MapUtil.setIfPresent(map, 'linkedBookId', companion.linkedBookId);
    MapUtil.setIfPresent(map, 'linkedItemId', companion.linkedItemId);
    return jsonEncode(map);
  }

  /// 从JSON对象创建Companion（用于日志恢复）
  static FuelRecordTableCompanion fromJson(Map<String, dynamic> json) {
    return FuelRecordTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      vehicleId: json['vehicleId'] != null ? Value(json['vehicleId'] as String) : const Value.absent(),
      mileage: json['mileage'] != null ? Value(json['mileage'] as int) : const Value.absent(),
      energyType: json['energyType'] != null ? Value(json['energyType'] as String) : const Value.absent(),
      fuelGrade: json['fuelGrade'] != null ? Value(json['fuelGrade'] as String) : const Value.absent(),
      volume: json['volume'] != null ? Value(json['volume'] as double) : const Value.absent(),
      unitPrice: json['unitPrice'] != null ? Value(json['unitPrice'] as double) : const Value.absent(),
      totalAmount: json['totalAmount'] != null ? Value(json['totalAmount'] as double) : const Value.absent(),
      isFullTank: json['isFullTank'] != null ? Value(json['isFullTank'] as int) : const Value.absent(),
      isFuelLightOn: json['isFuelLightOn'] != null ? Value(json['isFuelLightOn'] as int) : const Value.absent(),
      station: json['station'] != null ? Value(json['station'] as String) : const Value.absent(),
      remark: json['remark'] != null ? Value(json['remark'] as String) : const Value.absent(),
      refuelTime: json['refuelTime'] != null ? Value(json['refuelTime'] as int) : const Value.absent(),
      linkedBookId: json['linkedBookId'] != null ? Value(json['linkedBookId'] as String) : const Value.absent(),
      linkedItemId: json['linkedItemId'] != null ? Value(json['linkedItemId'] as String) : const Value.absent(),
    );
  }
}
