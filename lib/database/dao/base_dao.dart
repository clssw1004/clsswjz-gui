import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/base_table.dart';

/// 基础数据访问对象
abstract class BaseDao<T extends StringIdTable, D> {
  final AppDatabase db;

  BaseDao(this.db);

  /// 根据ID更新实体
  Future<bool> update(
    String id,
    Insertable<D> entity,
  ) async {
    final query = db.update(table)..where((t) => t.id.equals(id));
    final rows = await query.write(entity);
    return rows > 0;
  }

  Future<int> delete(String id) async {
    final query = db.delete(table)..where((t) => t.id.equals(id));
    return await query.go();
  }

  Future<List<D>> findAll() {
    return db.select(table).get();
  }

  Future<D?> findById(String id) {
    return (db.select(table)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<List<D>> findByIds(List<String> ids) {
    return (db.select(table)..where((t) => t.id.isIn(ids))).get();
  }

  Future<void> insert(Insertable<D> entity) async {
    await db.into(table).insert(entity);
  }

  Future<void> batchInsert(List<Insertable<D>> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(table, entity, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> existById(String id) async {
    final result = await (db.select(table)..where((t) => t.id.equals(id))).getSingleOrNull();
    return result != null;
  }

  TableInfo<T, D> get table;
}

abstract class BaseBookDao<T extends BaseAccountBookTable, D> extends BaseDao<T, D> {
  BaseBookDao(super.db);

  Future<List<D>> listByBook(String accountBookId, {int? limit, int? offset}) {
    final query = (db.select(table)
      ..where((t) => t.accountBookId.equals(accountBookId))
      ..orderBy(defaultOrderBy()));
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }

  List<OrderClauseGenerator<T>> defaultOrderBy() {
    return [
      (t) => OrderingTerm.desc(t.createdAt),
    ];
  }
}
