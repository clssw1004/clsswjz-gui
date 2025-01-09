import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('RelAccountbookUser')
class RelAccountbookUserTable extends BaseTable {
  TextColumn get userId => text().named('user_id')();
  TextColumn get accountBookId => text().named('account_book_id')();
  BoolColumn get canViewBook => boolean().named('can_view_book').withDefault(const Constant(true))();
  BoolColumn get canEditBook => boolean().named('can_edit_book').withDefault(const Constant(false))();
  BoolColumn get canDeleteBook => boolean().named('can_delete_book').withDefault(const Constant(false))();
  BoolColumn get canViewItem => boolean().named('can_view_item').withDefault(const Constant(true))();
  BoolColumn get canEditItem => boolean().named('can_edit_item').withDefault(const Constant(false))();
  BoolColumn get canDeleteItem => boolean().named('can_delete_item').withDefault(const Constant(false))();

  static RelAccountbookUserTableCompanion toUpdateCompanion({
    bool? canViewBook,
    bool? canEditBook,
    bool? canDeleteBook,
    bool? canViewItem,
    bool? canEditItem,
    bool? canDeleteItem,
  }) {
    return RelAccountbookUserTableCompanion(
      updatedAt: Value(DateUtil.now()),
      canViewBook: Value.absentIfNull(canViewBook),
      canEditBook: Value.absentIfNull(canEditBook),
      canDeleteBook: Value.absentIfNull(canDeleteBook),
      canViewItem: Value.absentIfNull(canViewItem),
      canEditItem: Value.absentIfNull(canEditItem),
      canDeleteItem: Value.absentIfNull(canDeleteItem),
    );
  }

  static RelAccountbookUserTableCompanion toCreateCompanion({
    required String userId,
    required String accountBookId,
    bool canViewBook = true,
    bool canEditBook = false,
    bool canDeleteBook = false,
    bool canViewItem = true,
    bool canEditItem = false,
    bool canDeleteItem = false,
  }) =>
      RelAccountbookUserTableCompanion(
        id: Value(IdUtil.genId()),
        userId: Value(userId),
        accountBookId: Value(accountBookId),
        canViewBook: Value(canViewBook),
        canEditBook: Value(canEditBook),
        canDeleteBook: Value(canDeleteBook),
        canViewItem: Value(canViewItem),
        canEditItem: Value(canEditItem),
        canDeleteItem: Value(canDeleteItem),
        createdAt: Value(DateUtil.now()),
        updatedAt: Value(DateUtil.now()),
      );

  static String toJsonString(RelAccountbookUserTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'userId', companion.userId);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'canViewBook', companion.canViewBook);
    MapUtil.setIfPresent(map, 'canEditBook', companion.canEditBook);
    MapUtil.setIfPresent(map, 'canDeleteBook', companion.canDeleteBook);
    MapUtil.setIfPresent(map, 'canViewItem', companion.canViewItem);
    MapUtil.setIfPresent(map, 'canEditItem', companion.canEditItem);
    MapUtil.setIfPresent(map, 'canDeleteItem', companion.canDeleteItem);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    return jsonEncode(map);
  }
}
