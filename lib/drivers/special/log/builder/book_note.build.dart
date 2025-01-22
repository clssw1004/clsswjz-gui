import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/account_note_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class BookNoteBuilder extends LogBuilder<AccountNoteTableCompanion, String> {
  BookNoteBuilder() : super() {
    doWith(BusinessType.note);
  }
  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.accountNoteDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.accountNoteDao.update(businessId!, data!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return AccountNoteTable.toJsonString(data as AccountNoteTableCompanion);
    }
  }

  static BookNoteBuilder create(
    String who,
    String bookId, {
    required String title,
    String? content,
    required String noteDate,
  }) {
    return BookNoteBuilder().who(who).inBook(bookId).doCreate().withData(AccountNoteTable.toCreateCompanion(
          who,
          bookId,
          content: content,
          noteDate: noteDate,
        )) as BookNoteBuilder;
  }

  static BookNoteBuilder update(
    String userId,
    String bookId,
    String noteId, {
    String? content,
    String? noteDate,
  }) {
    return BookNoteBuilder().who(userId).inBook(bookId).target(noteId).doUpdate().withData(AccountNoteTable.toUpdateCompanion(
          userId,
          content: content,
          noteDate: noteDate,
        )) as BookNoteBuilder;
  }

  static BookNoteBuilder fromCreateLog(LogSync log) {
    return BookNoteBuilder()
        .who(log.operatorId)
        .inBook(log.parentId)
        .doCreate()
        .withData(AccountNote.fromJson(jsonDecode(log.operateData)).toCompanion(true)) as BookNoteBuilder;
  }

  static BookNoteBuilder fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return BookNoteBuilder.update(
      log.operatorId,
      log.parentId,
      log.businessId,
      content: data['content'],
      noteDate: data['noteDate'],
    );
  }

  static BookNoteBuilder fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create
        ? BookNoteBuilder.fromCreateLog(log)
        : BookNoteBuilder.fromUpdateLog(log));
  }
}
