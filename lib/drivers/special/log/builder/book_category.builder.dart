import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/account_category_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class CategoryCULog extends LogBuilder<AccountCategoryTableCompanion, String> {
  CategoryCULog() : super() {
    doWith(BusinessType.category);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.categoryDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.categoryDao.update(businessId!, data!);
    }
    return businessId!;
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

  static CategoryCULog create(String who, String bookId,
      {required String name, required String categoryType, String? code}) {
    return CategoryCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(AccountCategoryTable.toCreateCompanion(
          who,
          bookId,
          name: name,
          categoryType: categoryType,
          code: code,
        )) as CategoryCULog;
  }

  static CategoryCULog update(String userId, String bookId, String categoryId,
      {String? name, DateTime? lastAccountItemAt}) {
    return CategoryCULog()
        .who(userId)
        .inBook(bookId)
        .target(categoryId)
        .doUpdate()
        .withData(AccountCategoryTable.toUpdateCompanion(
          userId,
          name: name,
          lastAccountItemAt: lastAccountItemAt,
        )) as CategoryCULog;
  }

  static CategoryCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create
        ? CategoryCULog.fromCreateLog(log)
        : CategoryCULog.fromUpdateLog(log));
  }

  static CategoryCULog fromCreateLog(LogSync log) {
    return CategoryCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .doCreate()
        .withData(AccountCategory.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as CategoryCULog;
  }

  static CategoryCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return CategoryCULog.update(log.operatorId, log.parentId, log.businessId,
        name: data['name'], lastAccountItemAt: data['lastAccountItemAt']);
  }
}
