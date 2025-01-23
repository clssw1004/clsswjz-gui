import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/rel_accountbook_user_table.dart';
import 'base_dao.dart';

class RelBookUserDao extends BaseDao<RelAccountbookUserTable, RelAccountbookUser> {
  RelBookUserDao(super.db);

  @override
  TableInfo<RelAccountbookUserTable, RelAccountbookUser> get table => db.relAccountbookUserTable;
}
