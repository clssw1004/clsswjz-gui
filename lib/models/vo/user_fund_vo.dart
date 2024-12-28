import '../../database/database.dart';

/// 用户资金账户视图对象
class UserFundVO {
  /// 资金账户信息
  final AccountFund fund;

  /// 关联的账本信息
  final List<RelatedAccountBook> relatedBooks;

  const UserFundVO({
    required this.fund,
    this.relatedBooks = const [],
  });
}

/// 关联的账本信息
class RelatedAccountBook {
  /// 账本ID
  final String id;

  /// 账本名称
  final String name;

  /// 账本描述
  final String? description;

  /// 账本图标
  final String? icon;

  /// 是否允许转入
  final bool fundIn;

  /// 是否允许转出
  final bool fundOut;

  /// 是否为默认账户
  final bool isDefault;

  const RelatedAccountBook({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.fundIn,
    required this.fundOut,
    required this.isDefault,
  });
} 