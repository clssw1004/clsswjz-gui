import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/account_note_table.dart';
import 'base_dao.dart';

class NoteDao extends BaseBookDao<AccountNoteTable, AccountNote> {
  NoteDao(super.db);

  @override
  TableInfo<AccountNoteTable, AccountNote> get table => db.accountNoteTable;

  @override
  Future<List<AccountNote>> listByBook(String accountBookId,
      {int? limit, int? offset, String? keyword}) {
    final query = (db.select(table)
      ..where((t) {
        var predicate = t.accountBookId.equals(accountBookId);
        if (keyword != null && keyword.isNotEmpty) {
          predicate = predicate & 
            (t.title.like('%$keyword%') | t.plainContent.like('%$keyword%'));
        }
        return predicate;
      })
      ..orderBy(defaultOrderBy()));
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }
}
