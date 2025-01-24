import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/account_note_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class NoteCULog extends LogBuilder<AccountNoteTableCompanion, String> {
  NoteCULog() : super() {
    doWith(BusinessType.note);
  }
  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.noteDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.noteDao.update(businessId!, data!);
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

  static NoteCULog create(
    String who,
    String bookId, {
    String? title,
    String? content,
  }) {
    return NoteCULog().who(who).inBook(bookId).doCreate().withData(AccountNoteTable.toCreateCompanion(
          who,
          bookId,
          title: title,
          content: content,
        )) as NoteCULog;
  }

  static NoteCULog update(
    String userId,
    String bookId,
    String noteId, {
    String? title,
    String? content,
    String? noteDate,
  }) {
    return NoteCULog().who(userId).inBook(bookId).target(noteId).doUpdate().withData(AccountNoteTable.toUpdateCompanion(
          userId,
          title: title,
          content: content,
          noteDate: noteDate,
        )) as NoteCULog;
  }

  static NoteCULog fromCreateLog(LogSync log) {
    return NoteCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .doCreate()
        .withData(AccountNote.fromJson(jsonDecode(log.operateData)).toCompanion(true)) as NoteCULog;
  }

  static NoteCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return NoteCULog.update(
      log.operatorId,
      log.parentId,
      log.businessId,
      title: data['title'],
      content: data['content'],
      noteDate: data['noteDate'],
    );
  }

  static NoteCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create ? NoteCULog.fromCreateLog(log) : NoteCULog.fromUpdateLog(log));
  }
}
