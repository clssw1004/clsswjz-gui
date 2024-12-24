import 'package:drift/drift.dart';
import 'base_table.dart';

@DataClassName('AccountBook')
class AccountBookTable extends BaseBusinessTable {
  TextColumn get name => text().named('name')();
  TextColumn get description => text().nullable().named('description')();
  TextColumn get currencySymbol =>
      text().named('currency_symbol').withDefault(const Constant('¥'))();
  TextColumn get icon => text().nullable().named('icon')();
}
