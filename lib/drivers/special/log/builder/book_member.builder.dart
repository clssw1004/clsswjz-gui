import 'dart:convert';
import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import 'package:clsswjz/utils/date_util.dart';
import 'package:drift/drift.dart';
import '../../../../database/tables/rel_accountbook_user_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import 'base.builder.dart';

class CreateMemberLog
    extends AbstraceLog<RelAccountbookUserTableCompanion, String> {
  CreateMemberLog() : super() {
    doWith(BusinessType.bookMember).operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    subject(data!.id.value);
    await DaoManager.relAccountbookUserDao.insert(data!);
    return data!.id.value;
  }

  @override
  String data2Json() {
    return RelAccountbookUserTable.toJsonString(data!);
  }
}

class UpdateMemberLog
    extends AbstraceLog<RelAccountbookUserTableCompanion, void> {
  UpdateMemberLog() : super() {
    operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    final newData = data!.copyWith(
      updatedAt: Value(DateUtil.now()),
    );
    await DaoManager.relAccountbookUserDao.update(accountBookId!, newData);
  }
}
