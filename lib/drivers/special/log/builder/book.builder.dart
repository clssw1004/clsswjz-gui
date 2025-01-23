import 'dart:convert';

import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import '../../../../database/tables/account_book_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/currency_symbol.dart';
import '../../../../enums/operate_type.dart';
import '../../../../models/vo/user_book_vo.dart';
import 'builder.dart';

class BookCULog<T> extends LogBuilder<AccountBookTableCompanion, String> {
  BookCULog() : super() {
    doWith(BusinessType.book);
  }

  @override
  BookCULog inBook(String bookId) {
    super.inBook(bookId).target(bookId);
    return this;
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.bookDao.insert(data!);
      inBook(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.bookDao.update(parentId!, data!);
    }
    return businessId!;
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

  static BookCULog create(String who,
      {required String name, String? description, CurrencySymbol? currencySymbol = CurrencySymbol.cny, String? icon}) {
    return BookCULog().who(who).doCreate().withData(AccountBookTable.toCreateCompanion(who,
        name: name,
        description: description,
        currencySymbol: currencySymbol?.symbol ?? CurrencySymbol.cny.symbol,
        icon: icon)) as BookCULog;
  }

  static BookCULog update(String who, String bookId,
      {String? name, String? description, CurrencySymbol? currencySymbol, String? icon, List<BookMemberVO>? members}) {
    return BookCULog().inBook(bookId).doUpdate().who(who).withData(AccountBookTable.toUpdateCompanion(who,
        name: name,
        description: description,
        currencySymbol: currencySymbol?.symbol ?? CurrencySymbol.cny.symbol,
        icon: icon)) as BookCULog;
  }

  static BookCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create ? BookCULog.fromCreateLog(log) : BookCULog.fromUpdateLog(log));
  }

  static BookCULog fromCreateLog(LogSync log) {
    return BookCULog().who(log.operatorId).doCreate().withData(AccountBook.fromJson(jsonDecode(log.operateData)).toCompanion(true))
        as BookCULog;
  }

  static BookCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return BookCULog.update(log.operatorId, log.parentId,
        name: data['name'],
        description: data['description'],
        currencySymbol: CurrencySymbol.fromSymbol(data['currencySymbol']),
        icon: data['icon']);
  }
}
