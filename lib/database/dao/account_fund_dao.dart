import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';
import '../tables/account_fund_table.dart';
import 'base_dao.dart';

class AccountFundDao extends BaseDao<AccountFundTable, AccountFund> {
  AccountFundDao(super.db);

  Future<List<AccountFund>> findByAccountBookId(String accountBookId) {
    final query = db.select(db.accountFundTable).join([
      innerJoin(
        db.relAccountbookFundTable,
        db.relAccountbookFundTable.fundId.equalsExp(
          db.accountFundTable.id,
        ),
      ),
    ])
      ..where(db.relAccountbookFundTable.accountBookId.equals(accountBookId));

    return query.map((row) => row.readTable(db.accountFundTable)).get();
  }

  Future<List<AccountFund>> findByType(String fundType) {
    return (db.select(db.accountFundTable)
          ..where((t) => t.fundType.equals(fundType)))
        .get();
  }

  Future<void> createFund({
    required String id,
    required String name,
    required String fundType,
    required String createdBy,
    required String updatedBy,
    String? fundRemark,
    double fundBalance = 0.00,
  }) {
    return insert(
      AccountFundTableCompanion.insert(
        id: id,
        name: name,
        fundType: fundType,
        fundRemark: Value(fundRemark),
        fundBalance: Value(fundBalance),
        createdBy: createdBy,
        updatedBy: updatedBy,
        createdAt: DateUtil.now(),
        updatedAt: DateUtil.now(),
      ),
    );
  }

  Future<void> updateBalance(AccountFund fund, double newBalance) async {
    await update(
        fund.id,
        AccountFundTableCompanion(
          fundBalance: Value(newBalance),
        ));
  }

  @override
  TableInfo<AccountFundTable, AccountFund> get table => db.accountFundTable;
}
