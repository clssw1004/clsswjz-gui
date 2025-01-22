import 'package:drift/drift.dart';

import '../../database/database.dart';
import '../../enums/currency_symbol.dart';

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

/// 账本权限VO
class AccountBookPermissionVO {
  /// 是否可以查看账本
  final bool canViewBook;

  /// 是否可以编辑账本
  final bool canEditBook;

  /// 是否可以删除账本
  final bool canDeleteBook;

  /// 是否可以查看账目
  final bool canViewItem;

  /// 是否可以编辑账目
  final bool canEditItem;

  /// 是否可以删除账目
  final bool canDeleteItem;

  AccountBookPermissionVO({
    required this.canViewBook,
    required this.canEditBook,
    required this.canDeleteBook,
    required this.canViewItem,
    required this.canEditItem,
    required this.canDeleteItem,
  });

  /// 从账本用户关系表记录创建
  factory AccountBookPermissionVO.fromRelAccountbookUser(RelAccountbookUser relAccountbookUser) {
    return AccountBookPermissionVO(
      canViewBook: relAccountbookUser.canViewBook,
      canEditBook: relAccountbookUser.canEditBook,
      canDeleteBook: relAccountbookUser.canDeleteBook,
      canViewItem: relAccountbookUser.canViewItem,
      canEditItem: relAccountbookUser.canEditItem,
      canDeleteItem: relAccountbookUser.canDeleteItem,
    );
  }
}

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
