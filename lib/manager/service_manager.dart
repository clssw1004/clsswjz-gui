import '../services/health_service.dart';
import '../services/statistic_service.dart';
import '../services/account_book_service.dart';
import '../services/sync_service.dart';
import '../services/attachment_service.dart';
import '../services/base_service.dart';
import 'app_config_manager.dart';

/// 服务管理类，用于集中管理和初始化所有服务
class ServiceManager extends BaseService {
  static bool _isInit = false;
  static ServiceManager? _instance;
  static late AccountBookService _accountBookService;
  static late SyncService _syncService;
  static late AttachmentService _attachmentService;
  static late StatisticService _statisticService;

  static late HealthService _currentHealthService;

  ServiceManager._();

  static Future<void> init({bool syncInit = false, bool force = false}) async {
    if (_isInit && !force) return;
    // 初始化所有服务
    _accountBookService = AccountBookService();
    if (syncInit) {
      _syncService = SyncService();
      _currentHealthService =
          HealthService(AppConfigManager.instance.serverUrl);
    }
    _attachmentService = AttachmentService();
    _statisticService = StatisticService();
    _instance = ServiceManager._();
    _isInit = true;
  }

  static Future<void> refreshServer() async {
    _currentHealthService =
        HealthService(AppConfigManager.instance.serverUrl);
  }

  static Future<ServiceManager> get instance async {
    return _instance!;
  }

  /// 获取账本服务
  static AccountBookService get accountBookService => _accountBookService;

  /// 获取同步服务
  static SyncService get syncService => _syncService;

  /// 获取附件服务
  static AttachmentService get attachmentService => _attachmentService;

  /// 获取统计服务
  static StatisticService get statisticService => _statisticService;

  /// 获取健康检查服务
  static HealthService get currentServer => _currentHealthService;
}
