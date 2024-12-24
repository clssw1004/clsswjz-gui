import 'package:drift/drift.dart';
import 'base_table.dart';

@DataClassName('RelAccountbookUser')
class RelAccountbookUserTable extends BaseTable {
  TextColumn get userId => text().named('user_id')();
  TextColumn get accountBookId => text().named('account_book_id')();
  BoolColumn get canViewBook =>
      boolean().named('can_view_book').withDefault(const Constant(true))();
  BoolColumn get canEditBook =>
      boolean().named('can_edit_book').withDefault(const Constant(false))();
  BoolColumn get canDeleteBook =>
      boolean().named('can_delete_book').withDefault(const Constant(false))();
  BoolColumn get canViewItem =>
      boolean().named('can_view_item').withDefault(const Constant(true))();
  BoolColumn get canEditItem =>
      boolean().named('can_edit_item').withDefault(const Constant(false))();
  BoolColumn get canDeleteItem =>
      boolean().named('can_delete_item').withDefault(const Constant(false))();
}
