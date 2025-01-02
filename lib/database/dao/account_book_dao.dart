import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/account_book_table.dart';
import 'base_dao.dart';

class AccountBookDao extends BaseDao<AccountBookTable, AccountBook> {
  AccountBookDao(super.db);

  Future<List<AccountBook>> findPermissionedByUserId(String userId) {
    final query = db.select(db.accountBookTable).join([
      innerJoin(
        db.relAccountbookUserTable,
        db.relAccountbookUserTable.accountBookId.equalsExp(
          db.accountBookTable.id,
        ),
      ),
    ])
      ..where(db.relAccountbookUserTable.userId.equals(userId) &
          db.relAccountbookUserTable.canViewBook.equals(true));

    return query.map((row) => row.readTable(db.accountBookTable)).get();
  }

  Future<List<AccountBook>> findByCreatedBy(String userId) {
    return (db.select(db.accountBookTable)
          ..where((t) => t.createdBy.equals(userId)))
        .get();
  }

  @override
  TableInfo<AccountBookTable, AccountBook> get table => db.accountBookTable;
}
