import 'dart:convert';
import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import '../../../../database/tables/account_book_table.dart';
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

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return jsonEncode(
          AccountBookTable.toJsonString(data as AccountBookTableCompanion));
    }
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

class CreateBookLog extends AbstraceBookLog<AccountBookTableCompanion, String> {
  CreateBookLog() : super() {
    operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    final newData = AbstraceLog.copyWithCreated(data!.copyWith, operatorId!);
    await DaoManager.accountBookDao.insert(newData);
    inBook(newData.id.value).withData(newData);
    return newData.id.value;
  }
}

class UpdateBookLog extends AbstraceBookLog<AccountBookTableCompanion, void> {
  UpdateBookLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    final newData = AbstraceLog.copyWithUpdate(data!.copyWith, operatorId!);
    DaoManager.accountBookDao.update(accountBookId!, newData);
    withData(newData);
  }
}
