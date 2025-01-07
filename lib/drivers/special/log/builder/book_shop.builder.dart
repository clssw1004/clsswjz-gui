import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/account_shop_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

abstract class AbstractBookShopLog<T, RunResult>
    extends LogBuilder<T, RunResult> {
  AbstractBookShopLog() {
    doWith(BusinessType.shop);
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
}

class CreateBookShopLog
    extends AbstractBookShopLog<AccountShopTableCompanion, String> {
  CreateBookShopLog() : super() {
    operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    await DaoManager.accountShopDao.insert(data!);
    subject(data!.id.value);
    return data!.id.value;
  }

  static CreateBookShopLog build(String who, String bookId,
      {required String name, required}) {
    return CreateBookShopLog()
        .who(who)
        .inBook(bookId)
        .withData(AccountShopTable.toCreateCompanion(
          who,
          bookId,
          name: name,
        )) as CreateBookShopLog;
  }

  @override
  LogBuilder<AccountShopTableCompanion, String> fromLog(LogSync log) {
    return CreateBookShopLog()
        .who(log.operatorId)
        .inBook(log.accountBookId)
        .withData(AccountShop.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as CreateBookShopLog;
  }
}

class UpdateBookShopLog
    extends AbstractBookShopLog<AccountShopTableCompanion, void> {
  UpdateBookShopLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    await DaoManager.accountShopDao.update(businessId!, data!);
  }

  static UpdateBookShopLog build(
    String userId,
    String bookId,
    String shopId, {
    required String name,
  }) {
    return UpdateBookShopLog()
        .who(userId)
        .inBook(bookId)
        .subject(shopId)
        .withData(AccountShopTable.toUpdateCompanion(
          userId,
          name: name,
        )) as UpdateBookShopLog;
  }

  @override
  LogBuilder<AccountShopTableCompanion, void> fromLog(LogSync log) {
    return UpdateBookShopLog()
        .who(log.operatorId)
        .inBook(log.accountBookId)
        .subject(log.businessId)
        .withData(AccountShop.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as UpdateBookShopLog;
  }
}
