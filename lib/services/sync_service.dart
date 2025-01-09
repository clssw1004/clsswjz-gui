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
import '../models/sync.dart';
import '../utils/attachment.util.dart';
import '../utils/http_client.dart';
import 'base_service.dart';

/// 数据同步服务
class SyncService extends BaseService {
  final HttpClient _httpClient;

  SyncService({required HttpClient httpClient}) : _httpClient = httpClient;

  Future<void> syncChanges({Function(int percent, String message)? onProgress}) async {
    try {
      int lastSyncTime = AppConfigManager.instance.lastSyncTime ?? -1;
      await _processOnProgress(onProgress, 0, '开始同步，上次同步时间：${DateUtil.format(lastSyncTime)}');
      List<LogSync> clientChanges = await _listChangeLogs(onProgress: onProgress);
      // 同步本地变更到服务器
      final syncResult =
          await _syncClientChanges<SyncResponseDTO>(logs: clientChanges, syncTimeStamp: lastSyncTime, onProgress: onProgress);
      // 同步服务器变更到本地
      await _syncServerChanges(changes: syncResult.changes, syncTimestamp: syncResult.syncTimeStamp, onProgress: onProgress);
      AppConfigManager.instance.setLastSyncTime(syncResult.syncTimeStamp);
      await _processOnProgress(onProgress, 100, '同步完成');
    } catch (e) {
      await _processOnProgress(onProgress, 100, '同步失败：$e');
    }
  }

  /// 处理进度
  Future<void> _processOnProgress(Function(int percent, String message)? onProgress, int percent, String message) async {
    // await Future.delayed(const Duration(milliseconds: 1000));
    if (onProgress != null) {
      onProgress(percent, message);
    }
  }

  /// 获取本地变更
  Future<List<LogSync>> _listChangeLogs({Function(int percent, String message)? onProgress}) async {
    await _processOnProgress(onProgress, 5, '获取本地变更');
    final logs = await DaoManager.logSyncDao.listChangeLogs();
    await _processOnProgress(onProgress, 10, '本地变更数量：${logs.length}');
    return logs;
  }

  Future<void> _uploadFiles({List<LogSync>? localChanges, int? syncTimestamp, Function(int percent, String message)? onProgress}) async {
    final newAttachmentIds = localChanges
        ?.where((e) =>
            BusinessType.fromCode(e.businessType) == BusinessType.attachment && OperateType.fromCode(e.operateType) == OperateType.create)
        .map((e) => e.businessId)
        .toList();
    if (newAttachmentIds == null || newAttachmentIds.isEmpty) return;

    final attachments = await ServiceManager.attachmentService.getAttachments(newAttachmentIds);
    if (attachments.isNotEmpty) {
      await _processOnProgress(onProgress, 15, '上传附件: ${attachments.length}');
      final files = attachments.where((e) => e.file != null).map((e) => (e.file!)).toList();
      final response = await HttpClient.instance.uploadFiles<List<String>>(
        path: '/api/attachments/upload',
        files: files,
      );
      await _processOnProgress(onProgress, 20, '附件上传完成');
      if (response.ok) {
        return;
      }
    }
  }

  Future<void> _downloadFiles({List<LogSync>? serverChanges, int? syncTimestamp, Function(int percent, String message)? onProgress}) async {
    final attachmentIds = serverChanges
        ?.where((e) =>
            BusinessType.fromCode(e.businessType) == BusinessType.attachment && OperateType.fromCode(e.operateType) == OperateType.create)
        .map((e) => e.businessId)
        .toList();
    if (attachmentIds == null || attachmentIds.isEmpty) return;
    await _processOnProgress(onProgress, 50, '下载附件: ${attachmentIds.length}');
    for (var attachmentId in attachmentIds) {
      final filePath = await AttachmentUtil.getAttachmentPath(attachmentId);
      final exists = await File(filePath).exists();
      if (!exists) {
        await HttpClient.instance.downloadFile(
          fileId: attachmentId,
          savePath: filePath,
        );
      }
    }
    await _processOnProgress(onProgress, 55, '附件下载完成');
  }

  /// 同步本地变更到服务端
  Future<SyncResponseDTO> _syncClientChanges<T>(
      {required List<LogSync> logs, required int syncTimeStamp, Function(int percent, String message)? onProgress}) async {
    // 同步附件
    await _uploadFiles(localChanges: logs, syncTimestamp: syncTimeStamp, onProgress: onProgress);
    await _processOnProgress(onProgress, 25, '同步本地变更: ${logs.length}');
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
        await _processOnProgress(onProgress, 30, '本地变更同步完成：${resultLogs.length}，成功：$success，失败：$failed');
        await _syncLogState(results: resultLogs, syncTimestamp: result.syncTimeStamp, onProgress: onProgress);
      }
      return result;
    }
    throw Exception(response.message);
  }

  Future<void> _syncLogState(
      {required List<SyncResultDTO> results, required int syncTimestamp, Function(int percent, String message)? onProgress}) async {
    await _processOnProgress(onProgress, 35, '同步本地变更状态: ${results.length}');
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
    await _processOnProgress(onProgress, 40, '本地变更状态同步完成');
  }

  /// 同步服务端变更
  Future<void> _syncServerChanges(
      {required List<LogSync> changes, required int syncTimestamp, Function(int percent, String message)? onProgress}) async {
    await _processOnProgress(onProgress, 45, '同步服务端变更: ${changes.length}');
    for (var change in changes) {
      final log = LogBuilder.fromLog(change);
      await log.executeWithoutRecord();
    }
    await _downloadFiles(serverChanges: changes, syncTimestamp: syncTimestamp, onProgress: onProgress);
    DaoManager.logSyncDao.batchInsert(changes);
    await _processOnProgress(onProgress, 60, '服务端变更同步完成');
  }
}
