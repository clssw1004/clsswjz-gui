import 'package:drift/drift.dart';

@DataClassName('StringIdEntity')
class StringIdTable extends Table {
  TextColumn get id => text().named('id')();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BaseEntity')
class BaseTable extends StringIdTable {
  IntColumn get createdAt => integer().named('created_at')();
  IntColumn get updatedAt => integer().named('updated_at')();
}

@DataClassName('BaseBusinessEntity')
class BaseBusinessTable extends BaseTable {
  TextColumn get createdBy => text().named('created_by')();
  TextColumn get updatedBy => text().named('updated_by')();
}
