import '../services/statistic_service.dart';
import '../services/account_book_service.dart';
import '../services/account_item_service.dart';
import '../services/user_service.dart';
import '../services/sync_service.dart';
import '../utils/http_client.dart';
import '../services/account_category_service.dart';
import '../services/account_fund_service.dart';
import '../services/account_shop_service.dart';
import '../services/account_symbol_service.dart';
import '../services/attachment_service.dart';
import '../services/base_service.dart';

/// 服务管理类，用于集中管理和初始化所有服务
class ServiceManager extends BaseService {
  static bool _isInit = false;
  static ServiceManager? _instance;
  static late UserService _userService;
  static late AccountBookService _accountBookService;
  static late AccountItemService _accountItemService;
  static late SyncService _syncService;
  static late AccountCategoryService _accountCategoryService;
  static late AccountFundService _accountFundService;
  static late AccountShopService _accountShopService;
  static late AccountSymbolService _accountSymbolService;
  static late AttachmentService _attachmentService;
  static late StatisticService _statisticService;

  ServiceManager._();

  static Future<void> init({bool syncInit = false}) async {
    if (_isInit) return;
    // 初始化所有服务
    _userService = UserService();
    _accountBookService = AccountBookService();
    _accountItemService = AccountItemService();
    if (syncInit) {
      _syncService = SyncService(httpClient: HttpClient.instance);
    }
    _accountCategoryService = AccountCategoryService();
    _accountFundService = AccountFundService();
    _accountShopService = AccountShopService();
    _accountSymbolService = AccountSymbolService();
    _attachmentService = AttachmentService();
    _statisticService = StatisticService();
    _instance = ServiceManager._();
    _isInit = true;
  }

  static Future<ServiceManager> get instance async {
    return _instance!;
  }

  /// 获取用户服务
  static UserService get userService => _userService;

  /// 获取账本服务
  static AccountBookService get accountBookService => _accountBookService;

  /// 获取账目服务
  static AccountItemService get accountItemService => _accountItemService;

  /// 获取同步服务
  static SyncService get syncService => _syncService;

  /// 获取分类服务
  static AccountCategoryService get accountCategoryService =>
      _accountCategoryService;

  /// 获取资金账户服务
  static AccountFundService get accountFundService => _accountFundService;

  /// 获取商家服务
  static AccountShopService get accountShopService => _accountShopService;

  /// 获取标签服务
  static AccountSymbolService get accountSymbolService => _accountSymbolService;

  /// 获取附件服务
  static AttachmentService get attachmentService => _attachmentService;

  /// 获取统计服务
  static StatisticService get statisticService => _statisticService;
}
