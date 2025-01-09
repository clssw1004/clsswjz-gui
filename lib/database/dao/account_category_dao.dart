import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';
import '../tables/account_category_table.dart';
import 'base_dao.dart';

class AccountCategoryDao extends BaseDao<AccountCategoryTable, AccountCategory> {
  AccountCategoryDao(super.db);

  Future<List<AccountCategory>> findByCodes(List<String> codes) {
    return (db.select(db.accountCategoryTable)..where((t) => t.code.isIn(codes))).get();
  }

  Future<List<AccountCategory>> findByAccountBookId(String accountBookId) {
    return (db.select(db.accountCategoryTable)..where((t) => t.accountBookId.equals(accountBookId))).get();
  }

  Future<List<AccountCategory>> findByAccountBookIdAndType(String accountBookId, String categoryType) {
    return (db.select(db.accountCategoryTable)
          ..where((t) => t.accountBookId.equals(accountBookId) & t.categoryType.equals(categoryType)))
        .get();
  }

  Future<void> createCategory({
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

  @override
  TableInfo<AccountCategoryTable, AccountCategory> get table => db.accountCategoryTable;
}
