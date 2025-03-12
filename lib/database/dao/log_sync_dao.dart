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
}
