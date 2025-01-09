import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';
import '../tables/account_shop_table.dart';
import 'base_dao.dart';

class AccountShopDao extends BaseDao<AccountShopTable, AccountShop> {
  AccountShopDao(super.db);

  Future<List<AccountShop>> findByCodes(List<String> codes) {
    return (db.select(db.accountShopTable)..where((t) => t.code.isIn(codes))).get();
  }

  Future<List<AccountShop>> findByAccountBookId(String accountBookId) {
    return (db.select(db.accountShopTable)..where((t) => t.accountBookId.equals(accountBookId))).get();
  }

  Future<AccountShop?> findByCode(String code) {
    return (db.select(db.accountShopTable)..where((t) => t.code.equals(code))).getSingleOrNull();
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

  @override
  // TODO: implement table
  TableInfo<AccountShopTable, AccountShop> get table => db.accountShopTable;
}
