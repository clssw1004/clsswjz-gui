import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../../utils/date_util.dart';
import 'base_table.dart';

@DataClassName('ItemRelField')
class ItemRelFieldTable extends BaseTable {
  TextColumn get itemId => text()();
  TextColumn get fieldCode => text()();
  TextColumn get fieldValue => text()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {itemId, fieldCode, fieldValue};

  static ItemRelFieldTableCompanion toCreateCompanion({
    required String itemId,
    required String fieldCode,
    required String fieldValue,
    int? sortOrder,
  }) {
    return ItemRelFieldTableCompanion(
      id: Value(IdUtil.genId()),
      itemId: Value(itemId),
      fieldCode: Value(fieldCode),
      fieldValue: Value(fieldValue),
      sortOrder: Value.absentIfNull(sortOrder),
      createdAt: Value(DateUtil.now()),
      updatedAt: Value(DateUtil.now()),
    );
  }

  static String toJsonString(ItemRelFieldTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'itemId', companion.itemId);
    MapUtil.setIfPresent(map, 'fieldCode', companion.fieldCode);
    MapUtil.setIfPresent(map, 'fieldValue', companion.fieldValue);
    MapUtil.setIfPresent(map, 'sortOrder', companion.sortOrder);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    return jsonEncode(map);
  }
}
