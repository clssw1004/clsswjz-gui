import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/account_fund_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/fund_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class FundCULog extends LogBuilder<AccountFundTableCompanion, String> {
  FundCULog() : super() {
    doWith(BusinessType.fund);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.accountFundDao.insert(data!);
      subject(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.accountFundDao.update(businessId!, data!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return AccountFundTable.toJsonString(data as AccountFundTableCompanion);
    }
  }

  static FundCULog create(String who, String bookId,
      {required String name,
      required FundType fundType,
      String? fundRemark,
      double? fundBalance,
      bool isDefault = false}) {
    return FundCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(AccountFundTable.toCreateCompanion(
          who,
          bookId,
          name: name,
          fundType: fundType,
          fundRemark: fundRemark,
          fundBalance: fundBalance,
          isDefault: isDefault,
        )) as FundCULog;
  }

  static FundCULog update(String userId, String bookId, String fundId,
      {String? name,
      FundType? fundType,
      String? fundRemark,
      double? fundBalance,
      bool? isDefault}) {
    return FundCULog()
        .who(userId)
        .inBook(bookId)
        .subject(fundId)
        .doUpdate()
        .withData(AccountFundTable.toUpdateCompanion(
          userId,
          name: name,
          fundType: fundType,
          fundRemark: fundRemark,
          fundBalance: fundBalance,
          isDefault: isDefault,
        )) as FundCULog;
  }

  static FundCULog fromCreateLog(LogSync log) {
    return FundCULog()
            .who(log.operatorId)
            .inBook(log.accountBookId)
            .doCreate()
            .withData(AccountFund.fromJson(jsonDecode(log.operateData)))
        as FundCULog;
  }

  static FundCULog fromUpdateLog(LogSync log) {
    return FundCULog()
            .who(log.operatorId)
            .inBook(log.accountBookId)
            .subject(log.businessId)
            .doUpdate()
            .withData(AccountFund.fromJson(jsonDecode(log.operateData)))
        as FundCULog;
  }

  static FundCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create
        ? FundCULog.fromCreateLog(log)
        : FundCULog.fromUpdateLog(log));
  }
}
