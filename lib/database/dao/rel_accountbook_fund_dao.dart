import 'package:drift/drift.dart';
import '../database.dart';

class RelAccountbookFundDao {
  final AppDatabase db;

  RelAccountbookFundDao(this.db);

  Future<int> insert(RelAccountbookFundTableCompanion entity) {
    return db.into(db.relAccountbookFundTable).insert(entity);
  }

  Future<void> batchInsert(
      List<RelAccountbookFundTableCompanion> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(db.relAccountbookFundTable, entity,
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> update(RelAccountbookFundTableCompanion entity) {
    return db.update(db.relAccountbookFundTable).replace(entity);
  }

  Future<int> delete(RelAccountbookFund entity) {
    return db.delete(db.relAccountbookFundTable).delete(entity);
  }

  Future<List<RelAccountbookFund>> findAll() {
    return db.select(db.relAccountbookFundTable).get();
  }
}
