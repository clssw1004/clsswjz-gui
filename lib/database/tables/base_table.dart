import 'package:drift/drift.dart';

@DataClassName('BaseEntity')
class BaseTable extends Table {
  TextColumn get id => text().named('id')();
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BaseBusinessEntity')
class BaseBusinessTable extends BaseTable {
  TextColumn get createdBy => text().named('created_by')();
  TextColumn get updatedBy => text().named('updated_by')();
}
