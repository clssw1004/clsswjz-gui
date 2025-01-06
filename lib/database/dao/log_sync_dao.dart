import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/log_sync_table.dart';
import 'base_dao.dart';

class LogSyncDao extends BaseDao<LogSyncTable, LogSync> {
  LogSyncDao(super.db);

  @override
  TableInfo<LogSyncTable, LogSync> get table => db.logSyncTable;
}
