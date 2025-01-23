import 'dart:convert';
import 'package:clsswjz/drivers/special/log/builder/user.builder.dart';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/auth_response.dart';
import '../utils/device.util.dart';
import '../widgets/setting/self_host_form.dart';

class AuthService {
  final String baseUrl;

  AuthService(this.baseUrl);

  Future<ApiResponse<AuthResponse>> loginOrRegister(SelfHostFormType type, SelfHostFormData data, DeviceInfo deviceInfo) async {
    if (type == SelfHostFormType.login) {
      return _login(data, deviceInfo);
    } else {
      return _register(data, deviceInfo);
    }
  }

  Future<ApiResponse<AuthResponse>> _register(SelfHostFormData data, DeviceInfo deviceInfo) async {
    return _authPost('/api/sync/register', {
      'username': data.username,
      'password': data.password,
      'nickname': data.nickname,
      'email': data.email,
      'phone': data.phone,
      'clientType': deviceInfo.clientType,
      'clientId': deviceInfo.clientId,
      'clientName': deviceInfo.clientName,
    });
  }

  Future<ApiResponse<AuthResponse>> _login(
    SelfHostFormData data,
    DeviceInfo deviceInfo,
  ) async {
    return _authPost('/api/auth/login', {
      'username': data.username,
      'password': data.password,
      'clientType': deviceInfo.clientType,
      'clientId': deviceInfo.clientId,
      'clientName': deviceInfo.clientName,
    });
  }

  Future<ApiResponse<AuthResponse>> _authPost(String path, Map<String, dynamic> body) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl$path'), headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      final json = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
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
