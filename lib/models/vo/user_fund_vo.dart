import '../../database/database.dart';
import '../../enums/fund_type.dart';

/// 用户资金账户视图对象
class UserFundVO {
  /// 资金账户ID
  final String id;

  /// 资金账户名称
  final String name;

  /// 账本ID
  final String accountBookId;

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

  /// 是否为默认账户
  final bool isDefault;

  const UserFundVO({
    required this.id,
    required this.name,
    required this.accountBookId,
    required this.fundType,
    required this.fundBalance,
    this.fundRemark,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
    this.isDefault = false,
  });

  /// 转换为资金账户对象
  AccountFund toAccountFund() {
    return AccountFund(
      id: id,
      name: name,
      accountBookId: accountBookId,
      fundType: fundType.code,
      fundBalance: fundBalance,
      fundRemark: fundRemark,
      createdBy: createdBy,
      updatedBy: updatedBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isDefault: isDefault,
    );
  }

  static UserFundVO fromFundAndBooks(AccountFund fund) {
    return UserFundVO(
      id: fund.id,
      name: fund.name,
      accountBookId: fund.accountBookId,
      fundType: FundType.fromCode(fund.fundType),
      fundBalance: fund.fundBalance,
      fundRemark: fund.fundRemark,
      createdAt: fund.createdAt,
      updatedAt: fund.updatedAt,
      createdBy: fund.createdBy,
      updatedBy: fund.updatedBy,
    );
  }
}
