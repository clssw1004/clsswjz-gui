import '../database/database.dart';
import '../enums/sync_state.dart';

class SyncResultDTO {
  final String logId;
  final SyncState syncState;
  final String? syncError;

  SyncResultDTO({
    required this.logId,
    required this.syncState,
    this.syncError = '',
  });

  factory SyncResultDTO.fromJson(Map<String, dynamic> json) {
    return SyncResultDTO(
      logId: json['logId'],
      syncState: SyncState.fromString(json['syncState']) ?? SyncState.unsynced,
      syncError: json['syncError'],
    );
  }
}

/// Push 响应 DTO
class SyncPushResponse {
  final List<SyncResultDTO> results;
  final int syncTimeStamp;
  final int totalChanges;
  final String commitId;

  SyncPushResponse({
    this.results = const [],
    required this.syncTimeStamp,
    this.totalChanges = 0,
    this.commitId = '',
  });

  factory SyncPushResponse.fromJson(Map<String, dynamic> json) {
    return SyncPushResponse(
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => SyncResultDTO.fromJson(e))
              .toList() ??
          [],
      syncTimeStamp: json['syncTimeStamp'],
      totalChanges: json['totalChanges'] ?? 0,
      commitId: json['commitId'] ?? '',
    );
  }
}

/// Pull 响应 DTO（分页）
class SyncPullResponse {
  final List<LogSync> changes;
  final int total;
  final int page;
  final int pageSize;
  final int syncTimeStamp;

  SyncPullResponse({
    this.changes = const [],
    this.total = 0,
    this.page = 0,
    this.pageSize = 0,
    required this.syncTimeStamp,
  });

  factory SyncPullResponse.fromJson(Map<String, dynamic> json) {
    return SyncPullResponse(
      changes: (json['changes'] as List<dynamic>?)
              ?.map((e) => LogSync.fromJson(e))
              .toList() ??
          [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      syncTimeStamp: json['syncTimeStamp'],
    );
  }
}
