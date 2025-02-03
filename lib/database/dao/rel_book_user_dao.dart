import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/rel_accountbook_user_table.dart';
import 'base_dao.dart';

class RelBookUserDao
    extends BaseDao<RelAccountbookUserTable, RelAccountbookUser> {
  RelBookUserDao(super.db);

  Future<void> deleteByBook(String accountBookId) async {
    final query = db.delete(table)
      ..where((t) => t.accountBookId.equals(accountBookId));
    await query.go();
  }

  @override
  TableInfo<RelAccountbookUserTable, RelAccountbookUser> get table =>
      db.relAccountbookUserTable;
}
