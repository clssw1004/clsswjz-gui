import 'dart:convert';
import '../../../../database/database.dart';
import '../../../../database/tables/user_share_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class UserShareCULog extends LogBuilder<UserShareTableCompanion, String> {
  UserShareCULog() : super() {
    doWith(BusinessType.userShare);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.userShareDao.upsert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.userShareDao.update(businessId!, data!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return UserShareTable.toJsonString(data as UserShareTableCompanion);
  }

  static UserShareCULog create({
    required String who,
    required String ownerUserId,
    required String targetUserId,
    required String businessType,
  }) {
    return UserShareCULog()
        .who(who)
        .doCreate()
        .noParent()
        .withData(UserShareTable.toCreateCompanion(
          ownerUserId: ownerUserId,
          targetUserId: targetUserId,
          businessType: businessType,
        )) as UserShareCULog;
  }

  static UserShareCULog update({
    required String who,
    required String id,
    required bool isEnabled,
  }) {
    return UserShareCULog()
        .who(who)
        .doUpdate()
        .noParent()
        .target(id)
        .withData(UserShareTable.toUpdateCompanion(
          isEnabled: isEnabled,
        )) as UserShareCULog;
  }

  static UserShareCULog fromCreateLog(LogSync log) {
    return UserShareCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as UserShareCULog;
  }

  static UserShareCULog fromUpdateLog(LogSync log) {
    final data = jsonDecode(log.operateData) as Map<String, dynamic>;
    return UserShareCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doUpdate()
        .withData(UserShareTable.toUpdateCompanion(
          isEnabled: data['isEnabled'] as bool?,
        )) as UserShareCULog;
  }

  static UserShareCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => UserShareCULog.fromCreateLog(log),
      OperateType.update => UserShareCULog.fromUpdateLog(log),
      _ => UserShareCULog.fromUpdateLog(log),
    };
  }

  static UserShareTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return UserShareTable.fromJson(json);
  }
}
