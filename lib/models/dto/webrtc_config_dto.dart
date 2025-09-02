import 'dart:convert';

/// WebRTC配置DTO
/// 用于存储TURN服务器配置信息
class WebRTCConfigDTO {
  final String turnIp;
  final String turnPort;
  final String turnUser;
  final String turnPass;
  final String turnRealm;

  /// 构造函数
  const WebRTCConfigDTO({
    this.turnIp = "139.224.41.190",
    this.turnPort = "3478",
    this.turnUser = "webrtc",
    this.turnPass = "Cuiwei@123.com",
    this.turnRealm = "clssw",
  });

  /// 从JSON创建实例
  factory WebRTCConfigDTO.fromJson(Map<String, dynamic> json) {
    return WebRTCConfigDTO(
      turnIp: json['turnIp'] ,
      turnPort: json['turnPort'] ?? "3478",
      turnUser: json['turnUser'] ?? "webrtc",
      turnPass: json['turnPass'] ?? "Cuiwei@123.com",
      turnRealm: json['turnRealm'] ?? "clssw",
    );
  }

  /// 从JSON字符串创建实例
  factory WebRTCConfigDTO.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return WebRTCConfigDTO.fromJson(json);
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'turnIp': turnIp,
      'turnPort': turnPort,
      'turnUser': turnUser,
      'turnPass': turnPass,
      'turnRealm': turnRealm,
    };
  }

  /// 转换为JSON字符串
  static String toJsonString(WebRTCConfigDTO config) {
    return jsonEncode(config.toJson());
  }

  /// 创建副本并更新属性
  WebRTCConfigDTO copyWith({
    String? turnIp,
    String? turnPort,
    String? turnUser,
    String? turnPass,
    String? turnRealm,
  }) {
    return WebRTCConfigDTO(
      turnIp: turnIp ?? this.turnIp,
      turnPort: turnPort ?? this.turnPort,
      turnUser: turnUser ?? this.turnUser,
      turnPass: turnPass ?? this.turnPass,
      turnRealm: turnRealm ?? this.turnRealm,
    );
  }
}