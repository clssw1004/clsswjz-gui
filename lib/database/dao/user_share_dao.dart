import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/user_share_table.dart';
import 'base_dao.dart';

class UserShareDao extends BaseDao<UserShareTable, UserShare> {
  UserShareDao(super.db);

  @override
  TableInfo<UserShareTable, UserShare> get table => db.userShareTable;

  /// 插入或替换（基于 UNIQUE 约束 upsert）
  Future<void> upsert(Insertable<UserShare> entity) async {
    await db.into(table).insert(entity, mode: InsertMode.insertOrReplace);
  }

  /// 查询谁把指定模块共享给了某用户（仅已启用的共享）
  Future<List<String>> findOwnersByTarget(
      String targetUserId, String businessType) async {
    final result = await (db.select(table)
          ..where((t) =>
              t.targetUserId.equals(targetUserId) &
              t.businessType.equals(businessType) &
              t.isEnabled.equals(true)))
        .get();
    return result.map((r) => r.ownerUserId).toList();
  }

  /// 查询某用户的所有共享配置（作为 owner）
  Future<List<UserShare>> findByOwner(String ownerUserId) {
    return (db.select(table)
          ..where((t) => t.ownerUserId.equals(ownerUserId)))
        .get();
  }

  /// 查询某用户被共享了哪些（作为 target）
  Future<List<UserShare>> findByTarget(String targetUserId) {
    return (db.select(table)
          ..where((t) => t.targetUserId.equals(targetUserId)))
        .get();
  }

  /// 按 owner + target + businessType 查询
  Future<List<UserShare>> findByOwnerAndTarget(
      String ownerUserId, String targetUserId, String businessType) {
    return (db.select(table)
          ..where((t) =>
              t.ownerUserId.equals(ownerUserId) &
              t.targetUserId.equals(targetUserId) &
              t.businessType.equals(businessType)))
        .get();
  }

  /// 查询 owner 已启用的共享
  Future<List<UserShare>> findEnabledByOwner(String ownerUserId) {
    return (db.select(table)
          ..where((t) =>
              t.ownerUserId.equals(ownerUserId) & t.isEnabled.equals(true)))
        .get();
  }

  /// 查询 target 已启用的共享
  Future<List<UserShare>> findEnabledByTarget(String targetUserId) {
    return (db.select(table)
          ..where((t) =>
              t.targetUserId.equals(targetUserId) & t.isEnabled.equals(true)))
        .get();
  }
}
