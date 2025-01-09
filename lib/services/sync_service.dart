import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/database/tables/log_sync_table.dart';
import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import '../drivers/special/log/builder/builder.dart';
import '../enums/sync_state.dart';
import '../models/sync.dart';
import '../utils/http_client.dart';
import 'base_service.dart';

/// 数据同步服务
class SyncService extends BaseService {
  final HttpClient _httpClient;

  SyncService({required HttpClient httpClient}) : _httpClient = httpClient;

  Future<void> syncChanges({Function(int percent, String message)? onProgress}) async {
    try {
      int lastSyncTime = AppConfigManager.instance.lastSyncTime ?? -1;
      await _processOnProgress(onProgress, 0, '开始同步，获取本地变更');
      List<LogSync> clientChanges = await _listChangeLogs();
      if (clientChanges.isNotEmpty) {
        await _processOnProgress(onProgress, 10, '本地变更：${clientChanges.length}，开始同步本地变更到服务端');
      } else {
        await _processOnProgress(onProgress, 10, '本地无变更');
      }
      final syncResult = await _syncChangesToServer<SyncResponseDTO>(clientChanges, lastSyncTime);
      final resultLogs = syncResult.results;
      if (resultLogs.isNotEmpty) {
        int success = resultLogs.where((e) => e.syncState == SyncState.synced).length;
        int failed = resultLogs.where((e) => e.syncState == SyncState.failed).length;
        await _processOnProgress(onProgress, 30, '服务端同步完成：${resultLogs.length}，成功：$success，失败：$failed');
        await _syncLogState(resultLogs, syncResult.syncTimeStamp);
      }
      if (syncResult.changes.isNotEmpty) {
        await _processOnProgress(onProgress, 40, '服务端变更：${syncResult.changes.length}，开始同步到本地');
        await _syncChanges(syncResult.changes, syncResult.syncTimeStamp);
        await _processOnProgress(onProgress, 50, '本地同步完成');
      } else {
        await _processOnProgress(onProgress, 50, '服务端无变更');
      }
      AppConfigManager.instance.setLastSyncTime(syncResult.syncTimeStamp);
      await _processOnProgress(onProgress, 100, '同步完成');
    } catch (e) {
      await _processOnProgress(onProgress, 100, '同步失败：$e');
    }
  }

  /// 同步服务端变更
  Future<void> _syncChanges(List<LogSync> changes, int syncTimestamp) async {
    for (var change in changes) {
      final log = LogBuilder.fromLog(change);
      await log.executeWithoutRecord();
    }
    DaoManager.logSyncDao.batchInsert(changes);
  }

  Future<void> _syncLogState(List<SyncResultDTO> results, int syncTimestamp) async {
    for (var result in results) {
      await DaoManager.logSyncDao.update(
        result.logId,
        LogSyncTable.toUpdateCompanion(
          result.syncState,
          syncTimestamp,
          result.syncError,
        ),
      );
    }
  }

  /// 同步本地变更到服务端
  Future<SyncResponseDTO> _syncChangesToServer<T>(List<LogSync> logs, int syncTimeStamp) async {
    final response = await _httpClient.post<SyncResponseDTO>(
      path: '/api/sync/changes',
      data: {
        'logs': logs.map((e) => e.toJson()).toList(),
        'syncTimeStamp': syncTimeStamp,
      },
      transform: (data) => SyncResponseDTO.fromJson(data['data']),
    );

    if (response.success) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  /// 获取本地变更
  Future<List<LogSync>> _listChangeLogs() async {
    return await DaoManager.logSyncDao.listChangeLogs();
  }

  /// 处理进度
  Future<void> _processOnProgress(Function(int percent, String message)? onProgress, int percent, String message) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (onProgress != null) {
      onProgress(percent, message);
    }
  }
}
