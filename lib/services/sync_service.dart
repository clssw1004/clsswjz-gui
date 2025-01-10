import 'dart:io';

import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/database/tables/log_sync_table.dart';
import 'package:clsswjz/enums/operate_type.dart';
import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import 'package:clsswjz/manager/service_manager.dart';
import 'package:clsswjz/utils/date_util.dart';
import '../drivers/special/log/builder/builder.dart';
import '../enums/business_type.dart';
import '../enums/sync_state.dart';
import '../manager/database_manager.dart';
import '../manager/l10n_manager.dart';
import '../models/sync.dart';
import '../utils/attachment.util.dart';
import '../utils/http_client.dart';
import 'base_service.dart';

/// 数据同步服务
class SyncService extends BaseService {
  final HttpClient _httpClient;

  SyncService({required HttpClient httpClient}) : _httpClient = httpClient;

  Future<void> syncChanges({Function(double percent, String message)? onProgress}) async {
    try {
      final l10n = L10nManager.l10n;
      int? lastSyncTime = AppConfigManager.instance.lastSyncTime;
      final lastSyncTimeStr = lastSyncTime != null ? DateUtil.format(lastSyncTime) : l10n.neverSync;
      await _processOnProgress(onProgress, 0, l10n.syncStarting(lastSyncTimeStr));
      List<LogSync> clientChanges = await _listChangeLogs(onProgress: onProgress);
      // 同步本地变更到服务器
      final syncResult =
          await _syncClientChanges<SyncResponseDTO>(logs: clientChanges, syncTimeStamp: lastSyncTime, onProgress: onProgress);
      // 同步服务器变更到本地
      await _syncServerChanges(changes: syncResult.changes, syncTimestamp: syncResult.syncTimeStamp, onProgress: onProgress);
      AppConfigManager.instance.setLastSyncTime(syncResult.syncTimeStamp);
      await _processOnProgress(onProgress, 100, l10n.syncComplete);
    } catch (e) {
      await _processOnProgress(onProgress, 100, L10nManager.l10n.syncFailed(e.toString()));
      rethrow;
    }
  }

