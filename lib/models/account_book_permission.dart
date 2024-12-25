/// 账本权限数据类
class AccountBookPermission {
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

  const AccountBookPermission({
    required this.canViewBook,
    required this.canEditBook,
    required this.canDeleteBook,
    required this.canViewItem,
    required this.canEditItem,
    required this.canDeleteItem,
  });

  /// 从 RelAccountbookUser 创建权限对象
  factory AccountBookPermission.fromRelAccountbookUser(dynamic user) {
    return AccountBookPermission(
      canViewBook: user.canViewBook,
      canEditBook: user.canEditBook,
      canDeleteBook: user.canDeleteBook,
      canViewItem: user.canViewItem,
      canEditItem: user.canEditItem,
      canDeleteItem: user.canDeleteItem,
    );
  }
}
