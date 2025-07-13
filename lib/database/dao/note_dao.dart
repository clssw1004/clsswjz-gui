import 'package:clsswjz_gui/models/dto/note_filter_dto.dart';
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
      {int? limit, int? offset, NoteFilterDTO? filter}) {
    final query = (db.select(table)
      ..where((t) {
        var predicate = t.accountBookId.equals(accountBookId);
        if (filter != null) {
          final keyword = filter.keyword;
          if (keyword != null && keyword.isNotEmpty) {
            predicate = predicate &
                (t.title.like('%$keyword%') |
                    t.plainContent.like('%$keyword%'));
          }
          
          // 添加分组筛选
          final groupCodes = filter.groupCodes;
          if (groupCodes != null && groupCodes.isNotEmpty) {
            // 如果包含 'none'，则包含所有无分组的笔记
            if (groupCodes.contains('none')) {
              predicate = predicate & 
                  (t.groupCode.isNull() | t.groupCode.isIn(groupCodes));
            } else {
              // 只筛选指定的分组
              predicate = predicate & t.groupCode.isIn(groupCodes);
            }
          }
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
