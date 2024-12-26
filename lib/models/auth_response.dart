class AuthResponse {
  final String accessToken;
  final String userId;
  final String username;
  final String nickname;

  AuthResponse({
    required this.accessToken,
    required this.userId,
    required this.username,
    required this.nickname,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
    );
  }
}
