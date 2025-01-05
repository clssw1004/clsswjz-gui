import 'package:flutter/material.dart';

/// 资金类型枚举
enum FundType {
  /// 现金
  cash('CASH', Icons.payments_outlined),

  /// 借记卡
  debitCard('DEBIT_CARD', Icons.credit_card_outlined),

  /// 信用卡
  creditCard('CREDIT_CARD', Icons.credit_score_outlined),

  /// 储值卡
  prepaidCard('PREPAID_CARD', Icons.card_giftcard_outlined),

  /// 支付宝
  alipay('ALIPAY', Icons.account_balance_wallet_outlined),

  /// 微信
  wechat('WECHAT', Icons.chat_outlined),

  /// 债务
  debt('DEBT', Icons.money_off_outlined),

  /// 投资
  investment('INVESTMENT', Icons.trending_up_outlined),

  /// 电子钱包
  eWallet('E_WALLET', Icons.account_balance_wallet_outlined),

  /// 其他
  other('OTHER', Icons.account_balance_outlined);

  /// 枚举代码
  final String code;

  /// 图标
  final IconData icon;

  /// 构造函数
  const FundType(this.code, this.icon);

  /// 根据代码获取枚举值
  static FundType fromCode(String code) {
    return FundType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => FundType.other,
    );
  }

  /// 转换为字符串
  String toJson() => code;
}
