import 'dart:convert';

import 'package:clsswjz/enums/fund_type.dart';

import '../../../../database/database.dart';
import '../../../../manager/dao_manager.dart';
import '../../../../database/tables/account_fund_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import 'builder.dart';

abstract class BookFundLogBuilder<T, RunResult>
    extends LogBuilder<T, RunResult> {
  BookFundLogBuilder() {
    doWith(BusinessType.fund);
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
}

class CreateFundLog
    extends BookFundLogBuilder<AccountFundTableCompanion, String> {
  CreateFundLog() : super() {
    operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    await DaoManager.accountFundDao.insert(data!);
    subject(data!.id.value);
    return data!.id.value;
  }

  factory CreateFundLog.build(
    String who,
    String bookId, {
    required String name,
    required FundType fundType,
    String? fundRemark,
    double? fundBalance,
    bool isDefault = false,
  }) {
    return CreateFundLog()
      ..who(who)
      ..inBook(bookId)
      ..withData(AccountFundTable.toCreateCompanion(
        who,
        bookId,
        name: name,
        fundType: fundType,
        fundRemark: fundRemark,
        fundBalance: fundBalance,
        isDefault: isDefault,
      ));
  }

  static LogBuilder<AccountFundTableCompanion, String> fromLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return CreateFundLog.build(log.operatorId, log.accountBookId,
        name: data['name'],
        fundType: data['fundType'],
        fundRemark: data['fundRemark'],
        fundBalance: data['fundBalance'],
        isDefault: data['isDefault']);
  }
}

class UpdateFundLog
    extends BookFundLogBuilder<AccountFundTableCompanion, void> {
  UpdateFundLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    await DaoManager.accountFundDao.update(businessId!, data!);
  }

  static UpdateFundLog build(
    String who,
    String bookId,
    String fundId, {
    String? name,
    FundType? fundType,
    String? fundRemark,
    double? fundBalance,
    bool? isDefault,
  }) {
    return UpdateFundLog()
      ..who(who)
      ..inBook(bookId)
      ..subject(fundId)
      ..withData(AccountFundTable.toUpdateCompanion(
        who,
        name: name,
        fundRemark: fundRemark,
        fundBalance: fundBalance,
        isDefault: isDefault,
      ));
  }

  static UpdateFundLog fromLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return UpdateFundLog.build(
        log.operatorId, log.accountBookId, log.businessId,
        name: data['name'],
        fundType: data['fundType'],
        fundRemark: data['fundRemark'],
        fundBalance: data['fundBalance'],
        isDefault: data['isDefault']);
  }
}
