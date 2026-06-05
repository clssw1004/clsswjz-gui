import 'package:drift/drift.dart';
import '../../utils/collection_util.dart';
import '../database.dart';
import '../tables/item_relation_table.dart';
import 'base_dao.dart';

class ItemRelationDao extends BaseDao<ItemRelationTable, ItemRelation> {
  ItemRelationDao(super.db);

  Future<List<ItemRelation>> findByItemId(String itemId) {
    return (db.select(table)..where((t) => t.itemId.equals(itemId))).get();
  }

  Future<List<ItemRelation>> findByRelation(String code, String id) {
    return (db.select(table)
      ..where((t) =>
        t.relationCode.equals(code) &
        t.relationId.equals(id))
    ).get();
  }

  Future<Map<String, List<ItemRelation>>> findByItemIds(List<String> itemIds) {
    return (db.select(table)
      ..where((t) => t.itemId.isIn(itemIds))
    ).get().then((rows) => CollectionUtil.groupBy(rows, (r) => r.itemId));
  }

  Future<int> deleteByItemAndRelation(String itemId, String relationCode, String relationId) {
    return (db.delete(table)
      ..where((t) =>
        t.itemId.equals(itemId) &
        t.relationCode.equals(relationCode) &
        t.relationId.equals(relationId))
    ).go();
  }

  @override
  TableInfo<ItemRelationTable, ItemRelation> get table => db.itemRelationTable;
}
