import '../../database/database.dart';
import 'attachment_vo.dart';

class UserVO {
  final String id;
  final int createdAt;
  final int updatedAt;
  final String username;
  final String nickname;
  final String password;
  final String? email;
  final String? phone;
  final String inviteCode;
  final String language;
  final String timezone;
  final AttachmentVO? avatar;

  UserVO({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.username,
    required this.nickname,
    required this.password,
    this.email,
    this.phone,
    required this.inviteCode,
    required this.language,
    required this.timezone,
    this.avatar,
  });

  static UserVO fromUser({
    required User user,
    AttachmentVO? avatar,
  }) {
    return UserVO(
      id: user.id,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      username: user.username,
      nickname: user.nickname,
      password: user.password,
      email: user.email,
      phone: user.phone,
      inviteCode: user.inviteCode,
      language: user.language,
      timezone: user.timezone,
      avatar: avatar,
    );
  }
}
