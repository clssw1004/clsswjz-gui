import 'package:drift/drift.dart';
import '../../utils/collection_util.dart';
import '../database.dart';
import '../tables/item_rel_field_table.dart';
import 'base_dao.dart';

class ItemRelFieldDao extends BaseDao<ItemRelFieldTable, ItemRelField> {
  ItemRelFieldDao(super.db);

  Future<List<ItemRelField>> findByItemId(String itemId) {
    return (db.select(table)..where((t) => t.itemId.equals(itemId))).get();
  }

  Future<Map<String, List<ItemRelField>>> findByItemIds(
    List<String> itemIds, {
    String? fieldCode,
  }) {
    var query = db.select(table)..where((t) => t.itemId.isIn(itemIds));
    if (fieldCode != null) {
      query = query..where((t) => t.fieldCode.equals(fieldCode));
    }
    return query.get().then(
        (rows) => CollectionUtil.groupBy(rows, (r) => r.itemId));
  }

  Future<List<ItemRelField>> findByFieldCodeAndValues(
      String fieldCode, List<String> values) {
    return (db.select(table)
      ..where((t) =>
          t.fieldCode.equals(fieldCode) &
          t.fieldValue.isIn(values))
    ).get();
  }

  Future<int> deleteByItemAndCode(String itemId, String fieldCode) {
    return (db.delete(table)
      ..where((t) =>
          t.itemId.equals(itemId) &
          t.fieldCode.equals(fieldCode))
    ).go();
  }

  Future<void> insert(ItemRelFieldTableCompanion companion) async {
    await db.into(table).insert(companion);
  }

  @override
  TableInfo<ItemRelFieldTable, ItemRelField> get table => db.itemRelFieldTable;
}
