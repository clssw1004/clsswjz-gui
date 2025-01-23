import 'package:drift/drift.dart';
import '../../enums/symbol_type.dart';
import '../database.dart';
import '../tables/account_symbol_table.dart';
import 'base_dao.dart';

class SymbolDao extends BaseBookDao<AccountSymbolTable, AccountSymbol> {
  SymbolDao(super.db);

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

  Future<List<AccountSymbol>> listSymbolsByBook(String accountBookId, {SymbolType? symbolType}) {
    final query = (db.select(db.accountSymbolTable)..where((t) => t.accountBookId.equals(accountBookId)));
    if (symbolType != null) {
      query.where((t) => t.symbolType.equals(symbolType.code));
    }
    return query.get();
  }

  @override
  TableInfo<AccountSymbolTable, AccountSymbol> get table => db.accountSymbolTable;
}
