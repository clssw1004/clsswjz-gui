import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 应用配置管理
class AppConfig {
  static const String _localeKey = 'locale';
  static const String _themeColorKey = 'theme_color';
  static const String _themeModeKey = 'theme_mode';
  static const String _fontSizeKey = 'font_size';
  static const String _radiusKey = 'radius';
  static const String _useMaterial3Key = 'use_material3';

  static late final AppConfig _instance;
  static AppConfig get instance => _instance;

  final SharedPreferences _prefs;

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

  AppConfig._(this._prefs) {
    // 初始化语言
    final languageCode = _prefs.getString(_localeKey) ?? 'zh';
    final countryCode = _prefs.getString('${_localeKey}_country');
    _locale = countryCode != null
        ? Locale(languageCode, countryCode)
        : Locale(languageCode);

    // 初始化主题色
    _themeColor = Color(_prefs.getInt(_themeColorKey) ?? Colors.blue.value);

    // 初始化主题模式
    final themeModeString = _prefs.getString(_themeModeKey);
    _themeMode = themeModeString != null
        ? ThemeMode.values.firstWhere(
            (mode) => mode.toString() == themeModeString,
            orElse: () => ThemeMode.system,
          )
        : ThemeMode.system;

    // 初始化字体大小
    _fontSize = _prefs.getDouble(_fontSizeKey) ?? 1.0;

    // 初始化圆角大小
    _radius = _prefs.getDouble(_radiusKey) ?? 8.0;

    // 初始化 Material 3 设置
    _useMaterial3 = _prefs.getBool(_useMaterial3Key) ?? true;
  }

  /// 初始化
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = AppConfig._(prefs);
  }

  /// 设置语言
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
    if (locale.countryCode != null) {
      await _prefs.setString('${_localeKey}_country', locale.countryCode!);
    } else {
      await _prefs.remove('${_localeKey}_country');
    }
  }

  /// 设置主题色
  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    await _prefs.setInt(_themeColorKey, color.value);
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeModeKey, mode.toString());
  }

  /// 设置字体大小
  Future<void> setFontSize(double size) async {
    _fontSize = size;
    await _prefs.setDouble(_fontSizeKey, size);
  }

  /// 设置圆角大小
  Future<void> setRadius(double radius) async {
    _radius = radius;
    await _prefs.setDouble(_radiusKey, radius);
  }

  /// 设置是否使用 Material 3
  Future<void> setUseMaterial3(bool use) async {
    _useMaterial3 = use;
    await _prefs.setBool(_useMaterial3Key, use);
  }
}
