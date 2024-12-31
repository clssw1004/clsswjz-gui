import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';

class AccountShopDao {
  final AppDatabase db;

  AccountShopDao(this.db);

  Future<int> insert(AccountShopTableCompanion entity) {
    return db.into(db.accountShopTable).insert(entity);
  }

  Future<void> batchInsert(List<AccountShopTableCompanion> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(db.accountShopTable, entity,
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> update(AccountShopTableCompanion entity) {
    return db.update(db.accountShopTable).replace(entity);
  }

  Future<int> delete(AccountShop entity) {
    return db.delete(db.accountShopTable).delete(entity);
  }

  Future<List<AccountShop>> findAll() {
    return db.select(db.accountShopTable).get();
  }

  Future<AccountShop?> findById(String id) {
    return (db.select(db.accountShopTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<AccountShop>> findByCodes(List<String> codes) {
    return (db.select(db.accountShopTable)..where((t) => t.code.isIn(codes)))
        .get();
  }

  Future<List<AccountShop>> findByAccountBookId(String accountBookId) {
    return (db.select(db.accountShopTable)
          ..where((t) => t.accountBookId.equals(accountBookId)))
        .get();
  }

  Future<AccountShop?> findByCode(String code) {
    return (db.select(db.accountShopTable)..where((t) => t.code.equals(code)))
        .getSingleOrNull();
  }

  Future<int> createShop({
    required String id,
    required String name,
    required String code,
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
  }) {
    return insert(
      AccountShopTableCompanion.insert(
        id: id,
        name: name,
        code: code,
        accountBookId: accountBookId,
        createdBy: createdBy,
        updatedBy: updatedBy,
        createdAt: DateUtil.now(),
        updatedAt: DateUtil.now(),
      ),
    );
  }
}
