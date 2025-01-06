import 'package:clsswjz/manager/dao_manager.dart';
import 'package:drift/drift.dart';
import '../models/common.dart';
import '../models/sync.dart';
import '../utils/http_client.dart';
import 'base_service.dart';

/// 数据同步服务
class SyncService extends BaseService {
  final HttpClient _httpClient;

  SyncService({required HttpClient httpClient}) : _httpClient = httpClient;

  Future<Map<String, dynamic>> syncChanges<T>() async {
    final logs = await DaoManager.logSyncDao.findAll();
    final response = await _httpClient.post<Map<String, dynamic>>(
      path: '/api/sync/changes',
      data: {
        'logs': logs.map((e) => e.toJson()).toList(),
      },
    );

    if (response.success) {
      return response.data!;
    }
    return {};
  }
}
