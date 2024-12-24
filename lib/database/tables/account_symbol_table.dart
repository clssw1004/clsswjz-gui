import 'package:drift/drift.dart';
import 'base_table.dart';

@DataClassName('AccountSymbol')
class AccountSymbolTable extends BaseBusinessTable {
  TextColumn get name => text().named('name')();
  TextColumn get code => text().named('code')();
  TextColumn get accountBookId => text().named('account_book_id')();
  TextColumn get symbolType => text().named('symbol_type')();
}
