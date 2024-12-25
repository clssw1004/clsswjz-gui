import '../../database/database.dart';
import '../account_book_permission.dart';

/// 用户账本视图对象
class UserBookVO {
  /// 账本信息
  final AccountBook accountBook;

  /// 账本权限
  final AccountBookPermission permission;

  const UserBookVO({
    required this.accountBook,
    required this.permission,
  });
}
