import 'dart:convert';

import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import '../../../../database/tables/account_item_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import 'builder.dart';

class ItemCULog extends LogBuilder<AccountItemTableCompanion, String> {
  ItemCULog() : super() {
    doWith(BusinessType.item);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.accountItemDao.insert(data!);
      subject(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.accountItemDao.update(businessId!, data!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return AccountItemTable.toJsonString(data as AccountItemTableCompanion);
    }
  }

  static ItemCULog create(String who, String bookId,
      {required amount,
      String? description,
      required String type,
      String? categoryCode,
      required String accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode}) {
    return ItemCULog().who(who).inBook(bookId).doCreate().withData(
        AccountItemTable.toCreateCompanion(who, bookId,
            amount: amount,
            description: description,
            type: type,
            categoryCode: categoryCode,
            accountDate: accountDate,
            fundId: fundId,
            shopCode: shopCode,
            tagCode: tagCode,
            projectCode: projectCode)) as ItemCULog;
  }

  static ItemCULog update(String userId, String bookId, String itemId,
      {double? amount,
      String? description,
      String? type,
      String? categoryCode,
      String? accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode}) {
    return ItemCULog()
        .who(userId)
        .inBook(bookId)
        .subject(itemId)
        .doUpdate()
        .withData(AccountItemTable.toUpdateCompanion(userId,
            amount: amount,
            description: description,
            type: type,
            categoryCode: categoryCode,
            accountDate: accountDate,
            fundId: fundId,
            shopCode: shopCode,
            tagCode: tagCode,
            projectCode: projectCode)) as ItemCULog;
  }

  static ItemCULog fromCreateLog(LogSync log) {
    return ItemCULog()
        .who(log.operatorId)
        .inBook(log.accountBookId)
        .doCreate()
        .withData(AccountItem.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as ItemCULog;
  }

  static ItemCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return ItemCULog.update(
      log.operatorId,
      log.accountBookId,
      log.businessId,
      amount: data['amount'],
      description: data['description'],
      type: data['type'],
      categoryCode: data['categoryCode'],
      accountDate: data['accountDate'],
      fundId: data['fundId'],
      shopCode: data['shopCode'],
      tagCode: data['tagCode'],
      projectCode: data['projectCode'],
    );
  }

  static ItemCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create
        ? ItemCULog.fromCreateLog(log)
        : ItemCULog.fromUpdateLog(log));
  }
}
