import 'dart:convert';

import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import '../../../../database/tables/account_item_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import 'builder.dart';

abstract class AbstractBookItemLog<T, RunResult>
    extends LogBuilder<T, RunResult> {
  AbstractBookItemLog() {
    doWith(BusinessType.item);
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
}

class CreateBookItemLog
    extends AbstractBookItemLog<AccountItemTableCompanion, String> {
  CreateBookItemLog() : super() {
    operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    await DaoManager.accountItemDao.insert(data!);
    subject(data!.id.value);
    return data!.id.value;
  }

  static CreateBookItemLog build(String who, String bookId,
      {required amount,
      String? description,
      required String type,
      String? categoryCode,
      required String accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode}) {
    return CreateBookItemLog().who(who).inBook(bookId).withData(
        AccountItemTable.toCreateCompanion(who, bookId,
            amount: amount,
            description: description,
            type: type,
            categoryCode: categoryCode,
            accountDate: accountDate,
            fundId: fundId,
            shopCode: shopCode,
            tagCode: tagCode,
            projectCode: projectCode)) as CreateBookItemLog;
  }

  @override
  LogBuilder<AccountItemTableCompanion, String> fromLog(LogSync log) {
    return CreateBookItemLog()
        .who(log.operatorId)
        .inBook(log.accountBookId)
        .withData(AccountItem.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as CreateBookItemLog;
  }
}

class UpdateBookItemLog
    extends AbstractBookItemLog<AccountItemTableCompanion, void> {
  UpdateBookItemLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    await DaoManager.accountItemDao.update(businessId!, data!);
  }

  static UpdateBookItemLog build(String userId, String bookId, String itemId,
      {double? amount,
      String? description,
      String? type,
      String? categoryCode,
      String? accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode}) {
    return UpdateBookItemLog()
        .who(userId)
        .inBook(bookId)
        .subject(itemId)
        .withData(AccountItemTable.toUpdateCompanion(userId,
            amount: amount,
            description: description,
            type: type,
            categoryCode: categoryCode,
            accountDate: accountDate,
            fundId: fundId,
            shopCode: shopCode,
            tagCode: tagCode,
            projectCode: projectCode)) as UpdateBookItemLog;
  }

  @override
  LogBuilder<AccountItemTableCompanion, void> fromLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return UpdateBookItemLog.build(
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
}
