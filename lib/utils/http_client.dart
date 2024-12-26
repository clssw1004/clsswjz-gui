import 'dart:convert';
import 'package:http/http.dart' as http;

/// HTTP请求方法枚举
enum HttpMethod { get, post, put, delete, patch }

/// HTTP内容类型枚举
enum ContentType {
  json('application/json; charset=utf-8'),
  form('application/x-www-form-urlencoded'),
  multipart('multipart/form-data');

  final String value;
  const ContentType(this.value);
}

/// HTTP请求配置
class HttpConfig {
  final String baseUrl;
  final Duration timeout;
  final Map<String, String> defaultHeaders;
  final List<HttpInterceptor> interceptors;

  const HttpConfig({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 30),
    this.defaultHeaders = const {},
    this.interceptors = const [],
  });
}

/// HTTP请求选项
class RequestOptions {
  final String path;
  final HttpMethod method;
  final Map<String, dynamic>? data;
  final Map<String, String>? queryParameters;
  final Map<String, String>? headers;
  final ContentType contentType;
  final Duration? timeout;
  final bool requireAuth;

  const RequestOptions({
    required this.path,
    required this.method,
    this.data,
    this.queryParameters,
    this.headers,
    this.contentType = ContentType.json,
    this.timeout,
    this.requireAuth = true,
  });
}

/// HTTP响应包装
class HttpResponse<T> {
  final int statusCode;
  final T? data;
  final String? message;
  final Map<String, String> headers;
  final bool success;

  const HttpResponse({
    required this.statusCode,
    this.data,
    this.message,
    required this.headers,
    required this.success,
  });

  factory HttpResponse.success({
    required int statusCode,
    required T? data,
    required Map<String, String> headers,
  }) {
    return HttpResponse(
      statusCode: statusCode,
      data: data,
      headers: headers,
      success: true,
    );
  }

  factory HttpResponse.error({
    required int statusCode,
    required String message,
    required Map<String, String> headers,
  }) {
    return HttpResponse(
      statusCode: statusCode,
      message: message,
      headers: headers,
      success: false,
    );
  }
}

/// HTTP错误
class HttpError implements Exception {
  final String message;
  final int? statusCode;
  final String? body;
  final StackTrace? stackTrace;

  const HttpError({
    required this.message,
    this.statusCode,
    this.body,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'HttpError: $message${statusCode != null ? ' ($statusCode)' : ''}';
  }
}

/// HTTP拦截器接口
abstract class HttpInterceptor {
  Future<RequestOptions> onRequest(RequestOptions options);
  Future<HttpResponse<T>> onResponse<T>(HttpResponse<T> response);
  Future<HttpError> onError(HttpError error);
}

/// 认证拦截器
class AuthInterceptor implements HttpInterceptor {
  final String Function() getToken;

  const AuthInterceptor({required this.getToken});

  @override
  Future<RequestOptions> onRequest(RequestOptions options) async {
    if (options.requireAuth) {
      final token = getToken();
      if (token.isNotEmpty) {
        final headers = options.headers ?? {};
        headers['Authorization'] = 'Bearer $token';
        return RequestOptions(
          path: options.path,
          method: options.method,
          data: options.data,
          queryParameters: options.queryParameters,
          headers: headers,
          contentType: options.contentType,
          timeout: options.timeout,
          requireAuth: options.requireAuth,
        );
      }
    }
    return options;
  }

  @override
  Future<HttpResponse<T>> onResponse<T>(HttpResponse<T> response) async =>
      response;

  @override
  Future<HttpError> onError(HttpError error) async => error;
}

/// HTTP客户端
class HttpClient {
  final HttpConfig config;
  final http.Client _client;
  static late final HttpClient _instance;

  static HttpClient get instance => _instance;

  HttpClient({
    required this.config,
  }) : _client = http.Client();

  static refresh({serverUrl, accessToken}) {
    _instance = HttpClient(
      config: HttpConfig(
        baseUrl: serverUrl,
        timeout: const Duration(seconds: 30),
        defaultHeaders: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        interceptors: [
          AuthInterceptor(
            getToken: () {
              return accessToken;
            },
          ),
        ],
      ),
    );
  }

  /// 发送请求
  Future<HttpResponse<T>> request<T>({
    required RequestOptions options,
    T Function(Map<String, dynamic>)? transform,
  }) async {
    try {
      // 应用请求拦截器
      var interceptedOptions = options;
      for (var interceptor in config.interceptors) {
        interceptedOptions = await interceptor.onRequest(interceptedOptions);
      }

      // 构建请求URI
      final uri = _buildUri(
          interceptedOptions.path, interceptedOptions.queryParameters);

      // 构建请求头
      final headers = {
        ...config.defaultHeaders,
        'Content-Type': interceptedOptions.contentType.value,
        ...?interceptedOptions.headers,
      };

      // 发送请求
      final response = await _sendRequest(
        uri: uri,
        method: interceptedOptions.method,
        headers: headers,
        data: interceptedOptions.data,
        timeout: interceptedOptions.timeout ?? config.timeout,
      );

      // 构建响应
      final httpResponse = _buildResponse<T>(response, transform);

      // 应用响应拦截器
      var interceptedResponse = httpResponse;
      for (var interceptor in config.interceptors) {
        interceptedResponse =
            await interceptor.onResponse<T>(interceptedResponse);
      }

      return interceptedResponse;
    } catch (e, stackTrace) {
      final error = _handleError(e, stackTrace);

      // 应用错误拦截器
      var interceptedError = error;
      for (var interceptor in config.interceptors) {
        interceptedError = await interceptor.onError(interceptedError);
      }

      throw interceptedError;
    }
  }

