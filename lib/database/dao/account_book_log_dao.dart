import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/account_book_log_table.dart';
import 'base_dao.dart';

class AccountBookLogDao extends BaseDao<AccountBookLogTable, AccountBookLog> {
  AccountBookLogDao(super.db);

  @override
  TableInfo<AccountBookLogTable, AccountBookLog> get table =>
      db.accountBookLogTable;
}
