import 'dart:convert';

import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import '../../../../database/tables/account_book_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/currency_symbol.dart';
import '../../../../enums/operate_type.dart';
import '../../../../models/vo/book_member_vo.dart';
import 'builder.dart';

abstract class BookLogBuilder<T, RunResult> extends LogBuilder<T, RunResult> {
  BookLogBuilder() {
    doWith(BusinessType.book);
  }

  @override
  LogBuilder<T, RunResult> inBook(String bookId) {
    super.inBook(bookId).subject(bookId);
    return this;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return AccountBookTable.toJsonString(data as AccountBookTableCompanion);
    }
  }
}

class CreateBookLog extends BookLogBuilder<AccountBookTableCompanion, String> {
  CreateBookLog() : super() {
    operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    await DaoManager.accountBookDao.insert(data!);
    inBook(data!.id.value);
    return data!.id.value;
  }

  static CreateBookLog build(String who,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol = CurrencySymbol.cny,
      String? icon}) {
    return CreateBookLog().who(who).withData(AccountBookTable.toCreateCompanion(
        who,
        name: name,
        description: description,
        currencySymbol: currencySymbol?.symbol ?? CurrencySymbol.cny.symbol,
        icon: icon)) as CreateBookLog;
  }

  @override
  LogBuilder<AccountBookTableCompanion, String> fromLog(LogSync log) {
    return CreateBookLog().who(log.operatorId).withData(
            AccountBook.fromJson(jsonDecode(log.operateData)).toCompanion(true))
        as CreateBookLog;
  }
}

class UpdateBookLog extends BookLogBuilder<AccountBookTableCompanion, void> {
  UpdateBookLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    DaoManager.accountBookDao.update(accountBookId!, data!);
  }

  static UpdateBookLog build(String who, String bookId,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO>? members}) {
    return UpdateBookLog().inBook(bookId).who(who).withData(
        AccountBookTable.toUpdateCompanion(who,
            name: name,
            description: description,
            currencySymbol: currencySymbol?.symbol ?? CurrencySymbol.cny.symbol,
            icon: icon)) as UpdateBookLog;
  }

  @override
  LogBuilder<AccountBookTableCompanion, void> fromLog(LogSync log) {
    return UpdateBookLog().who(log.operatorId).withData(
            AccountBook.fromJson(jsonDecode(log.operateData)).toCompanion(true))
        as UpdateBookLog;
  }
}
