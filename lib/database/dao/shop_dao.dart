import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';
import '../tables/account_shop_table.dart';
import 'base_dao.dart';

class ShopDao extends DateBaseBookDao<AccountShopTable, AccountShop> {
  ShopDao(super.db);

  Future<List<AccountShop>> findByCodes(List<String> codes) {
    return (db.select(db.accountShopTable)..where((t) => t.code.isIn(codes)))
        .get();
  }

  Future<AccountShop?> findByCode(String code) {
    return (db.select(db.accountShopTable)..where((t) => t.code.equals(code)))
        .getSingleOrNull();
  }

  Future<AccountShop?> findByBookAndCode(String bookId, String code) {
    return (db.select(db.accountShopTable)
          ..where((t) => t.accountBookId.equals(bookId) & t.code.equals(code)))
        .getSingleOrNull();
  }

  Future<AccountShop?> findByBookAndName(String bookId, String name) {
    return (db.select(db.accountShopTable)
          ..where((t) => t.accountBookId.equals(bookId) & t.name.equals(name)))
        .getSingleOrNull();
  }

  Future<void> createShop({
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

  /// 一次性加载账本下全量商户（含排序），用于构建树
  Future<List<AccountShop>> listAllByBook(String accountBookId) {
    final query = db.select(db.accountShopTable)
      ..where((t) => t.accountBookId.equals(accountBookId))
      ..orderBy([
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return query.get();
  }

  /// 查直接子节点
  Future<List<AccountShop>> findChildren(String parentId) {
    return (db.select(db.accountShopTable)
          ..where((t) => t.parentId.equals(parentId))
          ..orderBy([
            (t) => OrderingTerm.asc(t.sortOrder),
          ]))
        .get();
  }

  /// 查某父节点下最大 sortOrder
  Future<int> getMaxSortOrder(String? parentId, String bookId) async {
    final query = db.select(db.accountShopTable)
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
  TableInfo<AccountShopTable, AccountShop> get table => db.accountShopTable;
}
