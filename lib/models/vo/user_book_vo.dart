import '../../database/database.dart';
import '../../enums/currency_symbol.dart';
import 'account_book_permission_vo.dart';
import 'book_member_vo.dart';

/// 用户账本视图对象
class UserBookVO {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String? description;

  /// 图标
  final String? icon;

  /// 货币符号
  final CurrencySymbol currencySymbol;

  /// 创建人ID
  final String createdBy;

  /// 创建人名称
  final String? createdByName;

  /// 更新人ID
  final String updatedBy;

  /// 更新人名称
  final String? updatedByName;

  /// 创建时间
  final int createdAt;

  /// 更新时间
  final int updatedAt;

  /// 账本权限
  final AccountBookPermissionVO permission;

  /// 账本成员（不包含创建者）
  final List<BookMemberVO> members;

  const UserBookVO({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.currencySymbol,
    required this.createdBy,
    required this.createdByName,
    required this.updatedBy,
    required this.updatedByName,
    required this.createdAt,
    required this.updatedAt,
    required this.permission,
    this.members = const [],
  });

  /// 从账本对象创建视图对象
  static UserBookVO fromAccountBook({
    required AccountBook accountBook,
    required AccountBookPermissionVO permission,
    String? createdByName,
    String? updatedByName,
    List<BookMemberVO> members = const [],
  }) {
    return UserBookVO(
      id: accountBook.id,
      name: accountBook.name,
      description: accountBook.description,
      icon: accountBook.icon,
      currencySymbol: CurrencySymbol.fromSymbol(accountBook.currencySymbol),
      createdBy: accountBook.createdBy,
      createdByName: createdByName,
      updatedBy: accountBook.updatedBy,
      updatedByName: updatedByName,
      createdAt: accountBook.createdAt,
      updatedAt: accountBook.updatedAt,
      permission: permission,
      members: members,
    );
  }

  /// 转换为账本对象
  AccountBook toAccountBook() {
    return AccountBook(
      id: id,
      name: name,
      description: description,
      icon: icon,
      currencySymbol: currencySymbol.symbol,
      createdBy: createdBy,
      updatedBy: updatedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
