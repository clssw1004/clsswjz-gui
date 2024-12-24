import 'package:drift/drift.dart';
import 'package:flutter_gui/database/database_service.dart';
import 'package:flutter_gui/database/database.dart';
import '../utils/id.util.dart';

abstract class BaseService {
  final AppDatabase db = DatabaseService.db;

  /// 生成UUID
  String generateUuid() {
    return genId();
  }

  dynamic absentIfNull(dynamic value) {
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
      await db.batch((batchObj) {
        for (var row in batch) {
          batchObj.insert(table, row, mode: InsertMode.insertOrReplace);
        }
      });
    }
  }
}
