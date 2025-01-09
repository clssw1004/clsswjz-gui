import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/auth_response.dart';

class AuthService {
  final String baseUrl;

  AuthService(this.baseUrl);

  Future<ApiResponse<AuthResponse>> login(
    String username,
    String password, {
    String? clientType,
    String? clientId,
    String? clientName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'clientType': clientType,
          'clientId': clientId,
          'clientName': clientName,
        }),
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse(
          ok: true,
          data: AuthResponse.fromJson(json['data']),
        );
      }

      return ApiResponse(
        ok: false,
        message: json['message'] ?? '登录失败',
      );
    } catch (e) {
      return ApiResponse(
        ok: false,
        message: e.toString(),
      );
    }
  }
}
