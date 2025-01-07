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

class SyncResponseDTO {
  final List<SyncResultDTO> results;

  final List<LogSync> changes;

  final int syncTimeStamp;

  SyncResponseDTO({
    this.results = const [],
    this.changes = const [],
    required this.syncTimeStamp,
  });

  factory SyncResponseDTO.fromJson(Map<String, dynamic> json) {
    print(json);
    return SyncResponseDTO(
      results: (json['results'] as List<dynamic>)
          .map((e) => SyncResultDTO.fromJson(e))
          .toList(),
      changes: (json['changes'] as List<dynamic>)
          .map((e) => LogSync.fromJson(e))
          .toList(),
      syncTimeStamp: json['syncTimeStamp'],
    );
  }
}
