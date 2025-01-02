import 'dart:convert';

import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import 'package:clsswjz/utils/date_util.dart';
import 'package:clsswjz/utils/id_util.dart';
import 'package:drift/drift.dart';

import '../../enums/business_type.dart';
import '../../enums/operate_type.dart';

abstract class AbstraceLog<T, RunResult> {
  final String? _id;

  /// 账本ID
  String? _accountBookId;

  /// 操作人
  String? _operatorId;

  /// 操作时间戳
  final int? _operatedAt;

  /// 操作业务
  /// item-账目、book-账本、fund-账户、category-分类、shop-商家、symbol-标识、user-用户，attachment-附件
  BusinessType? _businessType;

  /// 操作类型
  /// update-更新、create-创建、delete-删除
  /// batchUpdate-批量更新、batchCreate-批量创建、batchDelete-批量删除
  OperateType? _operateType;

  /// 操作数据主键
  String? _businessId;

  T? _data;

  AbstraceLog()
      : _id = IdUtils.genId(),
        _operatedAt = DateUtil.now();

  AbstraceLog doWith(BusinessType businessType) {
    _businessType = businessType;
    return this;
  }

  AbstraceLog who(String operatorId) {
    _operatorId = operatorId;
    return this;
  }

  AbstraceLog inBook(String bookId) {
    _accountBookId = bookId;
    return this;
  }

  AbstraceLog create() {
    _operateType = OperateType.create;
    return this;
  }

  AbstraceLog update() {
    _operateType = OperateType.delete;
    return this;
  }

  AbstraceLog delete() {
    _operateType = OperateType.delete;
    return this;
  }

  AbstraceLog withData(T data) {
    _data = data;
    return this;
  }

  Future<RunResult> execute() async {
    final result = await _executeLog();
    await DaoManager.accountBookLogDao.insert(toAccountBookLog());
    DaoManager.accountBookLogDao.insert(toAccountBookLog());
    return result;
  }

  Future<RunResult> _executeLog();

  AccountBookLog toAccountBookLog() {
    return AccountBookLog(
      id: _id!,
      accountBookId: _accountBookId!,
      operatorId: _operatorId!,
      operatedAt: _operatedAt!,
      businessType: _businessType!.name,
      operateType: _operateType!.name,
      businessId: _businessId!,
      operateData: jsonEncode(_data),
    );
  }
}

class DeleteLog extends AbstraceLog<String, void> {
  @override
  Future<void> _executeLog() {
    switch (_businessType) {
      case BusinessType.book:
        return DaoManager.accountBookDao.delete(_accountBookId!);
      case BusinessType.category:
        return DaoManager.accountCategoryDao.delete(_businessId!);
      case BusinessType.item:
        return DaoManager.accountItemDao.delete(_businessId!);
      case BusinessType.fund:
        return DaoManager.accountFundDao.delete(_businessId!);
      case BusinessType.shop:
        return DaoManager.accountShopDao.delete(_businessId!);
      default:
        throw UnimplementedError('未实现的操作类型：$_businessType');
    }
  }
}

class CreateBookLog extends AbstraceLog<AccountBookTableCompanion, String> {
  CreateBookLog() : super() {
    _operateType = OperateType.create;
  }

  @override
  Future<String> _executeLog() async {
    final id = IdUtils.genId();
    final newDate = _data!.copyWith(
      id: Value(id),
      createdAt: Value(DateUtil.now()),
      createdBy: Value(_operatorId!),
      updatedAt: Value(DateUtil.now()),
      updatedBy: Value(_operatorId!),
    );
    await DaoManager.accountBookDao.insert(newDate);
    return id;
  }
}

class UpdateBookLog extends AbstraceLog<AccountBookTableCompanion, void> {
  @override
  Future<void> _executeLog() {
    final newData = _data!.copyWith(
      updatedAt: Value(DateUtil.now()),
      updatedBy: Value(_operatorId!),
    );
    return DaoManager.accountBookDao.update(_accountBookId!, newData);
  }
}

class CreateCategoryLog
    extends AbstraceLog<AccountCategoryTableCompanion, String> {
  CreateCategoryLog() : super() {
    _operateType = OperateType.create;
    _businessType = BusinessType.category;
  }

  @override
  Future<String> _executeLog() async {
    final id = IdUtils.genId();
    final newData = _data!.copyWith(
      id: Value(id),
      createdAt: Value(DateUtil.now()),
      createdBy: Value(_operatorId!),
      updatedAt: Value(DateUtil.now()),
      updatedBy: Value(_operatorId!),
    );
    await DaoManager.accountCategoryDao.insert(newData);
    return id;
  }
}

class UpdateCategoryLog
    extends AbstraceLog<AccountCategoryTableCompanion, void> {
  UpdateCategoryLog() : super() {
    _operateType = OperateType.update;
    _businessType = BusinessType.category;
  }

  @override
  Future<void> _executeLog() async {
    final newData = _data!.copyWith(
      updatedAt: Value(DateUtil.now()),
      updatedBy: Value(_operatorId!),
    );
    await DaoManager.accountCategoryDao.update(_businessId!, newData);
  }
}
