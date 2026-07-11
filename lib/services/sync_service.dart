import 'dart:io';
import '../database/database.dart';
import '../database/tables/log_sync_table.dart';
import '../drivers/special/log/builder/builder.dart';
import '../enums/business_type.dart';
import '../enums/operate_type.dart';
import '../enums/sync_state.dart';
import '../events/event_bus.dart';
import '../events/special/event_sync.dart';
import '../manager/app_config_manager.dart';
import '../manager/dao_manager.dart';
import '../manager/database_manager.dart';
import '../manager/l10n_manager.dart';
import '../manager/service_manager.dart';
import '../models/sync.dart';
import '../utils/attachment.util.dart';
import '../utils/date_util.dart';
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
  static const double progressDownloadAttachments = 70.0;
  static const double progressDownloadComplete = 75.0;
  static const double progressServerSyncComplete = 80.0;
  static const double progressCompletePre = 99.0;
  static const double progressComplete = 100.0;

  SyncService();

  /// 前端同步用：P0+P1 类型码
  List<String> get _priorityTypes => BusinessType.values
      .where((t) =>
          t.syncPriority == SyncPriority.critical ||
          t.syncPriority == SyncPriority.high)
      .map((t) => t.code)
      .toList();

  /// 后台同步用：P2+P3 类型码
  List<String> get _backgroundTypes => BusinessType.values
      .where((t) =>
          t.syncPriority == SyncPriority.normal ||
          t.syncPriority == SyncPriority.low)
      .map((t) => t.code)
      .toList();

  Future<void> syncChanges(
      {Function(double percent, String message)? onProgress,
      bool priorityOnly = false}) async {
    try {
      final isServerOk = await _checkServerHealth(onProgress: onProgress);
      if (!isServerOk) {
        return;
      }
      final l10n = L10nManager.l10n;
      int? lastSyncTime = AppConfigManager.instance.lastSyncTime;
      final lastSyncTimeStr =
          lastSyncTime != null ? DateUtil.format(lastSyncTime) : l10n.neverSync;
      await _processOnProgress(
          onProgress, progressStart, l10n.syncStarting(lastSyncTimeStr));
      List<LogSync> clientChanges =
          await _listChangeLogs(onProgress: onProgress);
      // 同步本地变更到服务器
      final syncResult = await _syncClientChanges<SyncResponseDTO>(
          logs: clientChanges,
          syncTimeStamp: lastSyncTime,
          businessTypes: priorityOnly ? _priorityTypes : null,
          onProgress: onProgress);
      // 同步服务器变更到本地（支持按优先级分批）
      await _syncServerChanges(
          changes: syncResult.changes,
          syncTimestamp: syncResult.syncTimeStamp,
          onProgress: onProgress,
          priorityOnly: priorityOnly);
      // 优先级同步不立即更新 lastSyncTime，由后台同步完成后更新
      if (!priorityOnly) {
        AppConfigManager.instance.setLastSyncTime(syncResult.syncTimeStamp);
      }
      await _processOnProgress(onProgress, progressComplete, l10n.syncComplete);
    } catch (e, stackTrace) {
      debugPrint('Sync error: $e');
      debugPrint('Stack trace: $stackTrace');
      await _processOnProgress(onProgress, progressComplete,
          L10nManager.l10n.syncFailed('$e\n$stackTrace'));
    }
  }

  Future<bool> _checkServerHealth(
      {Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    await _processOnProgress(
        onProgress, progressStart, l10n.checkingServerStatus);
    final serverHealth = await ServiceManager.currentServer.checkHealth();
    final result = serverHealth.ok && serverHealth.data?.status == 'ok';
    if (!result) {
      await _processOnProgress(onProgress, progressComplete,
          l10n.syncFailed(l10n.serverConnectionTimeout));
      return false;
    } else {
      await _processOnProgress(
          onProgress, progressCheckServerHealth, l10n.serverConnectionOk);
    }
    return result;
  }

  /// 获取本地变更
  Future<List<LogSync>> _listChangeLogs(
      {Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    await _processOnProgress(
        onProgress, progressGetLocalChanges, l10n.gettingLocalChanges);
    final logs = await DaoManager.logSyncDao.listChangeLogs();
    await _processOnProgress(onProgress, progressLocalChangeCount,
        l10n.localChangeCount(logs.length));
    return logs;
  }

  Future<void> _uploadFiles(
      {List<LogSync>? localChanges,
      int? syncTimestamp,
      Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    final newAttachmentIds = localChanges
        ?.where((e) =>
            BusinessType.fromCode(e.businessType) == BusinessType.attachment &&
            OperateType.fromCode(e.operateType) == OperateType.create)
        .map((e) => e.businessId)
        .toList();
    if (newAttachmentIds == null || newAttachmentIds.isEmpty) return;

    final attachments =
        await ServiceManager.attachmentService.getAttachments(newAttachmentIds);
    if (attachments.isNotEmpty) {
      await _processOnProgress(onProgress, progressUploadAttachments,
          l10n.uploadingAttachments(attachments.length));
      final files = attachments
          .where((e) => e.file != null)
          .map((e) => (e.file!))
          .toList();
      final response = await HttpClient.instance.uploadFiles<List<String>>(
        path: '/api/attachments/upload',
        files: files,
      );
      await _processOnProgress(
          onProgress, progressUploadComplete, l10n.attachmentUploadComplete);
      if (response.ok) {
        return;
      }
    }
  }

  Future<void> _downloadFiles(
      {List<LogSync>? serverChanges,
      int? syncTimestamp,
      Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    final attachmentIds = serverChanges
        ?.where((e) =>
            BusinessType.fromCode(e.businessType) == BusinessType.attachment &&
            OperateType.fromCode(e.operateType) == OperateType.create)
        .map((e) => e.businessId)
        .toList();
    if (attachmentIds == null || attachmentIds.isEmpty) return;
    await _processOnProgress(onProgress, progressDownloadAttachments,
        l10n.downloadingAttachments(attachmentIds.length));
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
      await _processOnProgress(onProgress, progressDownloadAttachments,
          l10n.downloadingAttachmentsProgress(i + 1, attachmentIds.length));
    }
    await _processOnProgress(
        onProgress, progressDownloadComplete, l10n.attachmentDownloadComplete);
  }

  /// 同步本地变更到服务端
  Future<SyncResponseDTO> _syncClientChanges<T>(
      {required List<LogSync> logs,
      required int? syncTimeStamp,
      List<String>? businessTypes,
      Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    // 同步附件
    await _uploadFiles(
        localChanges: logs,
        syncTimestamp: syncTimeStamp,
        onProgress: onProgress);
    await _processOnProgress(onProgress, progressSyncLocalChanges,
        l10n.syncingLocalChanges(logs.length));
    final requestData = <String, dynamic>{
      'logs': logs.map((e) => e.toJson()).toList(),
      'syncTimeStamp': syncTimeStamp,
    };
    if (businessTypes != null && businessTypes.isNotEmpty) {
      requestData['businessTypes'] = businessTypes;
    }
    final response = await HttpClient.instance.post<SyncResponseDTO>(
      path: '/api/sync/changes',
      data: requestData,
      transform: (data) => SyncResponseDTO.fromJson(data['data']),
    );
    if (response.ok) {
      final result = response.data!;
      final resultLogs = result.results;
      if (resultLogs.isNotEmpty) {
        int success =
            resultLogs.where((e) => e.syncState == SyncState.synced).length;
        int failed =
            resultLogs.where((e) => e.syncState == SyncState.failed).length;
        await _processOnProgress(onProgress, progressLocalSyncComplete,
            l10n.localChangeSyncComplete(resultLogs.length, success, failed));
        await _syncLogState(
            results: resultLogs,
            syncTimestamp: result.syncTimeStamp,
            onProgress: onProgress);
      }
      return result;
    }
    throw Exception(response.message);
  }

  Future<void> _syncLogState(
      {required List<SyncResultDTO> results,
      required int syncTimestamp,
      Function(double percent, String message)? onProgress}) async {
    final l10n = L10nManager.l10n;
    await _processOnProgress(onProgress, progressSyncLocalStatus,
        l10n.syncingLocalChangeStatus(results.length));
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
      await _processOnProgress(onProgress, progressSyncLocalStatus,
          l10n.syncingLocalChangeStatusProgress(i + 1, results.length));
    }
    await _processOnProgress(onProgress, progressLocalStatusComplete,
        l10n.localChangeStatusSyncComplete);
  }

  /// 按优先级分组服务端变更
  Map<SyncPriority, List<LogSync>> _groupByPriority(List<LogSync> changes) {
    final grouped = <SyncPriority, List<LogSync>>{
      SyncPriority.critical: [],
      SyncPriority.high: [],
      SyncPriority.normal: [],
      SyncPriority.low: [],
    };
    for (final change in changes) {
      final businessType = BusinessType.fromCode(change.businessType);
      final priority =
          businessType?.syncPriority ?? SyncPriority.low;
      grouped[priority]!.add(change);
    }
    return grouped;
  }

  /// 批量应用变更（使用批量 ID 存在性检查优化）
  Future<void> _applyChanges({
    required List<LogSync> changes,
    required Function(double percent, String message)? onProgress,
    required String Function(int processed, int total) getProgressDetail,
    required double progressStart,
    required double progressEnd,
  }) async {
    if (changes.isEmpty) return;

    final total = changes.length;
    int lastPercentStep = -1;

    // 批量 ID 存在性检查（一次查询代替逐条查询）
    final allIds = changes.map((e) => e.id).toList();
    final existingIds = await DaoManager.logSyncDao.existIdsSet(allIds);

    for (var i = 0; i < total; i++) {
      final change = changes[i];
      if (!existingIds.contains(change.id) && change.businessType.isNotEmpty) {
        await DatabaseManager.db.transaction(() async {
          final log = LogBuilder.fromLog(change);
          await log.executeWithoutRecord();
          await DaoManager.logSyncDao.insert(change);
        });
      }
      final processedPercent = (((i + 1) * 100) / total).floor();
      if (processedPercent > lastPercentStep) {
        lastPercentStep = processedPercent;
        final progress = progressStart +
            (processedPercent / 100.0) * (progressEnd - progressStart);
        await _processOnProgress(onProgress, progress,
            getProgressDetail(i + 1, total));
      }
    }
  }

  /// 在后台静默同步剩余数据（无进度回调）
  /// 每处理 N 条让渡一次控制权给 UI 线程，避免长时间阻塞导致 ANR
  Future<void> _applyChangesSilent(List<LogSync> changes) async {
    if (changes.isEmpty) return;
    const batchSize = 30; // 每 30 条让渡一次 UI
    final allIds = changes.map((e) => e.id).toList();
    final existingIds = await DaoManager.logSyncDao.existIdsSet(allIds);
    for (var i = 0; i < changes.length; i++) {
      final change = changes[i];
      if (!existingIds.contains(change.id) && change.businessType.isNotEmpty) {
        try {
          await DatabaseManager.db.transaction(() async {
            final log = LogBuilder.fromLog(change);
            await log.executeWithoutRecord();
            await DaoManager.logSyncDao.insert(change);
          });
        } catch (e) {
          // 后台同步单条失败不影响其余数据
          debugPrint('Background sync item failed: ${change.id} - $e');
        }
      }
      // 每 batchSize 条让渡一次事件循环，保证 UI 响应
      if ((i + 1) % batchSize == 0) {
        await Future.delayed(Duration.zero);
      }
    }
  }

  bool _backgroundSyncRunning = false;

  /// 后台同步 P2+P3 数据
  /// 发起独立的 API 请求，通过 businessTypes 参数让服务端过滤返回
  /// 若服务端不支持过滤，返回全量数据时由 existIdsSet 去重跳过已处理记录
  void _startBackgroundSync(List<LogSync> fallbackChanges, int syncTimestamp) {
    if (_backgroundSyncRunning) return;
    _backgroundSyncRunning = true;
    // 延迟启动，确保 APP 导航完成、UI 稳定后再开始大量数据写入
    Future.delayed(const Duration(seconds: 3), () async {
      try {
        List<LogSync> changes;
        int finalSyncTimestamp = syncTimestamp;

        // 尝试通过 API 分类型请求后台数据
        final response = await HttpClient.instance.post<SyncResponseDTO>(
          path: '/api/sync/changes',
          data: {
            'logs': <Map<String, dynamic>>[],
            'syncTimeStamp': null, // 首次全量，仅筛选类型
            'businessTypes': _backgroundTypes,
          },
          transform: (data) => SyncResponseDTO.fromJson(data['data']),
        );

        if (response.ok && response.data != null) {
          changes = response.data!.changes;
          finalSyncTimestamp = response.data!.syncTimeStamp;
          debugPrint(
              'Background sync API returned: ${changes.length} changes');
        } else {
          // API 请求失败，回退到本地已返回的数据
          changes = fallbackChanges;
          debugPrint(
              'Background sync API failed, using fallback: ${changes.length} changes');
        }

        if (changes.isNotEmpty) {
          debugPrint(
              'Background sync started: ${changes.length} changes remaining');
          await _applyChangesSilent(changes);
          // 下载后台数据中的附件文件
          await _downloadFiles(
              serverChanges: changes,
              syncTimestamp: finalSyncTimestamp,
              onProgress: null);
        } else {
          debugPrint('Background sync: no changes to process');
        }
        // 无论有无数据，都更新 lastSyncTime 并通知完成
        AppConfigManager.instance.setLastSyncTime(finalSyncTimestamp);
        EventBus.instance.emit(const SyncCompletedEvent());
        debugPrint('Background sync completed');
      } catch (e, stackTrace) {
        debugPrint('Background sync error: $e\n$stackTrace');
      } finally {
        _backgroundSyncRunning = false;
      }
    });
  }

  /// 同步服务端变更
  Future<void> _syncServerChanges(
      {required List<LogSync> changes,
      required int syncTimestamp,
      Function(double percent, String message)? onProgress,
      bool priorityOnly = false}) async {
    if (changes.isEmpty) {
      await _processOnProgress(
          onProgress, progressDownloadAttachments, L10nManager.l10n.serverChangeSyncComplete);
      return;
    }

    final l10n = L10nManager.l10n;
    await _processOnProgress(onProgress, progressSyncServerChanges,
        l10n.syncingServerChanges(changes.length));

    // 按优先级分组
    final grouped = _groupByPriority(changes);
    final priorityChanges = [
      ...grouped[SyncPriority.critical]!,
      ...grouped[SyncPriority.high]!,
    ];
    final backgroundChanges = [
      ...grouped[SyncPriority.normal]!,
      ...grouped[SyncPriority.low]!,
    ];

    if (priorityOnly) {
      // 首次启动：仅同步 P0+P1，剩余数据后台处理
      debugPrint(
          'Priority sync: ${priorityChanges.length} priority changes, '
          '${backgroundChanges.length} background changes');

      // 同步优先级数据
      await _applyChanges(
        changes: priorityChanges,
        onProgress: onProgress,
        getProgressDetail: (processed, total) =>
            l10n.syncingServerChangesProgress(processed, total),
        progressStart: progressSyncServerChanges,
        progressEnd: progressDownloadAttachments,
      );

      // 后台启动剩余数据同步
      _startBackgroundSync(backgroundChanges, syncTimestamp);

      await _processOnProgress(onProgress, progressServerSyncComplete,
          l10n.serverChangeSyncComplete);
    } else {
      // 完整同步：按优先级顺序全部处理
      await _applyChanges(
        changes: priorityChanges,
        onProgress: onProgress,
        getProgressDetail: (processed, total) =>
            l10n.syncingServerChangesProgress(processed, total),
        progressStart: progressSyncServerChanges,
        progressEnd: progressSyncServerChanges +
            (priorityChanges.length / changes.length) * 0.3,
      );
      await _applyChanges(
        changes: backgroundChanges,
        onProgress: onProgress,
        getProgressDetail: (processed, total) =>
            l10n.syncingServerChangesProgress(
                priorityChanges.length + processed, changes.length),
        progressStart: progressSyncServerChanges +
            (priorityChanges.length / changes.length) * 0.3,
        progressEnd: progressDownloadAttachments,
      );

      await _downloadFiles(
          serverChanges: changes,
          syncTimestamp: syncTimestamp,
          onProgress: onProgress);
      await _processOnProgress(
          onProgress, progressServerSyncComplete, l10n.serverChangeSyncComplete);
    }
  }

  /// 处理进度
  Future<void> _processOnProgress(
      Function(double percent, String message)? onProgress,
      double percent,
      String message) async {
    if (onProgress != null) {
      onProgress(percent, message);
      await Future.delayed(const Duration(milliseconds: 1));
    }
    if (percent == progressComplete) {
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }
}