  /// 获取本地变更
  Future<List<LogSync>> _listChangeLogs({Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    await _processOnProgress(onProgress, 5, l10n.gettingLocalChanges);
    final logs = await DaoManager.logSyncDao.listChangeLogs();
    await _processOnProgress(onProgress, 10, l10n.localChangeCount(logs.length));
    return logs;
  }

  Future<void> _uploadFiles({List<LogSync>? localChanges, int? syncTimestamp, Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    final newAttachmentIds = localChanges
        ?.where((e) =>
            BusinessType.fromCode(e.businessType) == BusinessType.attachment && OperateType.fromCode(e.operateType) == OperateType.create)
        .map((e) => e.businessId)
        .toList();
    if (newAttachmentIds == null || newAttachmentIds.isEmpty) return;

    final attachments = await ServiceManager.attachmentService.getAttachments(newAttachmentIds);
    if (attachments.isNotEmpty) {
      await _processOnProgress(onProgress, 15, l10n.uploadingAttachments(attachments.length));
      final files = attachments.where((e) => e.file != null).map((e) => (e.file!)).toList();
      final response = await HttpClient.instance.uploadFiles<List<String>>(
        path: '/api/attachments/upload',
        files: files,
      );
      await _processOnProgress(onProgress, 20, l10n.attachmentUploadComplete);
      if (response.ok) {
        return;
      }
    }
  }

  Future<void> _downloadFiles(
      {List<LogSync>? serverChanges, int? syncTimestamp, Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    final attachmentIds = serverChanges
        ?.where((e) =>
            BusinessType.fromCode(e.businessType) == BusinessType.attachment && OperateType.fromCode(e.operateType) == OperateType.create)
        .map((e) => e.businessId)
        .toList();
    if (attachmentIds == null || attachmentIds.isEmpty) return;
    await _processOnProgress(onProgress, 50, l10n.downloadingAttachments(attachmentIds.length));
    for (var i = 0; i < attachmentIds.length; i++) {
      final attachmentId = attachmentIds[i];
      final filePath = await AttachmentUtil.getAttachmentPath(attachmentId);
      final exists = await File(filePath).exists();
      if (!exists) {
        await HttpClient.instance.downloadFile(
          fileId: attachmentId,
          savePath: filePath,
        );
      }
      await _processOnProgress(onProgress, 50, l10n.downloadingAttachmentsProgress(i + 1, attachmentIds.length));
    }
    await _processOnProgress(onProgress, 55, l10n.attachmentDownloadComplete);
  }

  /// 同步本地变更到服务端
  Future<SyncResponseDTO> _syncClientChanges<T>(
      {required List<LogSync> logs, required int? syncTimeStamp, Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    // 同步附件
    await _uploadFiles(localChanges: logs, syncTimestamp: syncTimeStamp, onProgress: onProgress);
    await _processOnProgress(onProgress, 25, l10n.syncingLocalChanges(logs.length));
    final response = await _httpClient.post<SyncResponseDTO>(
      path: '/api/sync/changes',
      data: {
        'logs': logs.map((e) => e.toJson()).toList(),
        'syncTimeStamp': syncTimeStamp,
      },
      transform: (data) => SyncResponseDTO.fromJson(data['data']),
    );
    if (response.ok) {
      final result = response.data!;
      final resultLogs = result.results;
      if (resultLogs.isNotEmpty) {
        int success = resultLogs.where((e) => e.syncState == SyncState.synced).length;
        int failed = resultLogs.where((e) => e.syncState == SyncState.failed).length;
        await _processOnProgress(onProgress, 30, l10n.localChangeSyncComplete(resultLogs.length, success, failed));
        await _syncLogState(results: resultLogs, syncTimestamp: result.syncTimeStamp, onProgress: onProgress);
      }
      return result;
    }
    throw Exception(response.message);
  }

  Future<void> _syncLogState(
      {required List<SyncResultDTO> results, required int syncTimestamp, Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    await _processOnProgress(onProgress, 35, l10n.syncingLocalChangeStatus(results.length));
    for (var i = 0; i < results.length; i++) {
      final result = results[i];
      await DaoManager.logSyncDao.update(
        result.logId,
        LogSyncTable.toUpdateCompanion(
          result.syncState,
          syncTimestamp,
          result.syncError,
        ),
      );
      await _processOnProgress(onProgress, 35, l10n.syncingLocalChangeStatusProgress(i + 1, results.length));
    }
    await _processOnProgress(onProgress, 40, l10n.localChangeStatusSyncComplete);
  }

  /// 同步服务端变更
  Future<void> _syncServerChanges(
      {required List<LogSync> changes, required int syncTimestamp, Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    await _processOnProgress(onProgress, 45, l10n.syncingServerChanges(changes.length));
    for (var i = 0; i < changes.length; i++) {
      final change = changes[i];
      bool exist = await DaoManager.logSyncDao.existById(change.id);
      if (!exist) {
        await DatabaseManager.db.transaction(() async {
          final log = LogBuilder.fromLog(change);
          await log.executeWithoutRecord();
          await DaoManager.logSyncDao.insert(change);
        });
      }
      await _processOnProgress(onProgress, 45, l10n.syncingServerChangesProgress(i + 1, changes.length));
    }
    await _downloadFiles(serverChanges: changes, syncTimestamp: syncTimestamp, onProgress: onProgress);
    await _processOnProgress(onProgress, 60, l10n.serverChangeSyncComplete);
  }

  /// 处理进度
  Future<void> _processOnProgress(Function(double percent, String message)? onProgress, double percent, String message) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (onProgress != null) {
      onProgress(percent, message);
    }
  }
}
