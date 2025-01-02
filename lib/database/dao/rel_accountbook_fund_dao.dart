import 'package:clsswjz/database/dao/base_dao.dart';
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/rel_accountbook_fund_table.dart';

class RelAccountbookFundDao
    extends BaseDao<RelAccountbookFundTable, RelAccountbookFund> {
  RelAccountbookFundDao(super.db);

  @override
  TableInfo<RelAccountbookFundTable, RelAccountbookFund> get table =>
      db.relAccountbookFundTable;
}
