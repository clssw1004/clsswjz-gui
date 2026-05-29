import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/fuel_record_table.dart';
import 'base_dao.dart';

class FuelRecordDao extends BaseDao<FuelRecordTable, FuelRecord> {
  FuelRecordDao(super.db);

  @override
  TableInfo<FuelRecordTable, FuelRecord> get table => db.fuelRecordTable;

  /// 根据车辆ID查询加油记录（按加油时间倒序）
  Future<List<FuelRecord>> findByVehicleId(String vehicleId, {int? limit, int? offset}) {
    final query = (db.select(table)
      ..where((t) => t.vehicleId.equals(vehicleId))
      ..orderBy([(t) => OrderingTerm.desc(t.refuelTime)]));
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }

  /// 查询指定里程前最近的一次加满记录（用于计算油耗）
  Future<FuelRecord?> findLastFullTank(String vehicleId, int mileage) {
    return (db.select(table)
          ..where((t) =>
              t.vehicleId.equals(vehicleId) &
              t.isFullTank.equals(1) &
              t.mileage.isSmallerThanValue(mileage))
          ..orderBy([(t) => OrderingTerm.desc(t.mileage)])
          ..limit(1))
        .getSingleOrNull();
  }
}
