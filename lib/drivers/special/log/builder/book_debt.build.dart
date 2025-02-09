import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/account_debt_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/debt_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class DebtCULog extends LogBuilder<AccountDebtTableCompanion, String> {
  DebtCULog() : super() {
    doWith(BusinessType.debt);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.debtDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.debtDao.update(businessId!, data!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return AccountDebtTable.toJsonString(data as AccountDebtTableCompanion);
    }
  }

  static DebtCULog create(
    String who,
    String bookId, {
    required DebtType debtType,
    required String debtor,
    required double amount,
    required String fundId,
    required String debtDate,
  }) {
    return DebtCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(AccountDebtTable.toCreateCompanion(
          who,
          bookId,
          debtType: debtType.code,
          debtor: debtor,
          amount: amount,
          fundId: fundId,
          debtDate: debtDate,
        )) as DebtCULog;
  }

  static DebtCULog update(
    String userId,
    String bookId,
    String debtId, {
    String? debtor,
    double? amount,
    String? fundId,
    String? debtDate,
  }) {
    return DebtCULog()
        .who(userId)
        .inBook(bookId)
        .target(debtId)
        .doUpdate()
        .withData(AccountDebtTable.toUpdateCompanion(
          userId,
          debtor: debtor,
          amount: amount,
          fundId: fundId,
          debtDate: debtDate,
        )) as DebtCULog;
  }

  static DebtCULog fromCreateLog(LogSync log) {
    return DebtCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .doCreate()
        .withData(AccountDebt.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as DebtCULog;
  }

  static DebtCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return DebtCULog.update(
      log.operatorId,
      log.parentId,
      log.businessId,
      debtor: data['debtor'],
      amount: data['amount'],
      fundId: data['fundId'],
      debtDate: data['debtDate'],
    );
  }

  static DebtCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create
        ? DebtCULog.fromCreateLog(log)
        : DebtCULog.fromUpdateLog(log));
  }
} 