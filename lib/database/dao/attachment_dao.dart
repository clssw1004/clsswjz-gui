import 'package:drift/drift.dart';
import '../database.dart';

class AttachmentDao {
  final AppDatabase db;

  AttachmentDao(this.db);

  Future<int> insert(AttachmentTableCompanion entity) {
    return db.into(db.attachmentTable).insert(entity);
  }

  Future<void> batchInsert(List<AttachmentTableCompanion> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(db.attachmentTable, entity,
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> update(AttachmentTableCompanion entity) {
    return db.update(db.attachmentTable).replace(entity);
  }

  Future<int> delete(Attachment entity) {
    return db.delete(db.attachmentTable).delete(entity);
  }

  Future<List<Attachment>> findAll() {
    return db.select(db.attachmentTable).get();
  }
}
