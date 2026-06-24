import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 固定收支配置表
@DataClassName('RecurringConfig')
class RecurringConfigTable extends BaseAccountBookTable {
  /// 类型: INCOME / EXPENSE
  TextColumn get type =>
      text().named('type').withLength(min: 1, max: 16)();

  /// 金额
  RealColumn get amount => real().named('amount')();

  /// 备注
  TextColumn get description =>
      text().nullable().named('description')();

  /// 分类code
  TextColumn get categoryCode =>
      text().named('category_code').withLength(min: 1, max: 32)();

  /// 账户ID
  TextColumn get fundId =>
      text().named('fund_id').withLength(min: 1, max: 64)();

  /// 商户code
  TextColumn get shopCode =>
      text().nullable().named('shop_code')();

  /// 标签code
  TextColumn get tagCode =>
      text().nullable().named('tag_code')();

  /// 项目code
  TextColumn get projectCode =>
      text().nullable().named('project_code')();

  /// 频率类型: weekly / monthly
  TextColumn get frequencyType =>
      text().named('frequency_type').withLength(min: 1, max: 16)();

  /// 频率值: weekly用"1,3,5"(星期), monthly用"1,15"(日期)
  TextColumn get frequencyValue =>
      text().named('frequency_value').withLength(min: 1, max: 64)();

  /// 开始日期 yyyy-MM-dd
  TextColumn get startDate =>
      text().named('start_date').withLength(min: 1, max: 16)();

  /// 结束条件类型: infinite / date / count
  TextColumn get endType =>
      text().named('end_type').withLength(min: 1, max: 16)();

  /// 结束日期(endType=date时)
  TextColumn get endDate =>
      text().nullable().named('end_date')();

  /// 总次数(endType=count时)
  IntColumn get endCount =>
      integer().nullable().named('end_count')();

  /// 已生成次数
  IntColumn get generatedCount =>
      integer().named('generated_count').withDefault(const Constant(0))();

  /// 上次生成时间 yyyy-MM-dd HH:mm:ss
  TextColumn get lastGeneratedAt =>
      text().nullable().named('last_generated_at')();

  /// 启用状态
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();

