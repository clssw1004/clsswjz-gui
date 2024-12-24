import 'package:drift/drift.dart';
import '../database.dart';

class AccountFundDao {
  final AppDatabase db;

  AccountFundDao(this.db);

  Future<int> insert(AccountFundTableCompanion entity) {
    return db.into(db.accountFundTable).insert(entity);
  }

  Future<void> batchInsert(List<AccountFundTableCompanion> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(db.accountFundTable, entity,
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> update(AccountFundTableCompanion entity) {
    return db.update(db.accountFundTable).replace(entity);
  }

  Future<int> delete(AccountFund entity) {
    return db.delete(db.accountFundTable).delete(entity);
  }

  Future<List<AccountFund>> findAll() {
    return db.select(db.accountFundTable).get();
  }

  Future<AccountFund?> findById(String id) {
    return (db.select(db.accountFundTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<AccountFund>> findByAccountBookId(String accountBookId) {
    final query = db.select(db.accountFundTable).join([
      innerJoin(
        db.relAccountbookFundTable,
        db.relAccountbookFundTable.fundId.equalsExp(
          db.accountFundTable.id,
        ),
      ),
    ])
      ..where(db.relAccountbookFundTable.accountBookId.equals(accountBookId));

    return query.map((row) => row.readTable(db.accountFundTable)).get();
  }

  Future<List<AccountFund>> findByType(String fundType) {
    return (db.select(db.accountFundTable)
          ..where((t) => t.fundType.equals(fundType)))
        .get();
  }

  Future<int> createFund({
    required String id,
    required String name,
    required String fundType,
    required String createdBy,
    required String updatedBy,
    String? fundRemark,
    double fundBalance = 0.00,
  }) {
    return insert(
      AccountFundTableCompanion.insert(
        id: id,
        name: name,
        fundType: fundType,
        fundRemark: Value(fundRemark),
        fundBalance: Value(fundBalance),
        createdBy: createdBy,
        updatedBy: updatedBy,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<bool> updateBalance(String id, double newBalance) {
    return update(
      AccountFundTableCompanion(
        id: Value(id),
        fundBalance: Value(newBalance),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
