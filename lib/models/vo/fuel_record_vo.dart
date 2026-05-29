import '../../database/database.dart';

/// 加油记录视图对象
class FuelRecordVO {
  /// ID
  final String id;

  /// 车辆ID
  final String vehicleId;

  /// 里程数
  final int mileage;

  /// 能源类型
  final String energyType;

  /// 油号
  final String fuelGrade;

  /// 加油量 (升)
  final double volume;

  /// 单价 (元/升)
  final double unitPrice;

  /// 总金额 (元)
  final double totalAmount;

  /// 是否加满
  final int isFullTank;

  /// 加油站
  final String? station;

  /// 备注
  final String? remark;

  /// 加油时间 (毫秒时间戳)
  final int refuelTime;

  /// 关联账本ID
  final String? linkedBookId;

  /// 关联账目ID
  final String? linkedItemId;

  /// 上次加满时的里程数（由外部设置，用于计算油耗）
  final int? lastFullTankMileage;

  /// 上次加满时的加油量（由外部设置，用于计算油耗）
  final double? lastFullTankVolume;

  const FuelRecordVO({
    required this.id,
    required this.vehicleId,
    required this.mileage,
    required this.energyType,
    required this.fuelGrade,
    required this.volume,
    required this.unitPrice,
    required this.totalAmount,
    required this.isFullTank,
    this.station,
    this.remark,
    required this.refuelTime,
    this.linkedBookId,
    this.linkedItemId,
    this.lastFullTankMileage,
    this.lastFullTankVolume,
  });

  /// 里程差
  int get mileageDiff {
    if (lastFullTankMileage == null) return 0;
    return mileage - lastFullTankMileage!;
  }

  /// 油耗 (L/100km)
  double get fuelConsumption {
    if (mileageDiff <= 0 || volume <= 0) return 0;
    return volume / mileageDiff * 100;
  }

  /// 每公里成本 (元/km)
  double get costPerKm {
    if (mileageDiff <= 0 || totalAmount <= 0) return 0;
    return totalAmount / mileageDiff;
  }

  /// 显示油号
  String get displayFuelGrade => '$fuelGrade号';

  /// 是否关联账目
  bool get hasLinkedAccount =>
      linkedBookId != null && linkedBookId!.isNotEmpty &&
      linkedItemId != null && linkedItemId!.isNotEmpty;

  /// 是否加满标签
  String get isFullTankLabel => isFullTank == 1 ? '加满' : '未加满';

  /// 油耗文本
  String get fuelConsumptionText {
    final value = fuelConsumption;
    if (value <= 0) return '--';
    return '${value.toStringAsFixed(2)} L/100km';
  }

  /// 每公里成本文本
  String get costPerKmText {
    final value = costPerKm;
    if (value <= 0) return '--';
    return '${value.toStringAsFixed(2)} 元/km';
  }

  /// 从数据库实体创建视图对象
  static FuelRecordVO fromFuelRecord(FuelRecord record) {
    return FuelRecordVO(
      id: record.id,
      vehicleId: record.vehicleId,
      mileage: record.mileage,
      energyType: record.energyType,
      fuelGrade: record.fuelGrade,
      volume: record.volume,
      unitPrice: record.unitPrice,
      totalAmount: record.totalAmount,
      isFullTank: record.isFullTank,
      station: record.station,
      remark: record.remark,
      refuelTime: record.refuelTime,
      linkedBookId: record.linkedBookId,
      linkedItemId: record.linkedItemId,
    );
  }

  /// 复制并设置上次加满信息
  FuelRecordVO copyWith({
    int? lastFullTankMileage,
    double? lastFullTankVolume,
  }) {
    return FuelRecordVO(
      id: id,
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
      linkedBookId: linkedBookId,
      linkedItemId: linkedItemId,
      lastFullTankMileage: lastFullTankMileage ?? this.lastFullTankMileage,
      lastFullTankVolume: lastFullTankVolume ?? this.lastFullTankVolume,
    );
  }
}
