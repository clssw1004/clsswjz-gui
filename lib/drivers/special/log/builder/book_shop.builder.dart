import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/account_shop_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class ShopCULog extends LogBuilder<AccountShopTableCompanion, String> {
  ShopCULog() : super() {
    doWith(BusinessType.shop);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.accountShopDao.insert(data!);
      subject(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.accountShopDao.update(businessId!, data!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return AccountShopTable.toJsonString(data as AccountShopTableCompanion);
    }
  }

  static ShopCULog create(String who, String bookId, {required String name}) {
    return ShopCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(AccountShopTable.toCreateCompanion(
          who,
          bookId,
          name: name,
        )) as ShopCULog;
  }

  static ShopCULog update(String userId, String bookId, String shopId,
      {required String name}) {
    return ShopCULog()
        .who(userId)
        .inBook(bookId)
        .subject(shopId)
        .doUpdate()
        .withData(AccountShopTable.toUpdateCompanion(
          userId,
          name: name,
        )) as ShopCULog;
  }

  static ShopCULog fromCreateLog(LogSync log) {
    return ShopCULog()
            .who(log.operatorId)
            .inBook(log.accountBookId)
            .doCreate()
            .withData(AccountShop.fromJson(jsonDecode(log.operateData)))
        as ShopCULog;
  }

  static ShopCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return ShopCULog.update(log.operatorId, log.accountBookId, log.businessId,
        name: data['name']);
  }

  static ShopCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create
        ? ShopCULog.fromCreateLog(log)
        : ShopCULog.fromUpdateLog(log));
  }
}
