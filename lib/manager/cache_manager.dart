import 'package:shared_preferences/shared_preferences.dart';

/// 缓存工具类
class CacheManager {
  static late final CacheManager _instance;
  static CacheManager get instance => _instance;

  final SharedPreferences _prefs;

  CacheManager._(this._prefs);

  static bool _isInit = false;

  /// 初始化
  static Future<void> init() async {
    if (_isInit) return;
    final prefs = await SharedPreferences.getInstance();
    _instance = CacheManager._(prefs);
    _isInit = true;
  }

  /// 获取字符串
  String? getString(String key) => _prefs.getString(key);

  /// 设置字符串
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  /// 获取整数
  int? getInt(String key) => _prefs.getInt(key);

  /// 设置整数
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  /// 获取双精度浮点数
  double? getDouble(String key) => _prefs.getDouble(key);

  /// 设置双精度浮点数
  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  /// 获取布尔值
  bool? getBool(String key) => _prefs.getBool(key);

  /// 设置布尔值
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  /// 移除指定键的值
  Future<bool> remove(String key) => _prefs.remove(key);

  /// 清除所有数据
  Future<bool> clear() => _prefs.clear();
}
