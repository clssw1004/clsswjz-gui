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
  List<OrderClauseGenerator<AccountNoteTable>> defaultOrderBy() {
    return [
      (t) => OrderingTerm.desc(t.updatedAt),
      (t) => OrderingTerm.desc(t.createdAt),
    ];
  }

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

          // 添加笔记类型筛选
          final noteType = filter.noteType;
          if (noteType != null && noteType.isNotEmpty) {
            predicate = predicate & t.noteType.equals(noteType);
          }

          // 添加作用域筛选
          final scope = filter.scope;
          if (scope != null && scope.isNotEmpty) {
            predicate = predicate & t.scope.equals(scope);
          }
        } else {
          // 默认只显示账本笔记
          predicate = predicate & t.scope.equals('book');
        }
        return predicate;
      })
      ..orderBy(defaultOrderBy()));
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }

  /// 获取全局笔记（不依赖账本的笔记）
  Future<List<AccountNote>> listGlobalNotes({
    int? limit,
    int? offset,
    NoteFilterDTO? filter,
  }) {
    final query = (db.select(table)
      ..where((t) {
        var predicate = t.scope.equals('global');
        if (filter != null) {
          final keyword = filter.keyword;
          if (keyword != null && keyword.isNotEmpty) {
            predicate = predicate &
                (t.title.like('%$keyword%') |
                    t.plainContent.like('%$keyword%'));
          }
          final noteType = filter.noteType;
          if (noteType != null && noteType.isNotEmpty) {
            predicate = predicate & t.noteType.equals(noteType);
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
