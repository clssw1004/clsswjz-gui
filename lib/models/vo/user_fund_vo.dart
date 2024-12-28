import '../../database/database.dart';
import '../../enums/fund_type.dart';

/// 用户资金账户视图对象
class UserFundVO {
  /// 资金账户ID
  final String id;

  /// 资金账户名称
  final String name;

  /// 资金账户类型
  final FundType fundType;

  /// 资金账户余额
  final double fundBalance;

  /// 资金账户备注
  final String? fundRemark;

  /// 创建时间
  final int createdAt;

  /// 更新时间
  final int updatedAt;

  /// 创建人
  final String createdBy;

  /// 更新人
  final String updatedBy;

  /// 关联的账本信息
  final List<RelatedAccountBook> relatedBooks;

  const UserFundVO({
    required this.id,
    required this.name,
    required this.fundType,
    required this.fundBalance,
    this.fundRemark,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    this.relatedBooks = const [],
  });

  /// 转换为资金账户对象
  AccountFund toAccountFund() {
    return AccountFund(
      id: id,
      name: name,
      fundType: fundType.code,
      fundBalance: fundBalance,
      fundRemark: fundRemark,
      createdBy: createdBy,
      updatedBy: updatedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static UserFundVO fromFundAndBooks(
      {required AccountFund fund, required List<RelatedAccountBook>? books}) {
    return UserFundVO(
      id: fund.id,
      name: fund.name,
      fundType: FundType.fromCode(fund.fundType),
      fundBalance: fund.fundBalance,
      fundRemark: fund.fundRemark,
      createdAt: fund.createdAt,
      updatedAt: fund.updatedAt,
      createdBy: fund.createdBy,
      updatedBy: fund.updatedBy,
      relatedBooks: books ?? [],
    );
  }
}

/// 关联的账本信息
class RelatedAccountBook {
  /// 账本ID
  final String accountBookId;

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
    required this.accountBookId,
    required this.name,
    this.description,
    this.icon,
    required this.fundIn,
    required this.fundOut,
    required this.isDefault,
  });
}
