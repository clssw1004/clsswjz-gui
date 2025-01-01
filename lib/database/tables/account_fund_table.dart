import 'package:drift/drift.dart';
import 'base_table.dart';

@DataClassName('AccountFund')
class AccountFundTable extends BaseBusinessTable {
  TextColumn get name => text().named('name')();
  TextColumn get fundType => text().named('fund_type')();
  TextColumn get fundRemark => text().nullable().named('fund_remark')();
  RealColumn get fundBalance =>
      real().named('fund_balance').withDefault(const Constant(0.00))();
  BoolColumn get isDefault => boolean()
      .named('is_default')
      .nullable()
      .withDefault(const Constant(false))();
}
