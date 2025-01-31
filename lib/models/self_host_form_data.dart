/// 表单数据
class SelfHostFormData {
  final String serverUrl;
  final String username;
  final String password;
  final String? nickname;
  final String? phone;
  final String? email;
  final String? bookName;

  const SelfHostFormData({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.nickname,
    this.phone,
    this.email,
    this.bookName,
  });
} 