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

  /// 后台同步进度回调（由 SyncProvider 设置，供 _startBackgroundSync 使用）
  Function(double percent, String message)? _backgroundProgressCallback;

  /// 设置后台同步进度回调
  void setBackgroundProgressCallback(
      Function(double percent, String message)? callback) {
    _backgroundProgressCallback = callback;
  }

  /// 前端同步用：P0+P1 类型码（编译期确定，只需计算一次）
  static final List<String> _priorityTypes = BusinessType.values
      .where((t) =>
          t.syncPriority == SyncPriority.critical ||
          t.syncPriority == SyncPriority.high)
      .map((t) => t.code)
      .toList();

  /// 后台同步用：P2+P3 类型码（编译期确定，只需计算一次）
  static final List<String> _backgroundTypes = BusinessType.values
      .where((t) =>
          t.syncPriority == SyncPriority.normal ||
          t.syncPriority == SyncPriority.low)
      .map((t) => t.code)
      .toList();

  Future<void> syncChanges({
    Function(double percent, String message)? onProgress,
    bool priorityOnly = false,
  }) async {
    try {
      final isServerOk = await _checkServerHealth(onProgress: onProgress);
      if (!isServerOk) return;

      final l10n = L10nManager.l10n;
      int? lastSyncTime = AppConfigManager.instance.lastSyncTime;
      final lastSyncTimeStr =
          lastSyncTime != null ? DateUtil.format(lastSyncTime) : l10n.neverSync;
      await _processOnProgress(
          onProgress, progressStart, l10n.syncStarting(lastSyncTimeStr));
      List<LogSync> clientChanges =
          await _listChangeLogs(onProgress: onProgress);

      // 阶段 1：Push - 上传本地变更到服务端
      final pushResult = await _pushClientChanges(
        logs: clientChanges,
        syncTimeStamp: lastSyncTime,
        onProgress: onProgress,
      );

      // 阶段 2：Pull - 分页拉取服务端变更
      if (priorityOnly) {
        // 首次启动：只拉 P0+P1，不更新 lastSyncTime
        await _pullServerChanges(
          syncTimeStamp: lastSyncTime ?? 0,
          businessTypes: _priorityTypes,
          commitId: pushResult.commitId,
          onProgress: onProgress,
          progressStart: progressSyncServerChanges,
          progressEnd: progressDownloadAttachments,
          downloadAttachments: false,
        );
        // 后台启动剩余数据同步
        _startBackgroundSync(lastSyncTime ?? 0, pushResult.commitId);
      } else {
        // 完整/日常同步
        int finalSyncTimeStamp = pushResult.syncTimeStamp;
        if (pushResult.totalChanges > 0) {
          finalSyncTimeStamp = await _pullServerChanges(
            syncTimeStamp: lastSyncTime ?? 0,
            commitId: pushResult.commitId,
            onProgress: onProgress,
            progressStart: progressSyncServerChanges,
            progressEnd: progressDownloadAttachments,
            downloadAttachments: true,
          );
        }
        AppConfigManager.instance.setLastSyncTime(finalSyncTimeStamp);
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

  /// Push 本地变更到服务端
  Future<SyncPushResponse> _pushClientChanges({
    required List<LogSync> logs,
    required int? syncTimeStamp,
    Function(double percent, String message)? onProgress,
  }) async {
    final l10n = L10nManager.l10n;
    // 上传附件
    await _uploadFiles(
        localChanges: logs,
        syncTimestamp: syncTimeStamp,
        onProgress: onProgress);
    await _processOnProgress(onProgress, progressSyncLocalChanges,
        l10n.syncingLocalChanges(logs.length));
    // POST /api/sync/push
    final requestData = <String, dynamic>{
      'logs': logs.map((e) => e.toJson()).toList(),
      'syncTimeStamp': syncTimeStamp,
    };
    final response = await HttpClient.instance.post<SyncPushResponse>(
      path: '/api/sync/push',
      data: requestData,
      transform: (data) => SyncPushResponse.fromJson(data['data']),
    );
    if (response.ok) {
      final result = response.data!;
      if (result.results.isNotEmpty) {
        int success =
            result.results.where((e) => e.syncState == SyncState.synced).length;
        int failed =
            result.results.where((e) => e.syncState == SyncState.failed).length;
        await _processOnProgress(onProgress, progressLocalSyncComplete,
            l10n.localChangeSyncComplete(result.results.length, success, failed));
        await _syncLogState(
            results: result.results,
            syncTimestamp: result.syncTimeStamp,
            onProgress: onProgress);
      }
      return result;
    }
    throw Exception(response.message);
  }

  /// 将指定日志批量推送到服务端（分页上传，每批 2000 条）
  /// 用于迁移数据到新服务器场景
  Future<void> pushLogsToServer(List<LogSync> logs) async {
    if (logs.isEmpty) return;
    const batchSize = 2000;
    for (var start = 0; start < logs.length; start += batchSize) {
      final end = start + batchSize > logs.length ? logs.length : start + batchSize;
      final batch = logs.sublist(start, end);
      final response = await HttpClient.instance.post<SyncPushResponse>(
        path: '/api/sync/push',
        data: {
          'logs': batch.map((e) => e.toJson()).toList(),
          'syncTimeStamp': null,
        },
        transform: (data) => SyncPushResponse.fromJson(data['data']),
      );
      if (!response.ok) throw Exception(response.message);
      debugPrint('Pushed batch ${start ~/ batchSize + 1}/${(logs.length + batchSize - 1) ~/ batchSize}: ${batch.length} logs');
    }
  }

  /// 分页拉取服务端变更
  /// [downloadAttachments] 为 true 时同步完成后下载附件文件
  /// 返回最后页的 syncTimeStamp
  Future<int> _pullServerChanges({
    required int syncTimeStamp,
    List<String>? businessTypes,
    String? commitId,
    Function(double percent, String message)? onProgress,
    required double progressStart,
    required double progressEnd,
    bool downloadAttachments = false,
  }) async {
    const pageSize = 1000;
    int finalSyncTimeStamp = 0;
    // 收集所有附件 ID（仅 downloadAttachments=true 时）
    final List<String> allAttachmentIds = [];

    // 1. 先拉第一页获取总条数
    final firstData = <String, dynamic>{
      'syncTimeStamp': syncTimeStamp,
      'page': 1,
      'pageSize': pageSize,
    };
    if (businessTypes != null && businessTypes.isNotEmpty) {
      firstData['businessTypes'] = businessTypes;
    }
    if (commitId != null && commitId.isNotEmpty) {
      firstData['commitId'] = commitId;
    }

    final firstResp = await HttpClient.instance.post<SyncPullResponse>(
      path: '/api/sync/pull',
      data: firstData,
      transform: (data) => SyncPullResponse.fromJson(data['data']),
    );
    if (!firstResp.ok) throw Exception(firstResp.message);
    final firstResult = firstResp.data!;

    finalSyncTimeStamp = firstResult.syncTimeStamp;
    final int totalChanges = firstResult.total;
    final int totalPages =
        totalChanges > 0 ? (totalChanges + pageSize - 1) ~/ pageSize : 1;
    final double rangePerPage =
        totalPages > 0 ? (progressEnd - progressStart) / totalPages : 0.0;

    // 2. 逐页拉取，每页各自占用一段进度区间
    int cumulativeProcessed = 0;
    for (int page = 1; page <= totalPages; page++) {
      final SyncPullResponse pullResult;
      if (page == 1) {
        pullResult = firstResult;
      } else {
        final pageData = <String, dynamic>{
          'syncTimeStamp': syncTimeStamp,
          'page': page,
          'pageSize': pageSize,
        };
        if (businessTypes != null && businessTypes.isNotEmpty) {
          pageData['businessTypes'] = businessTypes;
        }
        if (commitId != null && commitId.isNotEmpty) {
          pageData['commitId'] = commitId;
        }
        final resp = await HttpClient.instance.post<SyncPullResponse>(
          path: '/api/sync/pull',
          data: pageData,
          transform: (data) => SyncPullResponse.fromJson(data['data']),
        );
        if (!resp.ok) throw Exception(resp.message);
        pullResult = resp.data!;
      }

      finalSyncTimeStamp = pullResult.syncTimeStamp;

      if (pullResult.changes.isNotEmpty) {
        final l10n = L10nManager.l10n;
        await _applyChanges(
          changes: pullResult.changes,
          onProgress: onProgress,
          getProgressDetail: (processed, _) =>
              l10n.syncingServerChangesProgress(
                  cumulativeProcessed + processed, totalChanges),
          progressStart: progressStart + (page - 1) * rangePerPage,
          progressEnd: progressStart + page * rangePerPage,
          batchTransaction: false,
        );
        cumulativeProcessed += pullResult.changes.length;
        if (downloadAttachments) {
          for (final change in pullResult.changes) {
            if (BusinessType.fromCode(change.businessType) ==
                    BusinessType.attachment &&
                OperateType.fromCode(change.operateType) ==
                    OperateType.create) {
              allAttachmentIds.add(change.businessId);
            }
          }
        }
      }
    }

    // 3. 下载附件文件
    if (downloadAttachments && allAttachmentIds.isNotEmpty) {
      final l10n = L10nManager.l10n;
      await _processOnProgress(onProgress, progressDownloadAttachments,
          l10n.downloadingAttachments(allAttachmentIds.length));
      for (var i = 0; i < allAttachmentIds.length; i++) {
        final filePath =
            await AttachmentUtil.getAttachmentPath(allAttachmentIds[i]);
        final exists = await File(filePath).exists();
        if (!exists) {
          await HttpClient.instance.downloadFile(
            fileId: allAttachmentIds[i],
            savePath: filePath,
          );
        }
        await _processOnProgress(onProgress, progressDownloadAttachments,
            l10n.downloadingAttachmentsProgress(i + 1, allAttachmentIds.length));
      }
      await _processOnProgress(
          onProgress, progressDownloadComplete, l10n.attachmentDownloadComplete);
    }

    return finalSyncTimeStamp;
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

  /// 批量应用变更（支持批量事务模式）
  /// [batchTransaction] 为 true 时所有变更在同一个事务中执行（用于数据量小且需保证完整性的 P0+P1），
  /// 为 false 时每条变更独立事务并逐条汇报进度（用于数据量大且需隔离的 P2+P3）
  Future<void> _applyChanges({
    required List<LogSync> changes,
    required Function(double percent, String message)? onProgress,
    required String Function(int processed, int total) getProgressDetail,
    required double progressStart,
    required double progressEnd,
    bool batchTransaction = false,
  }) async {
    if (changes.isEmpty) return;

    final total = changes.length;

    // 批量 ID 存在性检查（一次查询代替逐条查询）
    final allIds = changes.map((e) => e.id).toList();
    final existingIds = await DaoManager.logSyncDao.existIdsSet(allIds);

    final filtered = changes
        .where((c) => !existingIds.contains(c.id) && c.businessType.isNotEmpty)
        .toList();

    if (filtered.isEmpty) {
      await _processOnProgress(
          onProgress, progressEnd, getProgressDetail(total, total));
      return;
    }

    if (batchTransaction) {
      // 分批批量事务：每批最多 100 条，分批提交
      // 适用于 P0+P1 基础数据——既要保证效率，又避免大事务阻塞 UI
      const batchSize = 100;
      for (var start = 0; start < filtered.length; start += batchSize) {
        final end = (start + batchSize > filtered.length)
            ? filtered.length
            : start + batchSize;
        final batch = filtered.sublist(start, end);
        await DatabaseManager.db.transaction(() async {
          for (final change in batch) {
            final log = LogBuilder.fromLog(change);
            await log.executeWithoutRecord();
            await DaoManager.logSyncDao.insert(change);
          }
        });
        // 每批交让渡一次事件循环，保证 UI 响应
        await Future.delayed(const Duration(milliseconds: 5));
        final processedPercent =
            (((end) * 100) / total).floor();
        final progress = progressStart +
            (processedPercent / 100.0) * (progressEnd - progressStart);
        await _processOnProgress(onProgress, progress,
            getProgressDetail(end, total));
      }
      await _processOnProgress(
          onProgress, progressEnd, getProgressDetail(total, total));
    } else {
      // 默认 100 条一批事务，若批量失败则降级该批为逐条事务
      const batchSize = 100;
      int lastPercentStep = -1;
      for (var start = 0; start < filtered.length; start += batchSize) {
        final end = (start + batchSize > filtered.length)
            ? filtered.length
            : start + batchSize;
        final batch = filtered.sublist(start, end);
        try {
          await DatabaseManager.db.transaction(() async {
            for (final change in batch) {
              final log = LogBuilder.fromLog(change);
              await log.executeWithoutRecord();
              await DaoManager.logSyncDao.insert(change);
            }
          });
        } catch (e) {
          // 批量失败，降级为该批逐条事务
          debugPrint('Batch failed (${batch.length} items), fallback to per-record: $e');
          for (final change in batch) {
            try {
              await DatabaseManager.db.transaction(() async {
                final log = LogBuilder.fromLog(change);
                await log.executeWithoutRecord();
                await DaoManager.logSyncDao.insert(change);
              });
            } catch (e2) {
              debugPrint('Per-record fallback failed: ${change.id} - $e2');
            }
          }
        }
        await Future.delayed(const Duration(milliseconds: 5));
        final processedPercent = (((end) * 100) / total).floor();
        if (processedPercent > lastPercentStep) {
          lastPercentStep = processedPercent;
          final progress = progressStart +
              (processedPercent / 100.0) * (progressEnd - progressStart);
          await _processOnProgress(onProgress, progress,
              getProgressDetail(end, total));
        }
      }
    }
  }

  bool _backgroundSyncRunning = false;
  int _backgroundSyncGeneration = 0;

  /// 重置后台同步状态，在 app_init.dart 中调用以处理热重载/重启后状态残留
  void resetBackgroundSyncState() {
    _backgroundSyncRunning = false;
    _backgroundProgressCallback = null;
    _backgroundSyncGeneration++;
  }

  /// 后台同步 P2+P3 数据
  /// 分页拉取服务端变更，通过 businessTypes 参数让服务端按优先级类型过滤返回
  void _startBackgroundSync(int syncTimeStamp, String commitId) {
    if (_backgroundSyncRunning) return;
    _backgroundSyncRunning = true;
    final generation = _backgroundSyncGeneration;
    // 延迟启动，确保 APP 导航完成、UI 稳定后再开始大量数据写入
    Future.delayed(const Duration(seconds: 3), () async {
      // 如果 generation 变了，说明 app 已重启/重初始化，放弃旧会话的后台同步
      if (generation != _backgroundSyncGeneration) {
        debugPrint('Background sync cancelled: generation changed');
        _backgroundSyncRunning = false;
        return;
      }
      try {
        // 用 try-catch 包装回调，防止 SyncProvider 被 dispose 后调用 notifyListeners 崩溃
        final safeCallback = _backgroundProgressCallback;
        final finalSyncTimeStamp = await _pullServerChanges(
          syncTimeStamp: syncTimeStamp,
          businessTypes: _backgroundTypes,
          commitId: commitId,
          onProgress: safeCallback != null
              ? (percent, msg) {
                  try {
                    safeCallback(percent, msg);
                  } catch (_) {
                    // SyncProvider 已销毁，停止回调
                  }
                }
              : (_, __) {},
          progressStart: 0.0,
          progressEnd: 1.0,
        );
        // 无论有无数据，都更新 lastSyncTime 并通知完成
        AppConfigManager.instance.setLastSyncTime(finalSyncTimeStamp);
        EventBus.instance.emit(const SyncCompletedEvent());
        debugPrint('Background sync completed');
      } catch (e, stackTrace) {
        debugPrint('Background sync error: $e\n$stackTrace');
      } finally {
        if (generation == _backgroundSyncGeneration) {
          _backgroundSyncRunning = false;
          _backgroundProgressCallback = null;
        }
      }
    });
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
