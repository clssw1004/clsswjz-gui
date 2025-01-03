import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import '../../../../database/tables/account_item_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import 'base.builder.dart';

abstract class AbstractBookItemLog<T, RunResult> extends AbstraceLog<T, RunResult> {
  AbstractBookItemLog() {
    doWith(BusinessType.item);
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return AccountItemTable.toJsonString(data as AccountItemTableCompanion);
    }
  }
}

class CreateBookItemLog extends AbstractBookItemLog<AccountItemTableCompanion, String> {
  CreateBookItemLog() : super() {
    operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    await DaoManager.accountItemDao.insert(data!);
    inBook(data!.accountBookId.value);
    return data!.id.value;
  }
}

class UpdateBookItemLog extends AbstractBookItemLog<AccountItemTableCompanion, void> {
  UpdateBookItemLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    await DaoManager.accountItemDao.update(accountBookId!, data!);
  }
}
