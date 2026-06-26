import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/bookkeeping_rule_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

/// 记账规则日志构建器
class BookkeepingRuleCULog extends LogBuilder<BookkeepingRuleTableCompanion, String> {
  BookkeepingRuleCULog() : super() {
    doWith(BusinessType.bookkeepingRule);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.bookkeepingRuleDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.bookkeepingRuleDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.bookkeepingRuleDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return BookkeepingRuleTable.toJsonString(data as BookkeepingRuleTableCompanion);
  }

  /// 从创建日志恢复
  static BookkeepingRuleCULog fromCreateLog(LogSync log) {
    return BookkeepingRuleCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as BookkeepingRuleCULog;
  }

  /// 从更新日志恢复
  static BookkeepingRuleCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return BookkeepingRuleCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .target(log.businessId)
        .doUpdate()
        .withData(BookkeepingRuleTable.toUpdateCompanion(
          log.operatorId,
          name: data['name'] as String?,
          isActive: data['isActive'] as bool?,
          priority: data['priority'] as int?,
          conditionsJson: data['conditionsJson'] as String?,
          actionsJson: data['actionsJson'] as String?,
        )) as BookkeepingRuleCULog;
  }

  /// 从日志恢复
  static BookkeepingRuleCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => BookkeepingRuleCULog.fromCreateLog(log),
      OperateType.update => BookkeepingRuleCULog.fromUpdateLog(log),
      _ => BookkeepingRuleCULog.fromUpdateLog(log),
    };
  }

  /// 创建
  static BookkeepingRuleCULog create({
    required String who,
    required String bookId,
    required String name,
    required bool isActive,
    required int priority,
    required String conditionsJson,
    required String actionsJson,
  }) {
    return BookkeepingRuleCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(BookkeepingRuleTable.toCreateCompanion(
          who,
          bookId,
          name: name,
          isActive: isActive,
          priority: priority,
          conditionsJson: conditionsJson,
          actionsJson: actionsJson,
        )) as BookkeepingRuleCULog;
  }

  /// 更新
  static BookkeepingRuleCULog update({
    required String who,
    required String id,
    String? name,
    bool? isActive,
    int? priority,
    String? conditionsJson,
    String? actionsJson,
  }) {
    return BookkeepingRuleCULog()
        .who(who)
        .target(id)
        .doUpdate()
        .withData(BookkeepingRuleTable.toUpdateCompanion(
          who,
          name: name,
          isActive: isActive,
          priority: priority,
          conditionsJson: conditionsJson,
          actionsJson: actionsJson,
        )) as BookkeepingRuleCULog;
  }

  /// 删除
  static BookkeepingRuleCULog delete({
    required String who,
    required String id,
  }) {
    return BookkeepingRuleCULog()
        .who(who)
        .target(id)
        .doDelete() as BookkeepingRuleCULog;
  }

  /// 解析JSON为Companion
  static BookkeepingRuleTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return BookkeepingRuleTable.fromJson(json);
  }
}
