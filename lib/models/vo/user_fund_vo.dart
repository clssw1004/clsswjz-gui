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

  /// 是否为默认账户
  final bool isDefault;

  /// 关联的账本信息
  final List<FundBookVO> relatedBooks;

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
    this.isDefault = false,
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
      isDefault: isDefault,
    );
  }

  static UserFundVO fromFundAndBooks(
      {required AccountFund fund, required List<FundBookVO>? books}) {
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
class FundBookVO {
  final String id;

  /// 账本ID
  final String accountBookId;

  /// 账本名称
  final String name;

  /// 账本描述
  final String? description;

  /// 账本图标
  final String? icon;

  /// 来源ID
  final String fromId;

  /// 来源名称
  final String fromName;

  /// 是否允许转入
  final bool fundIn;

  /// 是否允许转出
  final bool fundOut;

  /// 是否为默认账户
  final bool isDefault;

  const FundBookVO({
    required this.id,
    required this.accountBookId,
    required this.name,
    required this.description,
    this.icon,
    required this.fromId,
    required this.fromName,
    required this.fundIn,
    required this.fundOut,
    required this.isDefault,
  });

  /// 创建一个新的 RelatedAccountBook 实例，可选择性地更新某些字段
  FundBookVO copyWith({
    String? accountBookId,
    String? name,
    String? description,
    String? icon,
    String? fromId,
    String? fromName,
    bool? fundIn,
    bool? fundOut,
    bool? isDefault,
  }) {
    return FundBookVO(
      id: id,
      accountBookId: accountBookId ?? this.accountBookId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      fromId: fromId ?? this.fromId,
      fromName: fromName ?? this.fromName,
      fundIn: fundIn ?? this.fundIn,
      fundOut: fundOut ?? this.fundOut,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
