import 'package:drift/drift.dart';
import 'base_table.dart';

@DataClassName('RelAccountbookFund')
class RelAccountbookFundTable extends BaseTable {
  TextColumn get accountBookId => text().named('account_book_id')();
  TextColumn get fundId => text().named('fund_id')();
  BoolColumn get fundIn =>
      boolean().named('fund_in').withDefault(const Constant(true))();
  BoolColumn get fundOut =>
      boolean().named('fund_out').withDefault(const Constant(true))();
  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();
}
