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
    return (db.select(table)..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  /// 查询用户有权限的车辆（自己创建的 + 共享者创建的）
  Future<List<Vehicle>> findByCreatorOrShared(
      String userId, List<String> sharedByUserIds) {
    final query = (db.select(table)
      ..where((t) {
        var predicate = t.createdBy.equals(userId);
        if (sharedByUserIds.isNotEmpty) {
          predicate = predicate | t.createdBy.isIn(sharedByUserIds);
        }
        return predicate;
      })
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]));
    return query.get();
  }

  /// 查询用户启用的车辆
  Future<List<Vehicle>> findActiveByUserId(String userId) {
    return (db.select(table)
          ..where((t) => t.isActive.equals(1))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }
}
