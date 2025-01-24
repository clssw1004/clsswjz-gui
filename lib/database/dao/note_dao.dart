import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/account_note_table.dart';
import 'base_dao.dart';

class NoteDao extends BaseBookDao<AccountNoteTable, AccountNote> {
  NoteDao(super.db);

  @override
  TableInfo<AccountNoteTable, AccountNote> get table => db.accountNoteTable;

  @override
  List<OrderClauseGenerator<AccountNoteTable>> defaultOrderBy() {
    return [
      (t) => OrderingTerm.desc(t.noteDate),
    ];
  }
}
