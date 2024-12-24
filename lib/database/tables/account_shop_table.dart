import 'package:drift/drift.dart';
import 'base_table.dart';

@DataClassName('AccountShop')
class AccountShopTable extends BaseBusinessTable {
  TextColumn get name => text().named('name')();
  TextColumn get code => text().named('code')();
  TextColumn get accountBookId => text().named('account_book_id')();
}
