import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('ItemRelation')
class ItemRelationTable extends BaseBusinessTable {
  TextColumn get itemId => text().named('item_id')();
  TextColumn get accountBookId => text().named('account_book_id')();
  TextColumn get relationCode => text().named('relation_code')();
  TextColumn get relationId => text().named('relation_id')();

  static ItemRelationTableCompanion toCreateCompanion(
    String who, {
    required String itemId,
    required String accountBookId,
    required String relationCode,
    required String relationId,
  }) {
    return ItemRelationTableCompanion(
      id: Value(IdUtil.genId()),
      itemId: Value(itemId),
      accountBookId: Value(accountBookId),
      relationCode: Value(relationCode),
      relationId: Value(relationId),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  static String toJsonString(ItemRelationTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'itemId', companion.itemId);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'relationCode', companion.relationCode);
    MapUtil.setIfPresent(map, 'relationId', companion.relationId);
    return jsonEncode(map);
  }
}
