import 'dart:convert';

import 'package:clsswjz/drivers/special/log/builder/book.builder.dart';
import 'package:drift/drift.dart';

import '../../../../database/database.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../enums/sync_state.dart';
import '../../../../manager/dao_manager.dart';
import '../../../../utils/date_util.dart';
import '../../../../utils/id_util.dart';
import 'attachment.builder.dart';
import 'book_category.builder.dart';
import 'book_item.builder.dart';
import 'book_member.builder.dart';
import 'book_shop.builder.dart';
import 'book_symbol.builder.dart';
import 'fund.builder.dart';

const NONE_BOOK = "NONE_BOOK";

abstract class DeserializerLog<T extends LogBuilder> {
  T fromLog(LogSync log);
}

abstract class LogBuilder<T, RunResult> {
  String? _id;
  String? get id => _id;

  /// 账本ID
  String? _parentId;
  String? get parentId => _parentId;

  /// 父级类型
  BusinessType? _parentType;
  BusinessType? get parentType => _parentType;

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
    _parentId = NONE_BOOK;
    return this;
  }

  LogBuilder inBook(String bookId) {
    _parentType = BusinessType.book;
    _parentId = bookId;
    return this;
  }

  LogBuilder withBelong(BusinessType belongType, String belongId) {
    _parentType = belongType;
    _parentId = belongId;
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

  LogBuilder doCreate() {
    _operateType = OperateType.create;
    return this;
  }

  LogBuilder doCreateBatch() {
    _operateType = OperateType.batchCreate;
    return this;
  }

  LogBuilder doUpdate() {
    _operateType = OperateType.update;
    return this;
  }

  LogBuilder doDelete() {
    _operateType = OperateType.delete;
    return this;
  }

  LogBuilder withData(T data) {
    _data = data;
    return this;
  }

  Future<RunResult> executeWithoutRecord() async {
    final result = await executeLog();
    return result;
  }

  Future<RunResult> execute() async {
    final result = await executeWithoutRecord();
    await DaoManager.logSyncDao.insert(toSyncLog());
    return result;
  }

  Future<RunResult> executeLog();

  LogSync toSyncLog() {
    return LogSync(
      id: _id!,
      parentType: _parentType!.code,
      parentId: _parentId!,
      operatorId: _operatorId!,
      operatedAt: _operatedAt!,
      businessType: _businessType!.code,
      operateType: _operateType!.code,
      businessId: _businessId!,
      operateData: data2Json(),
      syncState: SyncState.unsynced.value,
      syncTime: -1,
    );
  }

  factory LogBuilder.fromLog(LogSync log) {
    LogBuilder<T, RunResult> builder = _fromLog<T, RunResult>(log);
    builder._id = log.id;
    return builder;
  }

  static LogBuilder<T, RunResult> _fromLog<T, RunResult>(LogSync log) {
    final businessType = BusinessType.fromCode(log.businessType);
    final operateType = OperateType.fromCode(log.operateType);

    if (operateType == OperateType.delete) {
      if (businessType == BusinessType.book) {
        return DeleteLog.buildBook(log.operatorId, log.businessId) as LogBuilder<T, RunResult>;
      } else {
        return DeleteLog.buildBookSub(log.operatorId, log.parentId, businessType!, log.businessId) as LogBuilder<T, RunResult>;
      }
    }

    switch (businessType) {
      case BusinessType.book:
        return BookCULog.fromLog(log) as LogBuilder<T, RunResult>;
      case BusinessType.category:
        return CategoryCULog.fromLog(log) as LogBuilder<T, RunResult>;
      case BusinessType.item:
        return ItemCULog.fromLog(log) as LogBuilder<T, RunResult>;
      case BusinessType.shop:
        return ShopCULog.fromLog(log) as LogBuilder<T, RunResult>;
      case BusinessType.symbol:
        return SymbolCULog.fromLog(log) as LogBuilder<T, RunResult>;
      case BusinessType.fund:
        return FundCULog.fromLog(log) as LogBuilder<T, RunResult>;
      case BusinessType.bookMember:
        return MemberCULog.fromLog(log) as LogBuilder<T, RunResult>;
      case BusinessType.attachment:
        return AttachmentCULog.fromLog(log) as LogBuilder<T, RunResult>;
      default:
        throw UnimplementedError('Unsupported business type: ${log.businessType}');
    }
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
    doDelete();
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
      case BusinessType.attachment:
        return DaoManager.attachmentDao.delete(businessId!);
      default:
        throw UnimplementedError('未实现的操作类型：$businessType');
    }
  }

  static DeleteLog buildBook(String who, String bookId) {
    return DeleteLog().who(who).doWith(BusinessType.book).inBook(bookId).subject(bookId) as DeleteLog;
  }

  static DeleteLog buildBookSub(String who, String bookId, BusinessType businessType, String subjectId) {
    return DeleteLog().who(who).doWith(businessType).inBook(bookId).subject(subjectId) as DeleteLog;
  }

  static DeleteLog build(String who, BusinessType businessType, String subjectId) {
    return DeleteLog().who(who).doWith(businessType).withOutBook().subject(subjectId) as DeleteLog;
  }

  static DeleteLog fromLog(LogSync log) {
    return DeleteLog().who(log.operatorId).inBook(log.parentId).doWith(BusinessType.fromCode(log.businessType)!).subject(log.businessId)
        as DeleteLog;
  }
}
