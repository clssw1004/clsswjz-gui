import 'account_book_permission_vo.dart';

/// 账本成员视图对象
class BookMemberVO {
  /// 用户ID
  final String userId;

  /// 用户昵称
  final String? nickname;

  /// 权限
  final AccountBookPermissionVO permission;

  const BookMemberVO({
    required this.userId,
    required this.nickname,
    required this.permission,
  });
}
