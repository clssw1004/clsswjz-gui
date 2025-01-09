import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/account_fund_table.dart';
import 'base_dao.dart';

class AccountFundDao extends BaseBookDao<AccountFundTable, AccountFund> {
  AccountFundDao(super.db);

  Future<List<AccountFund>> findByType(String fundType) {
    return (db.select(db.accountFundTable)..where((t) => t.fundType.equals(fundType))).get();
  }

  @override
  TableInfo<AccountFundTable, AccountFund> get table => db.accountFundTable;
}
