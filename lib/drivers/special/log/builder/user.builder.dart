import 'dart:convert';

import 'package:clsswjz/database/tables/user_table.dart';
import 'package:clsswjz/drivers/special/log/builder/builder.dart';

import '../../../../database/database.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';

class UserCULog extends LogBuilder<UserTableCompanion, String> {
  UserCULog() : super() {
    doWith(BusinessType.user);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.userDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.userDao.update(businessId!, data!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return UserTable.toJsonString(data as UserTableCompanion);
    }
  }

  static UserCULog fromCreateLog(LogSync log) {
    return UserCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(AccountFund.fromJson(jsonDecode(log.operateData)).toCompanion(true)) as UserCULog;
  }

  static UserCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return UserCULog().who(log.operatorId).target(log.businessId).doUpdate().withData(UserTable.toUpdateCompanion(
          nickname: data['nickname'],
          password: data['password'],
          email: data['email'],
          phone: data['phone'],
          language: data['language'],
          timezone: data['timezone'],
          avatar: data['avatar'],
        )) as UserCULog;
  }

  static UserCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create ? UserCULog.fromCreateLog(log) : UserCULog.fromUpdateLog(log));
  }

  static UserCULog create({
    String? userId,
    required String username,
    required String password,
    required String nickname,
    String? email,
    String? phone,
    String? language,
    String? timezone,
    String? avatar,
  }) {
    return UserCULog().doCreate().noParent().withData(UserTable.toCreateCompanion(
          userId: userId,
          username: username,
          password: password,
          nickname: nickname,
          email: email,
          phone: phone,
          language: language,
          timezone: timezone,
          avatar: avatar,
        )) as UserCULog;
  }

  static UserCULog update(
    String who, {
    String? nickname,
    String? password,
    String? email,
    String? phone,
    String? language,
    String? timezone,
    String? avatar,
  }) {
    return UserCULog().who(who).doUpdate().noParent().target(who).withData(UserTable.toUpdateCompanion(
          nickname: nickname,
          password: password,
          email: email,
          phone: phone,
          language: language,
          timezone: timezone,
          avatar: avatar,
        )) as UserCULog;
  }
}
