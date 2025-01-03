import 'package:drift/drift.dart';

import '../../../../database/base_entity.dart';
import '../../../../database/database.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import '../../../../utils/date_util.dart';
import '../../../../utils/id_util.dart';

abstract class AbstraceLog<T, RunResult> {
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

  AbstraceLog subject(String businessId) {
    _businessId = businessId;
    return this;
  }

  AbstraceLog operate(OperateType operateType) {
    _operateType = operateType;
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
    final id = IdUtils.genId();
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
