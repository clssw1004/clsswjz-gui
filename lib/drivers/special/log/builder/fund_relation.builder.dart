import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import 'package:clsswjz/utils/date_util.dart';
import 'package:drift/drift.dart';
import '../../../../database/tables/rel_accountbook_fund_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import 'builder.dart';

/// 创建账本资金关系日志构建器
class CreateFundRelationLog
    extends LogBuilder<RelAccountbookFundTableCompanion, String> {
  CreateFundRelationLog() : super() {
    doWith(BusinessType.funBook).operate(OperateType.create);
  }

  @override
  Future<String> executeLog() async {
    subject(data!.id.value);
    await DaoManager.relAccountbookFundDao.insert(data!);
    return data!.id.value;
  }

  @override
  String data2Json() {
    return RelAccountbookFundTable.toJsonString(data!);
  }

  static CreateFundRelationLog build(
    String who, {
    required String accountBookId,
    required String fundId,
    bool fundIn = true,
    bool fundOut = true,
    bool isDefault = false,
  }) {
    return CreateFundRelationLog()
        .who(who)
        .inBook(accountBookId)
        .withData(RelAccountbookFundTable.toCreateCompanion(
          accountBookId: accountBookId,
          fundId: fundId,
          fundIn: fundIn,
          fundOut: fundOut,
        )) as CreateFundRelationLog;
  }
}

/// 更新账本资金关系日志构建器
class UpdateFundRelationLog
    extends LogBuilder<RelAccountbookFundTableCompanion, void> {
  UpdateFundRelationLog() : super() {
    doWith(BusinessType.funBook).operate(OperateType.update);
  }

  @override
  Future<void> executeLog() async {
    final newData = data!.copyWith(
      updatedAt: Value(DateUtil.now()),
    );
    await DaoManager.relAccountbookFundDao.update(businessId!, newData);
  }

  static UpdateFundRelationLog build(
    String who,
    String bookId,
    String fundId, {
    bool? fundIn,
    bool? fundOut,
    bool? isDefault,
  }) {
    return UpdateFundRelationLog()
        .who(who)
        .inBook(bookId)
        .subject(fundId)
        .withData(RelAccountbookFundTable.toUpdateCompanion(
          fundIn: fundIn,
          fundOut: fundOut,
        )) as UpdateFundRelationLog;
  }
}
