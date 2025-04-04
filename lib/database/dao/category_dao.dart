import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/account_category_table.dart';
import 'base_dao.dart';

class CategoryDao extends BaseBookDao<AccountCategoryTable, AccountCategory> {
  CategoryDao(super.db);

  Future<List<AccountCategory>> findByCodes(List<String> codes) {
    return (db.select(db.accountCategoryTable)
          ..where((t) => t.code.isIn(codes)))
        .get();
  }

  Future<AccountCategory?> findByBookAndCode(String bookId, String code) {
    return (db.select(db.accountCategoryTable)
          ..where((t) => t.accountBookId.equals(bookId) & t.code.equals(code)))
        .getSingleOrNull();
  }

  Future<AccountCategory?> findByBookAndName(String bookId, String name) {
    return (db.select(db.accountCategoryTable)
          ..where((t) => t.accountBookId.equals(bookId) & t.name.equals(name)))
        .getSingleOrNull();
  }

  Future<List<AccountCategory>> listCategoriesByBook(String accountBookId,
      {String? categoryType}) {
    final query = db.select(db.accountCategoryTable)
      ..where((t) => t.accountBookId.equals(accountBookId));
    if (categoryType != null) {
      query.where((t) => t.categoryType.equals(categoryType));
    }
    query.orderBy([
      (t) => OrderingTerm.desc(t.lastAccountItemAt),
      (t) => OrderingTerm.desc(t.createdAt),
    ]);

    return query.get();
  }

  Future<bool> checkCategoryName(
      String bookId, String categoryType, String name) async {
    final categories = await (db.select(db.accountCategoryTable)
          ..where((t) =>
              t.accountBookId.equals(bookId) &
              t.categoryType.equals(categoryType) &
              t.name.equals(name)))
        .get();
    return categories.isNotEmpty;
  }

  @override
  TableInfo<AccountCategoryTable, AccountCategory> get table =>
      db.accountCategoryTable;
}
