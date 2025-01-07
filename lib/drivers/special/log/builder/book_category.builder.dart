import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/account_category_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

abstract class AbstractBookCategoryLog<T, RunResult>
    extends LogBuilder<T, RunResult> {
  AbstractBookCategoryLog() {
    doWith(BusinessType.category);
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return AccountCategoryTable.toJsonString(
          data as AccountCategoryTableCompanion);
    }
  }
}

class CreateBookCategoryLog
    extends AbstractBookCategoryLog<AccountCategoryTableCompanion, String> {
  CreateBookCategoryLog() : super() {
    operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    await DaoManager.accountCategoryDao.insert(data!);
    subject(data!.id.value);
    return data!.id.value;
  }

  static CreateBookCategoryLog build(String who, String bookId,
      {required String name, required String categoryType}) {
    return CreateBookCategoryLog()
        .who(who)
        .inBook(bookId)
        .withData(AccountCategoryTable.toCreateCompanion(
          who,
          bookId,
          name: name,
          categoryType: categoryType,
        )) as CreateBookCategoryLog;
  }

  static LogBuilder<AccountCategoryTableCompanion, String> fromLog(
      LogSync log) {
    return CreateBookCategoryLog()
        .who(log.operatorId)
        .inBook(log.accountBookId)
        .withData(AccountCategory.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as CreateBookCategoryLog;
  }
}

class UpdateBookCategoryLog
    extends AbstractBookCategoryLog<AccountCategoryTableCompanion, void> {
  UpdateBookCategoryLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    await DaoManager.accountCategoryDao.update(businessId!, data!);
  }

  static UpdateBookCategoryLog build(
      String userId, String bookId, String categoryId,
      {String? name, DateTime? lastAccountItemAt}) {
    return UpdateBookCategoryLog()
        .who(userId)
        .inBook(bookId)
        .subject(categoryId)
        .withData(AccountCategoryTable.toUpdateCompanion(
          userId,
          name: name,
          lastAccountItemAt: lastAccountItemAt,
        )) as UpdateBookCategoryLog;
  }

  static LogBuilder<AccountCategoryTableCompanion, void> fromLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return UpdateBookCategoryLog.build(
        log.operatorId, log.accountBookId, log.businessId,
        name: data['name'], lastAccountItemAt: data['lastAccountItemAt']);
  }
}
