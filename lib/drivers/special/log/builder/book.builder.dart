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


class CreateBookLog extends AbstraceBookLog<AccountBookTableCompanion, String> {
  CreateBookLog() : super() {
    operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    await DaoManager.accountBookDao.insert(data!);
    inBook(data!.id.value);
    return data!.id.value;
  }
}

class UpdateBookLog extends AbstraceBookLog<AccountBookTableCompanion, void> {
  UpdateBookLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    DaoManager.accountBookDao.update(accountBookId!, data!);
  }
}
