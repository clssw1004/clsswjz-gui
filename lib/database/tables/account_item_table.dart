import 'package:drift/drift.dart';
import 'base_table.dart';

@DataClassName('AccountItem')
class AccountItemTable extends BaseBusinessTable {
  RealColumn get amount => real().named('amount')();
  TextColumn get description => text().nullable().named('description')();
  TextColumn get type => text().named('type')();
  TextColumn get categoryCode => text().nullable().named('category_code')();
  TextColumn get accountDate => text().named('account_date')();
  TextColumn get accountBookId => text().named('account_book_id')();
  TextColumn get fundId => text().nullable().named('fund_id')();
  TextColumn get shopCode => text().nullable().named('shop_code')();
  TextColumn get tagCode => text().nullable().named('tag_code')();
  TextColumn get projectCode => text().nullable().named('project_code')();
}
