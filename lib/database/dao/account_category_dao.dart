import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';

class AccountCategoryDao {
  final AppDatabase db;

  AccountCategoryDao(this.db);

  Future<int> insert(AccountCategoryTableCompanion entity) {
    return db.into(db.accountCategoryTable).insert(entity);
  }

  Future<void> batchInsert(List<AccountCategoryTableCompanion> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(db.accountCategoryTable, entity,
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> update(AccountCategoryTableCompanion entity) {
    return db.update(db.accountCategoryTable).replace(entity);
  }

  Future<int> delete(AccountCategory entity) {
    return db.delete(db.accountCategoryTable).delete(entity);
  }

  Future<List<AccountCategory>> findAll() {
    return db.select(db.accountCategoryTable).get();
  }

  Future<AccountCategory?> findById(String id) {
    return (db.select(db.accountCategoryTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<AccountCategory>> findByCodes(List<String> codes) {
    return (db.select(db.accountCategoryTable)
          ..where((t) => t.code.isIn(codes)))
        .get();
  }

  Future<List<AccountCategory>> findByAccountBookId(String accountBookId) {
    return (db.select(db.accountCategoryTable)
          ..where((t) => t.accountBookId.equals(accountBookId)))
        .get();
  }

  Future<List<AccountCategory>> findByAccountBookIdAndType(
      String accountBookId, String categoryType) {
    return (db.select(db.accountCategoryTable)
          ..where((t) =>
              t.accountBookId.equals(accountBookId) &
              t.categoryType.equals(categoryType)))
        .get();
  }

  Future<int> createCategory({
    required String id,
    required String name,
    required String code,
    required String accountBookId,
    required String categoryType,
    required String createdBy,
    required String updatedBy,
    DateTime? lastAccountItemAt,
  }) {
    return insert(
      AccountCategoryTableCompanion.insert(
        id: id,
        name: name,
        code: code,
        accountBookId: accountBookId,
        categoryType: categoryType,
        lastAccountItemAt: Value(lastAccountItemAt),
        createdBy: createdBy,
        updatedBy: updatedBy,
        createdAt: DateUtil.now(),
        updatedAt: DateUtil.now(),
      ),
    );
  }
}
