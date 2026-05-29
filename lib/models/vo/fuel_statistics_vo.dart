/// 油耗统计视图对象
class FuelStatisticsVO {
  final double totalVolume;
  final double totalAmount;
  final int totalRecords;
  final double? averageFuelConsumption;
  final double? averageCostPerKm;

  const FuelStatisticsVO({
    required this.totalVolume,
    required this.totalAmount,
    required this.totalRecords,
    this.averageFuelConsumption,
    this.averageCostPerKm,
  });

  String get averageFuelConsumptionText {
    if (averageFuelConsumption == null) return '--';
    return '${averageFuelConsumption!.toStringAsFixed(2)} L/100km';
  }

  String get averageCostPerKmText {
    if (averageCostPerKm == null) return '--';
    return '${averageCostPerKm!.toStringAsFixed(3)} 元/km';
  }
}
