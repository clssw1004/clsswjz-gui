import 'package:drift/drift.dart';

import '../../../../database/database.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import '../../../../utils/date_util.dart';
import '../../../../utils/id_util.dart';

const NONE_BOOK = "NONE_BOOK";

abstract class LogBuilder<T, RunResult> {
  final String? _id;
  String? get id => _id;

  /// 账本ID
  String? _accountBookId;
  String? get accountBookId => _accountBookId;

  /// 操作人
  String? _operatorId;
  String? get operatorId => _operatorId;

  /// 操作时间戳
  final int? _operatedAt;
  int? get operatedAt => _operatedAt;

  /// 操作业务
  /// item-账目、book-账本、fund-账户、category-分类、shop-商家、symbol-标识、user-用户，attachment-附件
  BusinessType? _businessType;
  BusinessType? get businessType => _businessType;

  /// 操作类型
  /// update-更新、create-创建、delete-删除
  /// batchUpdate-批量更新、batchCreate-批量创建、batchDelete-批量删除
  OperateType? _operateType;
  OperateType? get operateType => _operateType;

  /// 操作数据主键
  String? _businessId;
  String? get businessId => _businessId;

  T? _data;
  T? get data => _data;
  LogBuilder()
      : _id = IdUtil.genId(),
        _operatedAt = DateUtil.now();

  LogBuilder doWith(BusinessType businessType) {
    _businessType = businessType;
    return this;
  }

  LogBuilder who(String operatorId) {
    _operatorId = operatorId;
    return this;
  }

  LogBuilder withOutBook() {
    _accountBookId = NONE_BOOK;
    return this;
  }

  LogBuilder inBook(String bookId) {
    _accountBookId = bookId;
    return this;
  }

  LogBuilder subject(String businessId) {
    _businessId = businessId;
    return this;
  }

  LogBuilder operate(OperateType operateType) {
    _operateType = operateType;
    return this;
  }

  LogBuilder create() {
    _operateType = OperateType.create;
    return this;
  }

  LogBuilder update() {
    _operateType = OperateType.delete;
    return this;
  }

  LogBuilder delete() {
    _operateType = OperateType.delete;
    return this;
  }

  LogBuilder withData(T data) {
    _data = data;
    return this;
  }

  Future<RunResult> execute() async {
    final result = await executeLog();
    await DaoManager.accountBookLogDao.insert(toAccountBookLog());
    return result;
  }

  Future<RunResult> executeLog();

  AccountBookLog toAccountBookLog() {
    return AccountBookLog(
      id: _id!,
      accountBookId: _accountBookId!,
      operatorId: _operatorId!,
      operatedAt: _operatedAt!,
      businessType: _businessType!.name,
      operateType: _operateType!.name,
      businessId: _businessId!,
      operateData: data2Json(),
    );
  }

  String data2Json() {
    return _data.toString();
  }

  static copyWithCreated<T>(
      T Function({
        required Value<String> id,
        required Value<int> createdAt,
        required Value<int> updatedAt,
        required Value<String> createdBy,
        required Value<String> updatedBy,
      }) copyWith,
      String operatorId) {
    final now = DateUtil.now();
    final id = IdUtil.genId();
    return copyWith(
      id: Value(id),
      createdAt: Value(now),
      updatedAt: Value(now),
      createdBy: Value(operatorId),
      updatedBy: Value(operatorId),
    );
  }

  static copyWithUpdate<T>(
      T Function({
        required Value<int> updatedAt,
        required Value<String> updatedBy,
      }) copyWith,
      String operatorId) {
    final now = DateUtil.now();
    return copyWith(
      updatedAt: Value(now),
      updatedBy: Value(operatorId),
    );
  }
}

class DeleteLog extends LogBuilder<String, void> {
  DeleteLog() {
    operate(OperateType.delete);
  }

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
      case BusinessType.bookMember:
        return DaoManager.relAccountbookUserDao.delete(businessId!);
      case BusinessType.funBook:
        return DaoManager.relAccountbookFundDao.delete(businessId!);
      default:
        throw UnimplementedError('未实现的操作类型：$businessType');
    }
  }

  static DeleteLog buildBook(String who, String bookId) {
    return DeleteLog()
        .who(who)
        .doWith(BusinessType.book)
        .inBook(bookId)
        .subject(bookId) as DeleteLog;
  }

  static DeleteLog buildBookSub(
      String who, String bookId, BusinessType businessType, String subjectId) {
    return DeleteLog()
        .who(who)
        .doWith(businessType)
        .inBook(bookId)
        .subject(subjectId) as DeleteLog;
  }

  static DeleteLog build(
      String who, BusinessType businessType, String subjectId) {
    return DeleteLog()
        .who(who)
        .doWith(businessType)
        .withOutBook()
        .subject(subjectId) as DeleteLog;
  }
}
