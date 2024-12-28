/// 资金账户类型
enum FundType {
  /// 现金
  cash('CASH'),
  /// 储蓄卡
  debitCard('DEBIT'),
  /// 信用卡
  creditCard('CREDIT'),
  /// 充值卡
  prepaidCard('PREPAID'),
  /// 支付宝
  alipay('ALIPAY'),
  /// 微信
  wechat('WECHAT'),
  /// 欠款
  debt('DEBT'),
  /// 投资
  investment('INVESTMENT'),
  /// 网络钱包
  eWallet('E_WALLET'),
  /// 其他
  other('OTHER');

  final String code;
  const FundType(this.code);

  static FundType fromCode(String code) {
    return FundType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => FundType.other,
    );
  }
} 