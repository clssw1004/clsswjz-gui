import 'package:drift/drift.dart';
import '../manager/database_manager.dart';
import '../utils/id_util.dart';

abstract class BaseService {

  /// 生成UUID
  String generateUuid() {
    return IdUtil.genId();
  }

  Value<T> absentIfNull<T>(T? value) {
    return value != null ? Value(value) : const Value.absent();
  }

  /// 批量插入辅助方法
  Future<void> batchInsert<T extends Table, D>(
    TableInfo<T, D> table,
    List<Insertable<D>> rows, {
    int batchSize = 100,
    bool failOnError = true,
  }) async {
    for (var i = 0; i < rows.length; i += batchSize) {
      final end = (i + batchSize < rows.length) ? i + batchSize : rows.length;
      final batch = rows.sublist(i, end);
      await DatabaseManager.db.batch((batchObj) {
        for (var row in batch) {
          batchObj.insert(table, row, mode: InsertMode.insertOrReplace);
        }
      });
    }
  }
}
