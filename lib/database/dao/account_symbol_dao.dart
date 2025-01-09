import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';
import '../tables/account_symbol_table.dart';
import 'base_dao.dart';

class AccountSymbolDao extends BaseDao<AccountSymbolTable, AccountSymbol> {
  AccountSymbolDao(super.db);

  Future<List<AccountSymbol>> findByAccountBookId(String accountBookId) {
    return (db.select(db.accountSymbolTable)..where((t) => t.accountBookId.equals(accountBookId))).get();
  }

  Future<List<AccountSymbol>> findByType(String symbolType) {
    return (db.select(db.accountSymbolTable)..where((t) => t.symbolType.equals(symbolType))).get();
  }

  Future<List<AccountSymbol>> findByTypes(List<String> symbolTypes) {
    return (db.select(db.accountSymbolTable)..where((t) => t.symbolType.isIn(symbolTypes))).get();
  }

  Future<List<AccountSymbol>> findByTypeAndCodes(String symbolType, List<String> codes) {
    return (db.select(db.accountSymbolTable)..where((t) => t.symbolType.equals(symbolType) & t.code.isIn(codes))).get();
  }

  Future<AccountSymbol?> findByCode(String code) {
    return (db.select(db.accountSymbolTable)..where((t) => t.code.equals(code))).getSingleOrNull();
  }

  Future<List<AccountSymbol>> findByAccountBookIdAndType(String accountBookId, String symbolType) {
    return (db.select(db.accountSymbolTable)
          ..where((t) => t.accountBookId.equals(accountBookId) & t.symbolType.equals(symbolType)))
        .get();
  }

  Future<void> createSymbol({
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

  @override
  TableInfo<AccountSymbolTable, AccountSymbol> get table => db.accountSymbolTable;
}
