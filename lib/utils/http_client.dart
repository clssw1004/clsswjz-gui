import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';

class HttpClient {
  static late HttpClient _instance;
  final String baseUrl;
  final String? accessToken;

  HttpClient({
    required this.baseUrl,
    this.accessToken,
  });

  static HttpClient get instance => _instance;

  static Future<void> refresh({
    required String serverUrl,
    String? accessToken,
  }) async {
    _instance = HttpClient(
      baseUrl: serverUrl,
      accessToken: accessToken ?? _instance.accessToken,
    );
  }

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Map<String, String> _getMultipartHeaders() {
    final headers = <String, String>{};
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<ApiResponse<T>> post<T>({
    required String path,
    required dynamic data,
    T Function(Map<String, dynamic>)? transform,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _getHeaders(),
      body: jsonEncode(data),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ApiResponse(
        ok: true,
        data: transform != null ? transform(json) : json,
      );
    }

    return ApiResponse(
      ok: false,
      message: json['message'] ?? '请求失败',
    );
  }

  Future<ApiResponse<T>> uploadFiles<T>({
    required String path,
    required List<File> files,
    T Function(Map<String, dynamic>)? transform,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = http.MultipartRequest('POST', uri)..headers.addAll(_getMultipartHeaders());

      // 添加文件
      for (var file in files) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final json = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          ok: true,
          data: transform != null ? transform(json) : json,
        );
      }

      return ApiResponse(
        ok: false,
        message: json['message'] ?? '上传失败',
      );
    } catch (e) {
      return ApiResponse(
        ok: false,
        message: e.toString(),
      );
    }
  }

  /// 下载文件
  Future<ApiResponse<String>> downloadFile({
    required String fileId,
    required String savePath,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/attachments/$fileId'),
        headers: _getHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final file = File(savePath);
        await file.writeAsBytes(response.bodyBytes);
        return ApiResponse(
          ok: true,
          data: savePath,
        );
      }

      Map<String, dynamic>? json;
      try {
        json = jsonDecode(response.body);
      } catch (e) {
        // 忽略解析错误
      }

      return ApiResponse(
        ok: false,
        message: json?['message'] ?? '下载失败',
      );
    } catch (e) {
      return ApiResponse(
        ok: false,
        message: e.toString(),
      );
    }
  }

  Future<ApiResponse<T>> get<T>({
    required String path,
    T Function(Map<String, dynamic>)? transform,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _getHeaders(),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          ok: true,
          data: transform != null ? transform(json) : json,
        );
      }

      return ApiResponse(
        ok: false,
        message: json['message'] ?? '请求失败',
      );
    } catch (e) {
      return ApiResponse(
        ok: false,
        message: e.toString(),
      );
    }
  }
}
