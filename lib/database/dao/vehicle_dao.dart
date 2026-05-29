import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/vehicle_table.dart';
import 'base_dao.dart';

class VehicleDao extends BaseDao<VehicleTable, Vehicle> {
  VehicleDao(super.db);

  @override
  TableInfo<VehicleTable, Vehicle> get table => db.vehicleTable;

  /// 根据用户ID查询
  Future<List<Vehicle>> findByUserId(String userId) {
    return (db.select(table)
          ..where((t) => t.createdBy.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// 查询用户启用的车辆
  Future<List<Vehicle>> findActiveByUserId(String userId) {
    return (db.select(table)
          ..where((t) => t.createdBy.equals(userId) & t.isActive.equals(1))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }
}
