import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import '../models/health_status.dart';

class HealthService {
  final String baseUrl;

  HealthService(this.baseUrl);

  Future<ApiResponse<HealthStatus>> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health'));
      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse(
          ok: true,
          data: HealthStatus.fromJson(json['data']),
        );
      }

      return ApiResponse(
        ok: false,
        message: json['message'] ?? '服务器连接失败',
      );
    } catch (e) {
      return ApiResponse(
        ok: false,
        message: e.toString(),
      );
    }
  }
}
