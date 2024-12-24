import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class HttpClient {
  final String baseUrl;
  final String? token;
  final Map<String, String> defaultHeaders;

  HttpClient({
    required this.baseUrl,
    this.token,
    Map<String, String>? defaultHeaders,
  }) : defaultHeaders = {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          ...?defaultHeaders,
        };

  /// JSON请求
  Future<T> json<T>({
    required String path,
    required String method,
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? transform,
  }) async {
    final uri = _buildUri(path, queryParams);
    final requestHeaders = {
      ...defaultHeaders,
      'Content-Type': 'application/json; charset=utf-8',
      ...?headers,
    };

    final response = await _request(
      uri: uri,
      method: method,
      headers: requestHeaders,
      body: data != null ? convert.json.encode(data) : null,
    );

    final responseData = convert.json.decode(response.body);
    return transform != null ? transform(responseData) : responseData as T;
  }

  /// Form表单请求
  Future<T> form<T>({
    required String path,
    required String method,
    required Map<String, String> data,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? transform,
  }) async {
    final uri = _buildUri(path, queryParams);
    final requestHeaders = {
      ...defaultHeaders,
      'Content-Type': 'application/x-www-form-urlencoded',
      ...?headers,
    };

    final response = await _request(
      uri: uri,
      method: method,
      headers: requestHeaders,
      body: Uri(queryParameters: data).query,
    );

    final responseData = convert.json.decode(response.body);
    return transform != null ? transform(responseData) : responseData as T;
  }

  /// Multipart表单请求（文件上传）
  Future<T> multipart<T>({
    required String path,
    required String method,
    required Map<String, dynamic> data,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? transform,
  }) async {
    final uri = _buildUri(path, queryParams);
    final request = http.MultipartRequest(method, uri);

    // 添加headers
    request.headers.addAll({
      ...defaultHeaders,
      ...?headers,
    });

    // 添加字段和文件
    data.forEach((key, value) {
      if (value is http.MultipartFile) {
        request.files.add(value);
      } else {
        request.fields[key] = value.toString();
      }
    });

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final responseData = convert.json.decode(response.body);
    return transform != null ? transform(responseData) : responseData as T;
  }

  /// 构建请求URI
  Uri _buildUri(String path, Map<String, String>? queryParams) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams == null || queryParams.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParams);
  }

  /// 发送请求并处理错误
  Future<http.Response> _request({
    required Uri uri,
    required String method,
    required Map<String, String> headers,
    dynamic body,
  }) async {
    try {
      final request = http.Request(method, uri)
        ..headers.addAll(headers)
        ..body = body ?? '';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      throw HttpException(
        '请求失败: ${response.statusCode} ${response.reasonPhrase}',
        uri: uri,
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is HttpException) {
        rethrow;
      }
      throw HttpException(
        '网络请求错误: $e',
        uri: uri,
      );
    }
  }
}

class HttpException implements Exception {
  final String message;
  final Uri? uri;
  final int? statusCode;

  HttpException(
    this.message, {
    this.uri,
    this.statusCode,
  });

  @override
  String toString() =>
      'HttpException: $message${uri != null ? ' for $uri' : ''}';
}
