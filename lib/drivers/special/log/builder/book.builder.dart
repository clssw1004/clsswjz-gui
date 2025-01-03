import 'dart:convert';
import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/database/tables/account_book_table.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import 'package:clsswjz/utils/date_util.dart';
import 'package:drift/drift.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import 'base.builder.dart';

abstract class AbstraceBookLog<T, RunResult> extends AbstraceLog<T, RunResult> {
  AbstraceBookLog() {
    doWith(BusinessType.book);
  }

  @override
  AbstraceLog<T, RunResult> inBook(String bookId) {
    super.inBook(bookId).subject(bookId);
    return this;
  }
}

class DeleteLog extends AbstraceBookLog<String, void> {
  @override
  Future<void> executeLog() {
    switch (businessType) {
      case BusinessType.book:
        return DaoManager.accountBookDao.delete(businessId!);
      case BusinessType.category:
        return DaoManager.accountCategoryDao.delete(businessId!);
      case BusinessType.item:
        return DaoManager.accountItemDao.delete(businessId!);
      case BusinessType.fund:
        return DaoManager.accountFundDao.delete(businessId!);
      case BusinessType.shop:
        return DaoManager.accountShopDao.delete(businessId!);
      default:
        throw UnimplementedError('未实现的操作类型：${businessType}');
    }
  }
}

class CreateBookLog extends AbstraceBookLog<AccountBook, String> {
  CreateBookLog() : super() {
    operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    inBook(data!.id);
    await DaoManager.accountBookDao.insert(data!);
    return data!.id;
  }

  @override
  String data2Json() {
    return jsonEncode(data!.toJson());
  }
}

class UpdateBookLog extends AbstraceBookLog<AccountBookTableCompanion, void> {
  UpdateBookLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() {
    return DaoManager.accountBookDao.update(accountBookId!, data!);
  }

  @override
  String data2Json() {
    Map<String, dynamic> map = {};
    map['name'] = data!.name.present ? data!.name.value : '';
    map['description'] = data!.description.present ? data!.description.value : '';
    map['currencySymbol'] = data!.currencySymbol.present ? data!.currencySymbol.value : '';
    map['icon'] = data!.icon.present ? data!.icon.value : '';
    map['updatedAt'] = DateUtil.now();
    map['updatedBy'] = operatorId;
    return jsonEncode(map);
  }
}

