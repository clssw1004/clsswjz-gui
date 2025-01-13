import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/rel_accountbook_user_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class MemberCULog extends LogBuilder<RelAccountbookUserTableCompanion, String> {
  MemberCULog() : super() {
    doWith(BusinessType.bookMember);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.relAccountbookUserDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.relAccountbookUserDao.update(businessId!, data!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return RelAccountbookUserTable.toJsonString(data as RelAccountbookUserTableCompanion);
    }
  }

  static MemberCULog create(String who, String bookId,
      {required String userId,
      bool canViewBook = true,
      bool canEditBook = false,
      bool canDeleteBook = false,
      bool canViewItem = true,
      bool canEditItem = false,
      bool canDeleteItem = false}) {
    return MemberCULog().who(who).inBook(bookId).doCreate().withData(RelAccountbookUserTable.toCreateCompanion(
        accountBookId: bookId,
        userId: userId,
        canViewBook: canViewBook,
        canEditBook: canEditBook,
        canDeleteBook: canDeleteBook,
        canViewItem: canViewItem,
        canEditItem: canEditItem,
        canDeleteItem: canDeleteItem)) as MemberCULog;
  }

  static MemberCULog update(String who, String bookId, String memberId,
      {bool? canViewBook, bool? canEditBook, bool? canDeleteBook, bool? canViewItem, bool? canEditItem, bool? canDeleteItem}) {
    return MemberCULog().who(who).inBook(bookId).target(memberId).doUpdate().withData(RelAccountbookUserTable.toUpdateCompanion(
        canViewBook: canViewBook,
        canEditBook: canEditBook,
        canDeleteBook: canDeleteBook,
        canViewItem: canViewItem,
        canEditItem: canEditItem,
        canDeleteItem: canDeleteItem)) as MemberCULog;
  }

  static MemberCULog fromCreateLog(LogSync log) {
    return MemberCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .doCreate()
        .withData(RelAccountbookUser.fromJson(jsonDecode(log.operateData)).toCompanion(true)) as MemberCULog;
  }

  static MemberCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return MemberCULog.update(
      log.operatorId,
      log.parentId,
      log.businessId,
      canViewBook: data['canViewBook'],
      canEditBook: data['canEditBook'],
      canDeleteBook: data['canDeleteBook'],
      canViewItem: data['canViewItem'],
      canEditItem: data['canEditItem'],
      canDeleteItem: data['canDeleteItem'],
    );
  }

  static MemberCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create ? MemberCULog.fromCreateLog(log) : MemberCULog.fromUpdateLog(log));
  }
}
