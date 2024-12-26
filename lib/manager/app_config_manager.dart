import 'package:flutter/material.dart';
import '../utils/cache_util.dart';

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

  /// 默认账本ID
  String? _defaultBookId;
  String? get defaultBookId => _defaultBookId;

  /// 当前用户ID
  String? _userId;
  String? get userId => _userId;

  /// 服务器地址
  String? _serverUrl;
  String? get serverUrl => _serverUrl;

  /// 访问令牌
  String? _accessToken;
  String? get accessToken => _accessToken;

  AppConfigManager._() {
    // 初始化语言
    final languageCode = CacheUtil.instance.getString(_localeKey) ?? 'zh';
    final countryCode = CacheUtil.instance.getString('${_localeKey}_country');
    _locale = countryCode != null
        ? Locale(languageCode, countryCode)
        : Locale(languageCode);

    // 初始化主题色
    _themeColor =
        Color(CacheUtil.instance.getInt(_themeColorKey) ?? Colors.blue.value);

    // 初始化主题模式
    final themeModeString = CacheUtil.instance.getString(_themeModeKey);
    _themeMode = themeModeString != null
        ? ThemeMode.values.firstWhere(
            (mode) => mode.toString() == themeModeString,
            orElse: () => ThemeMode.system,
          )
        : ThemeMode.system;

    // 初始化字体大小
    _fontSize = CacheUtil.instance.getDouble(_fontSizeKey) ?? 1.0;

    // 初始化圆角大小
    _radius = CacheUtil.instance.getDouble(_radiusKey) ?? 8.0;

    // 初始化 Material 3 设置
    _useMaterial3 = CacheUtil.instance.getBool(_useMaterial3Key) ?? true;

    // 初始化默认账本ID
    _defaultBookId = CacheUtil.instance.getString(_defaultBookIdKey);

    // 初始化服务器地址
    _serverUrl = CacheUtil.instance.getString(_serverUrlKey);

    // 初始化访问令牌
    _accessToken = CacheUtil.instance.getString(_accessTokenKey);

    // 初始化用户ID
    _userId = CacheUtil.instance.getString(_userIdKey);
  }

  /// 初始化
  static Future<void> init() async {
    _instance = AppConfigManager._();
  }

  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await CacheUtil.instance.setString(_localeKey, locale.languageCode);
    if (locale.countryCode != null) {
      await CacheUtil.instance
          .setString('${_localeKey}_country', locale.countryCode!);
    } else {
      await CacheUtil.instance.remove('${_localeKey}_country');
    }
  }

  /// 设置主题色
  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    await CacheUtil.instance.setInt(_themeColorKey, color.value);
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await CacheUtil.instance.setString(_themeModeKey, mode.toString());
  }

  /// 设置字体大小
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await CacheUtil.instance.setDouble(_fontSizeKey, size);
  }

  /// 设置圆角大小
  Future<void> setRadius(double radius) async {
    _radius = radius;
    await CacheUtil.instance.setDouble(_radiusKey, radius);
  }

  /// 设置是否使用 Material 3
  Future<void> setUseMaterial3(bool use) async {
    _useMaterial3 = use;
    await CacheUtil.instance.setBool(_useMaterial3Key, use);
  }

  /// 设置默认账本ID
  Future<void> setDefaultBookId(String? bookId) async {
    _defaultBookId = bookId;
    if (bookId != null) {
      await CacheUtil.instance.setString(_defaultBookIdKey, bookId);
    } else {
      await CacheUtil.instance.remove(_defaultBookIdKey);
    }
  }

  /// 设置服务器地址
  Future<void> setServerUrl(String url) async {
    _serverUrl = url;
    await CacheUtil.instance.setString(_serverUrlKey, url);
  }

  /// 设置访问令牌
  Future<void> setAccessToken(String token) async {
    _accessToken = token;
    await CacheUtil.instance.setString(_accessTokenKey, token);
  }

  /// 设置用户ID
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await CacheUtil.instance.setString(_userIdKey, userId);
  }

  /// 是否已经配置过后台服务
  static bool isConfigServer() {
    return _instance.serverUrl != null || _instance.accessToken != null;
  }

  /// 设置服务器信息
  static Future<void> setServerInfo(
      String serverUrl, String userId, String accessToken) async {
    await _instance.setServerUrl(serverUrl);
    await _instance.setAccessToken(accessToken);
    await _instance.setUserId(userId);
  }
}
