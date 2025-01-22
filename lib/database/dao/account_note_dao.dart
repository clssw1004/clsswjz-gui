import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/account_note_table.dart';
import 'base_dao.dart';

class AccountNoteDao extends BaseBookDao<AccountNoteTable, AccountNote> {
  AccountNoteDao(super.db);

  @override
  TableInfo<AccountNoteTable, AccountNote> get table => db.accountNoteTable;
}
