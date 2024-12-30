import 'package:drift/drift.dart';
import '../database.dart';

class AccountBookDao {
  final AppDatabase db;

  AccountBookDao(this.db);

  Future<int> insert(AccountBookTableCompanion entity) {
    return db.into(db.accountBookTable).insert(entity);
  }

  Future<void> batchInsert(List<AccountBookTableCompanion> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(db.accountBookTable, entity,
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> update(AccountBookTableCompanion entity) {
    return db.update(db.accountBookTable).replace(entity);
  }

  Future<int> delete(AccountBook entity) {
    return db.delete(db.accountBookTable).delete(entity);
  }

  Future<List<AccountBook>> findAll() {
    return db.select(db.accountBookTable).get();
  }

  Future<AccountBook?> findById(String id) {
    return (db.select(db.accountBookTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<AccountBook>> findPermissionedByUserId(String userId) {
    final query = db.select(db.accountBookTable).join([
      innerJoin(
        db.relAccountbookUserTable,
        db.relAccountbookUserTable.accountBookId.equalsExp(
          db.accountBookTable.id,
        ),
      ),
    ])
      ..where(db.relAccountbookUserTable.userId.equals(userId) &
          db.relAccountbookUserTable.canViewBook.equals(true));

    return query.map((row) => row.readTable(db.accountBookTable)).get();
  }

  Future<List<AccountBook>> findByCreatedBy(String userId) {
    return (db.select(db.accountBookTable)
          ..where((t) => t.createdBy.equals(userId)))
        .get();
  }

  Future<int> createAccountBook({
    required String id,
    required String name,
    required String description,
    required String createdBy,
    required String updatedBy,
    String currencySymbol = '¥',
    String? icon,
  }) {
    return insert(
      AccountBookTableCompanion.insert(
        id: id,
        name: name,
        description: Value(description),
        currencySymbol: Value(currencySymbol),
        icon: Value(icon),
        createdBy: createdBy,
        updatedBy: updatedBy,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// 根据ID列表查询多个账本
  Future<List<AccountBook>> findByIds(List<String> ids) {
    return (db.select(db.accountBookTable)..where((t) => t.id.isIn(ids))).get();
  }
}
