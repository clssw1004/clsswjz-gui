import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('AccountNote')
class AccountNoteTable extends BaseAccountBookTable {
  TextColumn get title => text().nullable().named('title')();
  TextColumn get content =>
      text().nullable().named('content').withLength(max: 4294967295)();
  TextColumn get noteType => text().named('note_type')();
  TextColumn get plainContent =>
      text().nullable().named('plain_content').withLength(max: 4294967295)();
  TextColumn get groupCode => text().nullable().named('groupCode')();

  static AccountNoteTableCompanion toUpdateCompanion(
    String who, {
    String? title,
    String? content,
    String? plainContent,
    String? accountBookId,
    String? groupCode,
  }) {
    return AccountNoteTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      title: Value.absentIfNull(title),
      content: Value.absentIfNull(content),
      plainContent: Value.absentIfNull(plainContent),
      groupCode: Value.absentIfNull(groupCode),
      accountBookId: Value.absentIfNull(accountBookId),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
    );
  }

  static AccountNoteTableCompanion toCreateCompanion(
    String who,
    String accountBookId, {
    String? title,
    String? noteType,
    String? content,
    String? plainContent,
    String? groupCode,
  }) =>
      AccountNoteTableCompanion(
        id: Value(IdUtil.genId()),
        accountBookId: Value(accountBookId),
        title: Value.absentIfNull(title),
        noteType: Value.absentIfNull(noteType),
        content: Value.absentIfNull(content),
        plainContent: Value.absentIfNull(plainContent),
        groupCode: Value.absentIfNull(groupCode),
        createdBy: Value(who),
        createdAt: Value(DateUtil.now()),
        updatedBy: Value(who),
        updatedAt: Value(DateUtil.now()),
      );

  static String toJsonString(AccountNoteTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'title', companion.title);
    MapUtil.setIfPresent(map, 'content', companion.content);
    MapUtil.setIfPresent(map, 'noteType', companion.noteType);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'groupCode', companion.groupCode);
    return jsonEncode(map);
  }
}
