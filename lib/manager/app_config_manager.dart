import 'package:clsswjz/constants/default-constant.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../enums/currency_symbol.dart';
import '../database/database.dart';
import '../enums/storage_mode.dart';
import '../utils/http_client.dart';
import '../utils/id_util.dart';
import 'cache_manager.dart';
import 'database_manager.dart';
import 'service_manager.dart';
import '../utils/date_util.dart';

/// 应用配置管理
class AppConfigManager {
  static const String _localeKey = 'locale';
  static const String _themeColorKey = 'theme_color';
  static const String _themeModeKey = 'theme_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _radiusKey = 'radius';
  static const String _useMaterial3Key = 'use_material3';
  static const String _defaultBookIdKey = 'default_book_id';
  static const String _serverUrlKey = 'server_url';
  static const String _accessTokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _storageTypeKey = 'storage_type';
  static const String _isStorageInitKey = 'is_storage_init';
  static const String _databaseNameKey = 'database_name';
  static const String _lastSyncTimeKey = 'last_sync_time';

  static bool _isInit = false;

  static late final AppConfigManager _instance;
  static AppConfigManager get instance => _instance;

  /// 当前语言
  late Locale _locale;
  Locale get locale => _locale;

  /// 当前主题色
  late Color _themeColor;
  Color get themeColor => _themeColor;

  /// 当前主题模式
  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  /// 当前字体大小
  late double _fontSize;
  double get fontSize => _fontSize;

  /// 当前圆角大小
  late double _radius;
  double get radius => _radius;

  /// 是否使用 Material 3
  late bool _useMaterial3;
  bool get useMaterial3 => _useMaterial3;

  late StorageMode? _storageType;
  StorageMode? get storageType => _storageType;

  /// 默认账本ID
  String? _defaultBookId;
  String? get defaultBookId => _defaultBookId;

  /// 是否已初始化存储
  late bool _isStorageInit;
  bool get isStorageInit => _isStorageInit;

  /// 当前用户ID
  String? _userId;
  String? get userId => _userId;

  /// 服务器地址
  String? _serverUrl;
  String? get serverUrl => _serverUrl;

  /// 访问令牌
  String? _accessToken;
  String? get accessToken => _accessToken;

  /// 数据库名称
  late String? _databaseName;
  String? get databaseName => _databaseName;

  late int? _lastSyncTime;
  int? get lastSyncTime => _lastSyncTime;

  AppConfigManager._() {
    _isStorageInit = CacheManager.instance.getBool(_isStorageInitKey) ?? false;

    // 初始化数据库相关配置
    _databaseName = CacheManager.instance.getString(_databaseNameKey);

    // 初始化存储模式
    final String? storageTypeString =
        CacheManager.instance.getString(_storageTypeKey);
    _storageType = string2StorageMode(storageTypeString);

    // 初始化语言
    final languageCode = CacheManager.instance.getString(_localeKey) ?? 'zh';
    final countryCode =
        CacheManager.instance.getString('${_localeKey}_country');
    _locale = countryCode != null
        ? Locale(languageCode, countryCode)
        : Locale(languageCode);

    // 初始化主题色
    _themeColor = Color(
        CacheManager.instance.getInt(_themeColorKey) ?? Colors.blue.value);

    // 初始化主题模式
    final themeModeString = CacheManager.instance.getString(_themeModeKey);
    _themeMode = themeModeString != null
        ? ThemeMode.values.firstWhere(
            (mode) => mode.toString() == themeModeString,
            orElse: () => ThemeMode.system,
          )
        : ThemeMode.system;

    // 初始化字体大小
    _fontSize = CacheManager.instance.getDouble(_fontSizeKey) ?? 1.0;

    // 初始化圆角大小
    _radius = CacheManager.instance.getDouble(_radiusKey) ?? 8.0;

    // 初始化 Material 3 设置
    _useMaterial3 = CacheManager.instance.getBool(_useMaterial3Key) ?? true;

    // 初始化默认账本ID
    _defaultBookId = CacheManager.instance.getString(_defaultBookIdKey);

    // 初始化服务器地址
    _serverUrl = CacheManager.instance.getString(_serverUrlKey);

    // 初始化访问令牌
    _accessToken = CacheManager.instance.getString(_accessTokenKey);

    // 初始化用户ID
    _userId = CacheManager.instance.getString(_userIdKey);

    // 初始化上次同步时间
    _lastSyncTime = CacheManager.instance.getInt(_lastSyncTimeKey);
  }