  /// 更新Companion
  static RecurringConfigTableCompanion toUpdateCompanion(
    String who, {
    String? type,
    double? amount,
    String? description,
    String? categoryCode,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    String? frequencyType,
    String? frequencyValue,
    String? startDate,
    String? endType,
    String? endDate,
    int? endCount,
    bool? isActive,
    int? generatedCount,
    String? lastGeneratedAt,
  }) {
    return RecurringConfigTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      type: Value.absentIfNull(type),
      amount: Value.absentIfNull(amount),
      description: Value.absentIfNull(description),
      categoryCode: Value.absentIfNull(categoryCode),
      fundId: Value.absentIfNull(fundId),
      shopCode: Value.absentIfNull(shopCode),
      tagCode: Value.absentIfNull(tagCode),
      projectCode: Value.absentIfNull(projectCode),
      frequencyType: Value.absentIfNull(frequencyType),
      frequencyValue: Value.absentIfNull(frequencyValue),
      startDate: Value.absentIfNull(startDate),
      endType: Value.absentIfNull(endType),
      endDate: Value.absentIfNull(endDate),
      endCount: Value.absentIfNull(endCount),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
      generatedCount: generatedCount != null ? Value(generatedCount) : const Value.absent(),
      lastGeneratedAt: Value.absentIfNull(lastGeneratedAt),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
      accountBookId: const Value.absent(),
      id: const Value.absent(),
    );
  }

  /// 创建Companion
  static RecurringConfigTableCompanion toCreateCompanion(
    String who,
    String accountBookId, {
    required String type,
    required double amount,
    String? description,
    required String categoryCode,
    required String fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    required String frequencyType,
    required String frequencyValue,
    required String startDate,
    required String endType,
    String? endDate,
    int? endCount,
  }) {
    return RecurringConfigTableCompanion(
      id: Value(IdUtil.genId()),
      accountBookId: Value(accountBookId),
      type: Value(type),
      amount: Value(amount),
      description: Value.absentIfNull(description),
      categoryCode: Value(categoryCode),
      fundId: Value(fundId),
      shopCode: Value.absentIfNull(shopCode),
      tagCode: Value.absentIfNull(tagCode),
      projectCode: Value.absentIfNull(projectCode),
      frequencyType: Value(frequencyType),
      frequencyValue: Value(frequencyValue),
      startDate: Value(startDate),
      endType: Value(endType),
      endDate: Value.absentIfNull(endDate),
      endCount: Value.absentIfNull(endCount),
      generatedCount: const Value(0),
      lastGeneratedAt: const Value.absent(),
      isActive: const Value(true),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(RecurringConfigTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'type', companion.type);
    MapUtil.setIfPresent(map, 'amount', companion.amount);
    MapUtil.setIfPresent(map, 'description', companion.description);
    MapUtil.setIfPresent(map, 'categoryCode', companion.categoryCode);
    MapUtil.setIfPresent(map, 'fundId', companion.fundId);
    MapUtil.setIfPresent(map, 'shopCode', companion.shopCode);
    MapUtil.setIfPresent(map, 'tagCode', companion.tagCode);
    MapUtil.setIfPresent(map, 'projectCode', companion.projectCode);
    MapUtil.setIfPresent(map, 'frequencyType', companion.frequencyType);
    MapUtil.setIfPresent(map, 'frequencyValue', companion.frequencyValue);
    MapUtil.setIfPresent(map, 'startDate', companion.startDate);
    MapUtil.setIfPresent(map, 'endType', companion.endType);
    MapUtil.setIfPresent(map, 'endDate', companion.endDate);
    MapUtil.setIfPresent(map, 'endCount', companion.endCount);
    MapUtil.setIfPresent(map, 'generatedCount', companion.generatedCount);
    MapUtil.setIfPresent(map, 'lastGeneratedAt', companion.lastGeneratedAt);
    MapUtil.setIfPresent(map, 'isActive', companion.isActive);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    return jsonEncode(map);
  }

  /// 从JSON对象创建Companion（用于日志恢复）
  static RecurringConfigTableCompanion fromJson(Map<String, dynamic> json) {
    return RecurringConfigTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      accountBookId: json['accountBookId'] != null ? Value(json['accountBookId'] as String) : const Value.absent(),
      type: json['type'] != null ? Value(json['type'] as String) : const Value.absent(),
      amount: json['amount'] != null ? Value(json['amount'] as double) : const Value.absent(),
      description: json['description'] != null ? Value(json['description'] as String) : const Value.absent(),
      categoryCode: json['categoryCode'] != null ? Value(json['categoryCode'] as String) : const Value.absent(),
      fundId: json['fundId'] != null ? Value(json['fundId'] as String) : const Value.absent(),
      shopCode: json['shopCode'] != null ? Value(json['shopCode'] as String) : const Value.absent(),
      tagCode: json['tagCode'] != null ? Value(json['tagCode'] as String) : const Value.absent(),
      projectCode: json['projectCode'] != null ? Value(json['projectCode'] as String) : const Value.absent(),
      frequencyType: json['frequencyType'] != null ? Value(json['frequencyType'] as String) : const Value.absent(),
      frequencyValue: json['frequencyValue'] != null ? Value(json['frequencyValue'] as String) : const Value.absent(),
      startDate: json['startDate'] != null ? Value(json['startDate'] as String) : const Value.absent(),
      endType: json['endType'] != null ? Value(json['endType'] as String) : const Value.absent(),
      endDate: json['endDate'] != null ? Value(json['endDate'] as String) : const Value.absent(),
      endCount: json['endCount'] != null ? Value(json['endCount'] as int) : const Value.absent(),
      generatedCount: json['generatedCount'] != null ? Value(json['generatedCount'] as int) : const Value.absent(),
      lastGeneratedAt: json['lastGeneratedAt'] != null ? Value(json['lastGeneratedAt'] as String) : const Value.absent(),
      isActive: json['isActive'] != null ? Value(json['isActive'] as bool) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
    );
  }
}
