import 'package:clsswjz/manager/user_config_manager.dart';

import '../services/statistic_service.dart';
import 'database_manager.dart';
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

  static init() async {
    // 初始化所有服务
    _userService = UserConfigManager.userService;
    _accountBookService = AccountBookService();
    _accountItemService = AccountItemService();
    _syncService = SyncService(
      httpClient: HttpClient(
        config: HttpConfig(
          baseUrl: 'http://192.168.2.147:3000',
          timeout: const Duration(seconds: 30),
          defaultHeaders: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          interceptors: [
            AuthInterceptor(
              getToken: () {
                return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJpeTZkbmlyMWszNTlqNDd5bmExNmQ1MzhxODh6cXBwbiIsInVzZXJuYW1lIjoiY3Vpd2VpIiwibmlja25hbWUiOiJjbHNzdyIsImlhdCI6MTczNTAyODkyOCwiZXhwIjoxNzM3NjIwOTI4fQ.CXK6f6I6wv8JdxHh_f_b0vaYweFHQwI70_CuyrCTsRs';
              },
            ),
          ],
        ),
      ),
    );
    _accountCategoryService = AccountCategoryService();
    _accountFundService = AccountFundService();
    _accountShopService = AccountShopService();
    _accountSymbolService = AccountSymbolService();
    _attachmentService = AttachmentService();
    _statisticService = StatisticService();
    _instance = ServiceManager._();

    // 初始化同步数据
    await _instance!._initializeSyncData();
  }

  static Future<ServiceManager> get instance async {
    print("all books---------------");
    final books = await _accountBookService
        .getBooksByUserId('iy6dnir1k359j47yna16d538q88zqppn')
        .then((value) => value.data);
    books?.forEach((book) {
      print(book.permission);
    });
    return _instance!;
  }

  /// 初始化同步数据
  Future<void> _initializeSyncData() async {
    try {
      final result = await _syncService.getInitialData();
      if (result.ok && result.data != null) {
        await _syncService.applyServerChanges(result.data!.data);
      }
    } catch (e) {
      print('初始化同步数据失败: ${e.toString()}');
    }
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