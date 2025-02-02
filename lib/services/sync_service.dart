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
import 'package:flutter/foundation.dart';

/// 数据同步服务
class SyncService extends BaseService {
  static const double progressStart = 0.0;
  static const double progressCheckServerHealth = 5.0;
  static const double progressGetLocalChanges = 10.0;
  static const double progressLocalChangeCount = 15.0;
  static const double progressUploadAttachments = 20.0;
  static const double progressUploadComplete = 25.0;
  static const double progressSyncLocalChanges = 30.0;
  static const double progressLocalSyncComplete = 35.0;
  static const double progressSyncLocalStatus = 40.0;
  static const double progressLocalStatusComplete = 45.0;
  static const double progressSyncServerChanges = 50.0;
  static const double progressDownloadAttachments = 55.0;
  static const double progressDownloadComplete = 60.0;
  static const double progressServerSyncComplete = 65.0;
  static const double progressCompletePre = 99.0;
  static const double progressComplete = 100.0;

  SyncService();

  Future<void> syncChanges({Function(double percent, String message)? onProgress}) async {
    try {
      final isServerOk = await _checkServerHealth(onProgress: onProgress);
      if (!isServerOk) {
        return;
      }
      final l10n = L10nManager.l10n;
      int? lastSyncTime = AppConfigManager.instance.lastSyncTime;
      final lastSyncTimeStr = lastSyncTime != null ? DateUtil.format(lastSyncTime) : l10n.neverSync;
      await _processOnProgress(onProgress, progressStart, l10n.syncStarting(lastSyncTimeStr));
      List<LogSync> clientChanges = await _listChangeLogs(onProgress: onProgress);
      // 同步本地变更到服务器
      final syncResult =
          await _syncClientChanges<SyncResponseDTO>(logs: clientChanges, syncTimeStamp: lastSyncTime, onProgress: onProgress);
      // 同步服务器变更到本地
      await _syncServerChanges(changes: syncResult.changes, syncTimestamp: syncResult.syncTimeStamp, onProgress: onProgress);
      AppConfigManager.instance.setLastSyncTime(syncResult.syncTimeStamp);
      await _processOnProgress(onProgress, progressComplete, l10n.syncComplete);
    } catch (e, stackTrace) {
      debugPrint('Sync error: $e');
      debugPrint('Stack trace: $stackTrace');
      await _processOnProgress(onProgress, progressComplete, L10nManager.l10n.syncFailed('$e\n$stackTrace'));
    }
  }

  Future<bool> _checkServerHealth({Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    await _processOnProgress(onProgress, progressStart, l10n.checkingServerStatus);
    final serverHealth = await ServiceManager.currentServer.checkHealth();
    final result = serverHealth.ok && serverHealth.data?.status == 'ok';
    if (!result) {
      await _processOnProgress(onProgress, progressComplete, l10n.syncFailed(l10n.serverConnectionTimeout));
      return false;
    } else {
      await _processOnProgress(onProgress, progressComplete, l10n.serverConnectionOk);
    }
    return result;
  }

  /// 获取本地变更
  Future<List<LogSync>> _listChangeLogs({Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    await _processOnProgress(onProgress, progressGetLocalChanges, l10n.gettingLocalChanges);
    final logs = await DaoManager.logSyncDao.listChangeLogs();
    await _processOnProgress(onProgress, progressLocalChangeCount, l10n.localChangeCount(logs.length));
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
      await _processOnProgress(onProgress, progressUploadAttachments, l10n.uploadingAttachments(attachments.length));
      final files = attachments.where((e) => e.file != null).map((e) => (e.file!)).toList();
      final response = await HttpClient.instance.uploadFiles<List<String>>(
        path: '/api/attachments/upload',
        files: files,
      );
      await _processOnProgress(onProgress, progressUploadComplete, l10n.attachmentUploadComplete);
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
    await _processOnProgress(onProgress, progressDownloadAttachments, l10n.downloadingAttachments(attachmentIds.length));
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
      await _processOnProgress(onProgress, progressDownloadAttachments, l10n.downloadingAttachmentsProgress(i + 1, attachmentIds.length));
    }
    await _processOnProgress(onProgress, progressDownloadComplete, l10n.attachmentDownloadComplete);
  }

  /// 同步本地变更到服务端
  Future<SyncResponseDTO> _syncClientChanges<T>(
      {required List<LogSync> logs, required int? syncTimeStamp, Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    // 同步附件
    await _uploadFiles(localChanges: logs, syncTimestamp: syncTimeStamp, onProgress: onProgress);
    await _processOnProgress(onProgress, progressSyncLocalChanges, l10n.syncingLocalChanges(logs.length));
    final response = await HttpClient.instance.post<SyncResponseDTO>(
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
        await _processOnProgress(onProgress, progressLocalSyncComplete, l10n.localChangeSyncComplete(resultLogs.length, success, failed));
        await _syncLogState(results: resultLogs, syncTimestamp: result.syncTimeStamp, onProgress: onProgress);
      }
      return result;
    }
    throw Exception(response.message);
  }

  Future<void> _syncLogState(
      {required List<SyncResultDTO> results, required int syncTimestamp, Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    await _processOnProgress(onProgress, progressSyncLocalStatus, l10n.syncingLocalChangeStatus(results.length));
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
      await _processOnProgress(onProgress, progressSyncLocalStatus, l10n.syncingLocalChangeStatusProgress(i + 1, results.length));
    }
    await _processOnProgress(onProgress, progressLocalStatusComplete, l10n.localChangeStatusSyncComplete);
  }

  /// 同步服务端变更
  Future<void> _syncServerChanges(
      {required List<LogSync> changes, required int syncTimestamp, Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    await _processOnProgress(onProgress, progressSyncServerChanges, l10n.syncingServerChanges(changes.length));
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
      await _processOnProgress(onProgress, progressSyncServerChanges, l10n.syncingServerChangesProgress(i + 1, changes.length));
    }
    await _downloadFiles(serverChanges: changes, syncTimestamp: syncTimestamp, onProgress: onProgress);
    await _processOnProgress(onProgress, progressServerSyncComplete, l10n.serverChangeSyncComplete);
  }

  /// 处理进度
  Future<void> _processOnProgress(Function(double percent, String message)? onProgress, double percent, String message) async {
    if (onProgress != null) {
      onProgress(percent, message);
    }
    if (percent == progressComplete) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }
}
