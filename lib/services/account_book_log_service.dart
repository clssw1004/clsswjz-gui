import 'dart:convert';

import 'package:clsswjz/utils/date_util.dart';
import 'package:clsswjz/utils/uuid_util.dart';
import 'package:drift/drift.dart';

import '../database/database.dart';
import '../enums/business_type.dart';
import '../enums/operate_type.dart';
import '../manager/database_manager.dart';
import '../database/dao/account_book_log_dao.dart';
import 'base_service.dart';

class AccountBookLogService extends BaseService {
  final AccountBookLogDao _accountBookLogDao;

  AccountBookLogService()
      : _accountBookLogDao = AccountBookLogDao(DatabaseManager.db);

  Future<void> log({
    required String userId,
    required String accountBookId,
    required OperateType operateType,
    required BusinessType businessType,
    required String businessId,
    required Map<String, dynamic> operateData,
  }) async {
    final entity = AccountBookLogTableCompanion(
      id: Value(generateUuid()),
      operatorId: Value(userId),
      accountBookId: Value(accountBookId),
      operatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      businessType: Value(businessType.code),
      operateType: Value(operateType.code),
      businessId: Value(businessId),
      operateData: Value(json.encode(operateData)),
    );
    await _accountBookLogDao.insert(entity);
  }
}
