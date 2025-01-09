import '../../database/database.dart';

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
