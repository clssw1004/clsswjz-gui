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

  /// 一次性加载账本下全量分类（含排序），用于构建树
  Future<List<AccountCategory>> listAllByBook(String accountBookId,
      {String? categoryType}) {
    final query = db.select(db.accountCategoryTable)
      ..where((t) => t.accountBookId.equals(accountBookId));
    if (categoryType != null) {
      query.where((t) => t.categoryType.equals(categoryType));
    }
    query.orderBy([
      (t) => OrderingTerm.asc(t.sortOrder),
      (t) => OrderingTerm.desc(t.createdAt),
    ]);
    return query.get();
  }

  /// 查直接子节点
  Future<List<AccountCategory>> findChildren(String parentId) {
    return (db.select(db.accountCategoryTable)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .get();
  }

  /// 查某父节点下最大 sortOrder
  Future<int> getMaxSortOrder(String? parentId, String bookId) async {
    final query = db.select(db.accountCategoryTable)
      ..where((t) => t.accountBookId.equals(bookId));
    if (parentId != null) {
      query.where((t) => t.parentId.equals(parentId));
    } else {
      query.where((t) => t.parentId.isNull());
    }
    final orders = await query.map((row) => row.sortOrder).get();
    return orders.isEmpty ? 0 : orders.reduce((a, b) => a > b ? a : b);
  }

  /// 获取所有子孙节点 IDs（递归）
  Future<List<String>> getAllDescendantIds(String parentId) async {
    final result = <String>[];
    final children = await findChildren(parentId);
    for (final child in children) {
      result.add(child.id);
      result.addAll(await getAllDescendantIds(child.id));
    }
    return result;
  }

  @override
  TableInfo<AccountCategoryTable, AccountCategory> get table =>
      db.accountCategoryTable;
}
