import 'package:drift/drift.dart';
import 'base_table.dart';

@DataClassName('AccountCategory')
class AccountCategoryTable extends BaseBusinessTable {
  TextColumn get name => text().named('name')();
  TextColumn get code => text().named('code')();
  TextColumn get accountBookId => text().named('account_book_id')();
  TextColumn get categoryType => text().named('category_type')();
  DateTimeColumn get lastAccountItemAt =>
      dateTime().nullable().named('last_account_item_at')();
}