  /// 发送GET请求
  Future<HttpResponse<T>> get<T>({
    required String path,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? transform,
  }) {
    return request<T>(
      options: RequestOptions(
        path: path,
        method: HttpMethod.get,
        queryParameters: queryParameters,
        headers: headers,
      ),
      transform: transform,
    );
  }

  /// 发送POST请求
  Future<HttpResponse<T>> post<T>({
    required String path,
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    ContentType contentType = ContentType.json,
    T Function(Map<String, dynamic>)? transform,
  }) {
    return request<T>(
      options: RequestOptions(
        path: path,
        method: HttpMethod.post,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        contentType: contentType,
      ),
      transform: transform,
    );
  }

  /// 发送PUT请求
  Future<HttpResponse<T>> put<T>({
    required String path,
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    ContentType contentType = ContentType.json,
    T Function(Map<String, dynamic>)? transform,
  }) {
    return request<T>(
      options: RequestOptions(
        path: path,
        method: HttpMethod.put,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        contentType: contentType,
      ),
      transform: transform,
    );
  }

  /// 发送DELETE请求
  Future<HttpResponse<T>> delete<T>({
    required String path,
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? transform,
  }) {
    return request<T>(
      options: RequestOptions(
        path: path,
        method: HttpMethod.delete,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
      ),
      transform: transform,
    );
  }

  /// 发送PATCH请求
  Future<HttpResponse<T>> patch<T>({
    required String path,
    Map<String, dynamic>? data,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    ContentType contentType = ContentType.json,
    T Function(Map<String, dynamic>)? transform,
  }) {
    return request<T>(
      options: RequestOptions(
        path: path,
        method: HttpMethod.patch,
        data: data,
        queryParameters: queryParameters,
        headers: headers,
        contentType: contentType,
      ),
      transform: transform,
    );
  }

  /// 构建请求URI
  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final uri = Uri.parse('${config.baseUrl}$path');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters);
  }

  /// 发送请求
  Future<http.Response> _sendRequest({
    required Uri uri,
    required HttpMethod method,
    required Map<String, String> headers,
    Map<String, dynamic>? data,
    required Duration timeout,
  }) async {
    final methodName = method.toString().split('.').last.toUpperCase();
    final request = http.Request(methodName, uri)..headers.addAll(headers);

    if (data != null) {
      if (headers['Content-Type']?.contains('application/json') == true) {
        request.body = jsonEncode(data);
      } else if (headers['Content-Type']?.contains('multipart/form-data') ==
          true) {
        final multipartRequest = http.MultipartRequest(methodName, uri)
          ..headers.addAll(headers);

        data.forEach((key, value) {
          if (value is http.MultipartFile) {
            multipartRequest.files.add(value);
          } else {
            multipartRequest.fields[key] = value.toString();
          }
        });

        final streamedResponse = await multipartRequest.send().timeout(timeout);
        return http.Response.fromStream(streamedResponse);
      } else {
        request.body = Uri(
            queryParameters: data
                .map((key, value) => MapEntry(key, value.toString()))).query;
      }
    }

    final streamedResponse = await _client.send(request).timeout(timeout);
    return http.Response.fromStream(streamedResponse);
  }

  /// 构建响应
  HttpResponse<T> _buildResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? transform,
  ) {
    final statusCode = response.statusCode;
    final headers = response.headers;

    if (statusCode >= 200 && statusCode < 300) {
      final body = response.body;
      if (body.isEmpty) {
        return HttpResponse<T>.success(
          statusCode: statusCode,
          data: null,
          headers: headers,
        );
      }

      final jsonData = jsonDecode(body);
      final data = transform != null ? transform(jsonData) : jsonData as T;

      return HttpResponse<T>.success(
        statusCode: statusCode,
        data: data,
        headers: headers,
      );
    }

    throw HttpError(
      message: 'Request failed with status: $statusCode',
      statusCode: statusCode,
      body: response.body,
    );
  }

  /// 处理错误
  HttpError _handleError(Object error, StackTrace stackTrace) {
    if (error is HttpError) {
      return error;
    }

    if (error is http.ClientException) {
      return HttpError(
        message: 'Network error: ${error.message}',
        stackTrace: stackTrace,
      );
    }

    return HttpError(
      message: 'Unknown error: $error',
      stackTrace: stackTrace,
    );
  }

  /// 关闭客户端
  void close() {
    _client.close();
  }
}
