import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/account_fund_table.dart';
import 'base_dao.dart';

class FundDao extends BaseBookDao<AccountFundTable, AccountFund> {
  FundDao(super.db);

  Future<List<AccountFund>> findByType(String fundType) {
    return (db.select(db.accountFundTable)..where((t) => t.fundType.equals(fundType))).get();
  }

  /// 获取默认资金账户
  Future<AccountFund?> getDefaultFund(String userId) async {
    final fund =
        await (db.select(db.accountFundTable)..where((t) => t.createdBy.equals(userId) & t.isDefault.equals(true))).getSingleOrNull();
    if (fund == null) {}
    return fund;
  }

  @override
  TableInfo<AccountFundTable, AccountFund> get table => db.accountFundTable;
}
