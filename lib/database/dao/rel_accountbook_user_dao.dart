import 'package:drift/drift.dart';
import '../database.dart';

class RelAccountbookUserDao {
  final AppDatabase db;

  RelAccountbookUserDao(this.db);

  Future<int> insert(RelAccountbookUserTableCompanion entity) {
    return db.into(db.relAccountbookUserTable).insert(entity);
  }

  Future<void> batchInsert(
      List<RelAccountbookUserTableCompanion> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(db.relAccountbookUserTable, entity,
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> update(RelAccountbookUserTableCompanion entity) {
    return db.update(db.relAccountbookUserTable).replace(entity);
  }

  Future<int> delete(RelAccountbookUser entity) {
    return db.delete(db.relAccountbookUserTable).delete(entity);
  }

  Future<List<RelAccountbookUser>> findAll() {
    return db.select(db.relAccountbookUserTable).get();
  }
}
