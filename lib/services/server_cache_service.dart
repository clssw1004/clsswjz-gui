import 'dart:convert';
import '../utils/http_client.dart';

/// 服务端缓存服务
/// 纯粹封装服务端HTTP请求方法，不包含业务逻辑
class ServerCacheService {
  static final ServerCacheService _instance = ServerCacheService._internal();
  factory ServerCacheService() => _instance;
  ServerCacheService._internal();

  /// 存储数据到服务端缓存
  /// [key] 存储键
  /// [data] 要存储的数据
  /// 返回是否存储成功
  Future<bool> setData(String key, Map<String, dynamic> data) async {
    try {
      final response = await HttpClient.instance.post(
        path: '/api/cache/set',
        data: {
          'key': key,
          'value': jsonEncode(data),
        },
      );
      
      return response.ok;
    } catch (e) {
      return false;
    }
  }

  /// 从服务端缓存获取数据
  /// [key] 存储键
  /// 返回数据，如果不存在或出错则返回null
  Future<Map<String, dynamic>?> getData(String key) async {
    try {
      final response = await HttpClient.instance.post(
        path: '/api/cache/get',
        data: {'key': key},
      );
      
      if (response.ok && response.data != null) {
        final value = response.data['data'] as String?;
        if (value != null) {
          return jsonDecode(value) as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 删除数据
  /// [key] 存储键
  /// 返回是否删除成功
  Future<bool> deleteData(String key) async {
    try {
      final response = await HttpClient.instance.post(
        path: '/api/cache/delete',
        data: {'key': key},
      );
      
      return response.ok;
    } catch (e) {
      return false;
    }
  }
}