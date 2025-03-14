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
      await DaoManager.shopDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.shopDao.update(businessId!, data!);
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
      {String? name, String? lastAccountItemAt}) {
    return ShopCULog()
        .who(userId)
        .inBook(bookId)
        .target(shopId)
        .doUpdate()
        .withData(AccountShopTable.toUpdateCompanion(
          userId,
          name: name,
          lastAccountItemAt: lastAccountItemAt,
        )) as ShopCULog;
  }

  static ShopCULog fromCreateLog(LogSync log) {
    return ShopCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .doCreate()
        .withData(AccountShop.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as ShopCULog;
  }

  static ShopCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return ShopCULog.update(log.operatorId, log.parentId, log.businessId,
        name: data['name']);
  }

  static ShopCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create
        ? ShopCULog.fromCreateLog(log)
        : ShopCULog.fromUpdateLog(log));
  }
}
