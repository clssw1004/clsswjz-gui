import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/rel_accountbook_user_table.dart';
import 'base_dao.dart';

class RelAccountbookUserDao extends BaseDao<RelAccountbookUserTable, RelAccountbookUser> {
  RelAccountbookUserDao(super.db);

  @override
  TableInfo<RelAccountbookUserTable, RelAccountbookUser> get table => db.relAccountbookUserTable;
}
