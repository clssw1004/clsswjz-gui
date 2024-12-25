import '../../database/database.dart';
import '../account_book_permission.dart';

/// 用户账本视图对象
class UserBookVO {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String? description;

  /// 货币符号
  final String currencySymbol;

  /// 创建人ID
  final String createdBy;

  /// 更新人ID
  final String updatedBy;

  /// 创建时间
  final int createdAt;

  /// 更新时间
  final int updatedAt;

  /// 账本权限
  final AccountBookPermission permission;

  const UserBookVO({
    required this.id,
    required this.name,
    this.description,
    required this.currencySymbol,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.permission,
  });

  /// 从账本对象创建视图对象
  static UserBookVO fromAccountBook({
    required AccountBook accountBook,
    required AccountBookPermission permission,
  }) {
    return UserBookVO(
      id: accountBook.id,
      name: accountBook.name,
      description: accountBook.description,
      currencySymbol: accountBook.currencySymbol,
      createdBy: accountBook.createdBy,
      updatedBy: accountBook.updatedBy,
      createdAt: accountBook.createdAt,
      updatedAt: accountBook.updatedAt,
      permission: permission,
    );
  }

  /// 转换为账本对象
  AccountBook toAccountBook() {
    return AccountBook(
      id: id,
      name: name,
      description: description,
      currencySymbol: currencySymbol,
      createdBy: createdBy,
      updatedBy: updatedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
