import '../../../../constants/symbol_type.dart';
import '../../../../database/database.dart';
import '../../../../database/tables/account_symbol_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';
import 'dart:convert';

abstract class AbstractBookSymbolLog<T, RunResult>
    extends LogBuilder<T, RunResult> {
  AbstractBookSymbolLog() {
    doWith(BusinessType.symbol);
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
}

class CreateBookSymbolLog
    extends AbstractBookSymbolLog<AccountSymbolTableCompanion, String> {
  CreateBookSymbolLog() : super() {
    operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    await DaoManager.accountSymbolDao.insert(data!);
    subject(data!.id.value);
    return data!.id.value;
  }

  static CreateBookSymbolLog build(String who, String bookId,
      {required String name, required SymbolType symbolType}) {
    return CreateBookSymbolLog()
        .who(who)
        .inBook(bookId)
        .withData(AccountSymbolTable.toCreateCompanion(
          who,
          bookId,
          name: name,
          symbolType: symbolType,
        )) as CreateBookSymbolLog;
  }

  @override
  LogBuilder<AccountSymbolTableCompanion, String> fromLog(LogSync log) {
    return CreateBookSymbolLog()
        .who(log.operatorId)
        .inBook(log.accountBookId)
        .withData(AccountSymbol.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as CreateBookSymbolLog;
  }
}

class UpdateBookSymbolLog
    extends AbstractBookSymbolLog<AccountSymbolTableCompanion, void> {
  UpdateBookSymbolLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    await DaoManager.accountSymbolDao.update(businessId!, data!);
  }

  static UpdateBookSymbolLog build(
      String userId, String bookId, String symbolId,
      {String? name}) {
    return UpdateBookSymbolLog()
        .who(userId)
        .inBook(bookId)
        .subject(symbolId)
        .withData(AccountSymbolTable.toUpdateCompanion(
          userId,
          name: name,
        )) as UpdateBookSymbolLog;
  }

  @override
  LogBuilder<AccountSymbolTableCompanion, void> fromLog(LogSync log) {
    return UpdateBookSymbolLog()
        .who(log.operatorId)
        .inBook(log.accountBookId)
        .subject(log.businessId)
        .withData(AccountSymbol.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as UpdateBookSymbolLog;
  }
}
