import '../../../../constants/symbol_type.dart';
import '../../../../database/database.dart';
import '../../../../database/tables/account_symbol_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';
import 'dart:convert';

class SymbolCULog extends LogBuilder<AccountSymbolTableCompanion, String> {
  SymbolCULog() : super() {
    doWith(BusinessType.symbol);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.accountSymbolDao.insert(data!);
      subject(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.accountSymbolDao.update(businessId!, data!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return AccountSymbolTable.toJsonString(
          data as AccountSymbolTableCompanion);
    }
  }

  static SymbolCULog create(String who, String bookId,
      {required String name, required SymbolType symbolType}) {
    return SymbolCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(AccountSymbolTable.toCreateCompanion(
          who,
          bookId,
          name: name,
          symbolType: symbolType,
        )) as SymbolCULog;
  }

  static SymbolCULog update(String userId, String bookId, String symbolId,
      {String? name}) {
    return SymbolCULog()
        .who(userId)
        .inBook(bookId)
        .subject(symbolId)
        .doUpdate()
        .withData(AccountSymbolTable.toUpdateCompanion(
          userId,
          name: name,
        )) as SymbolCULog;
  }

  static SymbolCULog fromCreateLog(LogSync log) {
    return SymbolCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .doCreate()
        .withData(AccountSymbol.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as SymbolCULog;
  }

  static SymbolCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return SymbolCULog.update(log.operatorId, log.parentId, log.businessId,
        name: data['name']);
  }

  static SymbolCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create
        ? SymbolCULog.fromCreateLog(log)
        : SymbolCULog.fromUpdateLog(log));
  }
}