  /// 初始化
  static Future<void> init() async {
    if (_isInit) return;
    _instance = AppConfigManager._();
    _isInit = true;
  }

  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await CacheManager.instance.setString(_localeKey, locale.languageCode);
    if (locale.countryCode != null) {
      await CacheManager.instance
          .setString('${_localeKey}_country', locale.countryCode!);
    } else {
      await CacheManager.instance.remove('${_localeKey}_country');
    }
  }

  /// 设置主题色
  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    await CacheManager.instance.setInt(_themeColorKey, color.value);
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await CacheManager.instance.setString(_themeModeKey, mode.toString());
  }

  /// 设置字体大小
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await CacheManager.instance.setDouble(_fontSizeKey, size);
  }

  /// 设置圆角大小
  Future<void> setRadius(double radius) async {
    _radius = radius;
    await CacheManager.instance.setDouble(_radiusKey, radius);
  }

  /// 设置是否使用 Material 3
  Future<void> setUseMaterial3(bool use) async {
    _useMaterial3 = use;
    await CacheManager.instance.setBool(_useMaterial3Key, use);
  }

  /// 设置默认账本ID
  Future<void> setDefaultBookId(String? bookId) async {
    _defaultBookId = bookId;
    if (bookId != null) {
      await CacheManager.instance.setString(_defaultBookIdKey, bookId);
    } else {
      await CacheManager.instance.remove(_defaultBookIdKey);
    }
  }

  /// 设置服务器地址
  Future<void> setServerUrl(String url) async {
    _serverUrl = url;
    await CacheManager.instance.setString(_serverUrlKey, url);
  }

  /// 设置访问令牌
  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await CacheManager.instance.setString(_accessTokenKey, token);
  }

  /// 设置用户ID
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await CacheManager.instance.setString(_userIdKey, userId);
  }

  /// 设置存储类型
  Future<void> setStorageType(StorageMode mode) async {
    _storageType = mode;
    await CacheManager.instance.setString(_storageTypeKey, mode.toString());
  }

  Future<void> makeStorageInit() async {
    _isStorageInit = true;
    await CacheManager.instance.setBool(_isStorageInitKey, true);
  }

  Future<void> _setDatabaseName(String databaseName) async {
    _databaseName = databaseName;
    await CacheManager.instance.setString(_databaseNameKey, databaseName);
  }

  Future<void> setLastSyncTime(int time) async {
    _lastSyncTime = time;
    await CacheManager.instance.setInt(_lastSyncTimeKey, time);
  }

  /// 是否已经配置过后台服务
  static bool isAppInit() {
    return _instance.isStorageInit;
  }

  static Future<void> storageOfflineMode(BuildContext context,
      {required String username,
      required String nickname,
      String? email,
      String? phone,
      required String bookName,
      required String bookIcon}) async {
    final userId = IdUtils.genId();
    await _instance.setStorageType(StorageMode.offline);
    await _instance.setUserId(userId);
    await _instance._setDatabaseName(userId);
    await DatabaseManager.init();
    await ServiceManager.init();

    /// 注册用户
    final user = await ServiceManager.userService
        .register(
            userId: userId,
            username: username,
            password: DEFAULT_PASSWORD,
            nickname: nickname,
            email: email,
            phone: phone)
        .then((value) => value.data);

    /// 创建默认资金账户
    await ServiceManager.accountFundService
        .createDefaultFund(AppLocalizations.of(context)!.cash, userId);

    /// 创建账本
    final bookId = await DriverFactory.bookDataDriver
        .createBook(userId, name: bookName)
        .then((value) => value.data);
    await ServiceManager.accountBookService.initBookDefaultData(
        bookId: bookId!,
        userId: userId,
        defaultCategoryName: AppLocalizations.of(context)!.noCategory,
        defaultShopName: AppLocalizations.of(context)!.noShop);
    await _instance.setDefaultBookId(bookId);
    await _instance.makeStorageInit();
  }

  /// 设置服务器信息
  static Future<void> storgeSelfhostMode(
      String serverUrl, String userId, String accessToken) async {
    _instance.setStorageType(StorageMode.selfHost);
    await _instance.setServerUrl(serverUrl);
    await _instance.setAccessToken(accessToken);
    await _instance.setUserId(userId);
    await HttpClient.refresh(
      serverUrl: serverUrl,
      accessToken: accessToken,
    );
    await DatabaseManager.init();
    await ServiceManager.init(syncInit: true);

    /// 初始化导入数据
    final result = await ServiceManager.syncService.syncInit();
    if (result.ok) {
      await _instance.setLastSyncTime(result.data!);
    }
    await _instance.makeStorageInit();
  }
}
