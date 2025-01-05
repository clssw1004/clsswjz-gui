import 'package:clsswjz/database/database.dart';
import 'package:drift/drift.dart';

import 'account_book_permission_vo.dart';

/// 账本成员视图对象
class BookMemberVO {
  /// 成员ID
  final String id;

  /// 用户ID
  final String userId;

  /// 用户昵称
  final String? nickname;

  /// 权限
  final AccountBookPermissionVO permission;

  const BookMemberVO({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.permission,
  });

  /// 转换为账本成员对象
  RelAccountbookUserTableCompanion toRelAccountbookUserCompanion() {
    return RelAccountbookUserTableCompanion(
      userId: Value(userId),
      canViewBook: Value(permission.canViewBook),
      canEditBook: Value(permission.canEditBook),
      canDeleteBook: Value(permission.canDeleteBook),
      canViewItem: Value(permission.canViewItem),
      canEditItem: Value(permission.canEditItem),
    );
  }
}
