import 'dart:convert';

import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import '../../../../database/tables/account_item_table.dart';
import '../../../../enums/account_type.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../models/vo/attachment_vo.dart';
import 'builder.dart';

class ItemCULog extends LogBuilder<AccountItemTableCompanion, String> {
  ItemCULog() : super() {
    doWith(BusinessType.item);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.itemDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.itemDao.update(businessId!, data!);
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
      required AccountItemType type,
      String? categoryCode,
      required String accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode,
      String? source,
      String? sourceId,
      List<AttachmentVO>? attachments}) {
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
            projectCode: projectCode,
            source: source,
            sourceId: sourceId)) as ItemCULog;
  }

  static ItemCULog update(String userId, String bookId, String itemId,
      {double? amount,
      String? description,
      AccountItemType? type,
      String? categoryCode,
      String? accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode}) {
    return ItemCULog()
        .who(userId)
        .inBook(bookId)
        .target(itemId)
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
        .inBook(log.parentId)
        .doCreate()
        .withData(AccountItem.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as ItemCULog;
  }

  static ItemCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return ItemCULog.update(
      log.operatorId,
      log.parentId,
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
