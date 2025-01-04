import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import 'package:clsswjz/utils/date_util.dart';
import 'package:drift/drift.dart';
import '../../../../database/tables/rel_accountbook_user_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import 'builder.dart';

class CreateMemberLog
    extends LogBuilder<RelAccountbookUserTableCompanion, String> {
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

    static CreateMemberLog builder(String who,
      {required String accountBookId,
      required String userId,
      bool canViewBook = true,
      bool canEditBook = false,
      bool canDeleteBook = false,
      bool canViewItem = true,
      bool canEditItem = false,
      bool canDeleteItem = false}) {
    return CreateMemberLog().who(who).inBook(accountBookId).withData(
        RelAccountbookUserTable.toCreateCompanion(
            accountBookId: accountBookId,
            userId: userId,
            canViewBook: canViewBook,
            canEditBook: canEditBook,
            canDeleteBook: canDeleteBook,
            canViewItem: canViewItem,
            canEditItem: canEditItem,
            canDeleteItem: canDeleteItem)) as CreateMemberLog;
  }
}

class UpdateMemberLog
    extends LogBuilder<RelAccountbookUserTableCompanion, void> {
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
