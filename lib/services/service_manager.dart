import 'package:clsswjz/database/database_service.dart';
import 'package:clsswjz/services/account_book_service.dart';
import 'package:clsswjz/services/account_item_service.dart';
import 'package:clsswjz/services/user_service.dart';
import 'package:clsswjz/services/sync_service.dart';
import 'package:clsswjz/utils/http_client.dart';
import 'package:clsswjz/services/account_category_service.dart';
import 'package:clsswjz/services/account_fund_service.dart';
import 'package:clsswjz/services/account_shop_service.dart';
import 'package:clsswjz/services/account_symbol_service.dart';
import 'package:clsswjz/services/attachment_service.dart';
import 'package:clsswjz/services/base_service.dart';

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

  ServiceManager._();

  static Future<ServiceManager> get instance async {
    if (_instance == null) {
      // 确保数据库已初始化
      await DatabaseService.instance;

      // 初始化所有服务
      _userService = UserService();
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

      _instance = ServiceManager._();

      // 初始化同步数据
      await _instance!._initializeSyncData();
    }
    print("all books---------------");
    final books =
        await _accountBookService.getAll().then((value) => value.data);
    print("all items---------------");
    final items =
        await _accountItemService.getAll().then((value) => value.data);
    print(items);
    print(books);
    for (var book in books ?? []) {
      print(book.id);
      print(await _accountItemService
          .getByAccountBookId(book.id!)
          .then((value) => value.data));
    }

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

  /// 关闭所有服务
  Future<void> dispose() async {
    // 关闭数据库连接
    await DatabaseService.db.close();
    _instance = null;
  }
}
