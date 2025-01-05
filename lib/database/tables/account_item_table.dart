import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('AccountItem')
class AccountItemTable extends BaseBusinessTable {
  RealColumn get amount => real().named('amount')();
  TextColumn get description => text().nullable().named('description')();
  TextColumn get type => text().named('type')();
  TextColumn get categoryCode => text().nullable().named('category_code')();
  TextColumn get accountDate => text().named('account_date')();
  TextColumn get accountBookId => text().named('account_book_id')();
  TextColumn get fundId => text().nullable().named('fund_id')();
  TextColumn get shopCode => text().nullable().named('shop_code')();
  TextColumn get tagCode => text().nullable().named('tag_code')();
  TextColumn get projectCode => text().nullable().named('project_code')();

  static AccountItemTableCompanion toUpdateCompanion(
    String who, {
    double? amount,
    String? description,
    String? type,
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
      type: Value.absentIfNull(type),
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
    required String type,
    String? categoryCode,
    required String accountDate,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
  }) =>
      AccountItemTableCompanion(
        id: Value(IdUtils.genId()),
        amount: Value(amount),
        description: Value.absentIfNull(description),
        type: Value(type),
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
    return jsonEncode(map);
  }
}
