/// 货币符号枚举
enum CurrencySymbol {
  /// 人民币
  cny('¥', 'CNY', '人民币'),

  /// 美元
  usd('\$', 'USD', '美元'),

  /// 欧元
  eur('€', 'EUR', '欧元'),

  /// 英镑
  gbp('£', 'GBP', '英镑'),

  /// 日元
  jpy('¥', 'JPY', '日元'),

  /// 港币
  hkd('HK\$', 'HKD', '港币'),

  /// 澳大利亚元
  aud('A\$', 'AUD', '澳大利亚元'),

  /// 加拿大元
  cad('C\$', 'CAD', '加拿大元');

  /// 货币符号
  final String symbol;

  /// 货币代码
  final String code;

  /// 货币名称
  final String name;

  const CurrencySymbol(this.symbol, this.code, this.name);

  /// 根据货币代码获取货币符号
  static CurrencySymbol? fromCode(String code) {
    try {
      return CurrencySymbol.values.firstWhere(
        (currency) => currency.code == code.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// 根据货币符号获取货币枚举
  static CurrencySymbol fromSymbol(String symbol) {
    try {
      return CurrencySymbol.values.firstWhere(
        (currency) => currency.symbol == symbol,
      );
    } catch (e) {
      return CurrencySymbol.cny;
    }
  }
}
