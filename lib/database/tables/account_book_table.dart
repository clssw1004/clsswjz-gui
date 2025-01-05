import 'dart:convert';

import 'package:clsswjz/utils/id_util.dart';
import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('AccountBook')
class AccountBookTable extends BaseBusinessTable {
  TextColumn get name => text().named('name')();
  TextColumn get description => text().nullable().named('description')();
  TextColumn get currencySymbol =>
      text().named('currency_symbol').withDefault(const Constant('¥'))();
  TextColumn get icon => text().nullable().named('icon')();

  static AccountBookTableCompanion toUpdateCompanion(
    String who, {
    String? name,
    String? description,
    String? currencySymbol,
    String? icon,
  }) {
    return AccountBookTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      name: Value.absentIfNull(name),
      description: Value.absentIfNull(description),
      icon: Value.absentIfNull(icon),
      currencySymbol: Value.absentIfNull(currencySymbol),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
    );
  }

  static AccountBookTableCompanion toCreateCompanion(String who,
          {required String name,
          String? description,
          required String currencySymbol,
          String? icon}) =>
      AccountBookTableCompanion(
        id: Value(IdUtil.genId()),
        name: Value(name),
        description: Value.absentIfNull(description),
        currencySymbol: Value(currencySymbol),
        icon: Value.absentIfNull(icon),
        createdBy: Value(who),
        createdAt: Value(DateUtil.now()),
        updatedBy: Value(who),
        updatedAt: Value(DateUtil.now()),
      );

  static String toJsonString(AccountBookTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'name', companion.name);
    MapUtil.setIfPresent(map, 'description', companion.description);
    MapUtil.setIfPresent(map, 'currencySymbol', companion.currencySymbol);
    MapUtil.setIfPresent(map, 'icon', companion.icon);
    return jsonEncode(map);
  }
}
