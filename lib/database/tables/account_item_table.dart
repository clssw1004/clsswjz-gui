import 'dart:convert';

import 'package:drift/drift.dart';
import '../../enums/account_type.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('AccountItem')
class AccountItemTable extends BaseAccountBookTable {
  RealColumn get amount => real().named('amount')();
  TextColumn get description => text().nullable().named('description')();
  TextColumn get type => text().named('type')();
  TextColumn get categoryCode => text().nullable().named('category_code')();
  TextColumn get accountDate => text().named('account_date')();
  TextColumn get fundId => text().nullable().named('fund_id')();
  TextColumn get shopCode => text().nullable().named('shop_code')();
  TextColumn get tagCode => text().nullable().named('tag_code')();
  TextColumn get projectCode => text().nullable().named('project_code')();
  /// 账目来源
  TextColumn get source => text().nullable().named('source')();
  /// 账目来源ID
  TextColumn get sourceId => text().nullable().named('source_id')();

  static AccountItemTableCompanion toUpdateCompanion(
    String who, {
    double? amount,
    String? description,
    AccountItemType? type,
    String? categoryCode,
    String? accountDate,
    String? accountBookId,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
  }) {
    return AccountItemTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      amount: Value.absentIfNull(amount),
      description: Value.absentIfNull(description),
      type: Value.absentIfNull(type?.code),
      categoryCode: Value.absentIfNull(categoryCode),
      accountDate: Value.absentIfNull(accountDate),
      accountBookId: Value.absentIfNull(accountBookId),
      fundId: Value.absentIfNull(fundId),
      shopCode: Value.absentIfNull(shopCode),
      tagCode: Value.absentIfNull(tagCode),
      projectCode: Value.absentIfNull(projectCode),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
  );
  }

  static AccountItemTableCompanion toCreateCompanion(
    String who,
    String accountBookId, {
    required double amount,
    String? description,
    required AccountItemType type,
    String? categoryCode,
    required String accountDate,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    String? source,
    String? sourceId,
  }) =>
      AccountItemTableCompanion(
        id: Value(IdUtil.genId()),
        accountBookId: Value(accountBookId),
        amount: Value(amount),
        description: Value.absentIfNull(description),
        type: Value(type.code),
        categoryCode: Value.absentIfNull(categoryCode),
        accountDate: Value(accountDate),
        fundId: Value.absentIfNull(fundId),
        shopCode: Value.absentIfNull(shopCode),
        tagCode: Value.absentIfNull(tagCode),
        projectCode: Value.absentIfNull(projectCode),
        createdBy: Value(who),
        createdAt: Value(DateUtil.now()),
        updatedBy: Value(who),
        updatedAt: Value(DateUtil.now()),
        source: Value.absentIfNull(source),
        sourceId: Value.absentIfNull(sourceId),
      );

  static String toJsonString(AccountItemTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'amount', companion.amount);
    MapUtil.setIfPresent(map, 'description', companion.description);
    MapUtil.setIfPresent(map, 'type', companion.type);
    MapUtil.setIfPresent(map, 'categoryCode', companion.categoryCode);
    MapUtil.setIfPresent(map, 'accountDate', companion.accountDate);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'fundId', companion.fundId);
    MapUtil.setIfPresent(map, 'shopCode', companion.shopCode);
    MapUtil.setIfPresent(map, 'tagCode', companion.tagCode);
    MapUtil.setIfPresent(map, 'projectCode', companion.projectCode);
    MapUtil.setIfPresent(map, 'source', companion.source);
    MapUtil.setIfPresent(map, 'sourceId', companion.sourceId);
    return jsonEncode(map);
  }
}
