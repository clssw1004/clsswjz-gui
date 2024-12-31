import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';

class AccountSymbolDao {
  final AppDatabase db;

  AccountSymbolDao(this.db);

  Future<int> insert(AccountSymbolTableCompanion entity) {
    return db.into(db.accountSymbolTable).insert(entity);
  }

  Future<void> batchInsert(List<AccountSymbolTableCompanion> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(db.accountSymbolTable, entity,
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> update(AccountSymbolTableCompanion entity) {
    return db.update(db.accountSymbolTable).replace(entity);
  }

  Future<int> delete(AccountSymbol entity) {
    return db.delete(db.accountSymbolTable).delete(entity);
  }

  Future<List<AccountSymbol>> findAll() {
    return db.select(db.accountSymbolTable).get();
  }

  Future<AccountSymbol?> findById(String id) {
    return (db.select(db.accountSymbolTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<AccountSymbol>> findByAccountBookId(String accountBookId) {
    return (db.select(db.accountSymbolTable)
          ..where((t) => t.accountBookId.equals(accountBookId)))
        .get();
  }

  Future<List<AccountSymbol>> findByType(String symbolType) {
    return (db.select(db.accountSymbolTable)
          ..where((t) => t.symbolType.equals(symbolType)))
        .get();
  }

  Future<List<AccountSymbol>> findByTypes(List<String> symbolTypes) {
    return (db.select(db.accountSymbolTable)
          ..where((t) => t.symbolType.isIn(symbolTypes)))
        .get();
  }

  Future<List<AccountSymbol>> findByTypeAndCodes(
      String symbolType, List<String> codes) {
    return (db.select(db.accountSymbolTable)
          ..where((t) => t.symbolType.equals(symbolType) & t.code.isIn(codes)))
        .get();
  }

  Future<AccountSymbol?> findByCode(String code) {
    return (db.select(db.accountSymbolTable)..where((t) => t.code.equals(code)))
        .getSingleOrNull();
  }

  Future<List<AccountSymbol>> findByAccountBookIdAndType(
      String accountBookId, String symbolType) {
    return (db.select(db.accountSymbolTable)
          ..where((t) =>
              t.accountBookId.equals(accountBookId) &
              t.symbolType.equals(symbolType)))
        .get();
  }

  Future<int> createSymbol({
    required String id,
    required String name,
    required String code,
    required String accountBookId,
    required String symbolType,
    required String createdBy,
    required String updatedBy,
  }) {
    return insert(
      AccountSymbolTableCompanion.insert(
        id: id,
        name: name,
        code: code,
        accountBookId: accountBookId,
        symbolType: symbolType,
        createdBy: createdBy,
        updatedBy: updatedBy,
        createdAt: DateUtil.now(),
        updatedAt: DateUtil.now(),
      ),
    );
  }
}
