import 'package:drift/drift.dart';
import '../../enums/sync_state.dart';
import '../database.dart';
import '../tables/log_sync_table.dart';
import 'base_dao.dart';

class LogSyncDao extends BaseDao<LogSyncTable, LogSync> {
  LogSyncDao(super.db);

  @override
  TableInfo<LogSyncTable, LogSync> get table => db.logSyncTable;

  Future<List<LogSync>> listChangeLogs() async {
    return await (db.select(db.logSyncTable)..where((tbl) => tbl.syncState.equals(SyncState.unsynced.value))).get();
  }

  /// 获取所有日志记录（不限 syncState），用于迁移数据到新服务器
  Future<List<LogSync>> listAllLogs() async {
    return await (db.select(db.logSyncTable)).get();
  }

  /// 批量查询 ID 存在性，返回已存在 ID 的集合
  /// 用于批量同步时一次性判断，避免逐条查询
  Future<Set<String>> existIdsSet(List<String> ids) async {
    if (ids.isEmpty) return {};
    final rows = await (db.select(db.logSyncTable)
      ..where((tbl) => tbl.id.isIn(ids))
    ).get();
    return rows.map((e) => e.id).toSet();
  }
}
