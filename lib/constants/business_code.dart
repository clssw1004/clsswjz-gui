/// 业务代码枚举
/// 对应后端 BusinessCode 枚举
enum BusinessCode {
  /// 账目
  item('item', '账目'),

  /// 账本
  book('book', '账本'),

  /// 资金账户
  fund('fund', '资金账户'),

  /// 用户
  user('user', '用户');

  /// 业务代码值
  final String code;

  /// 业务名称
  final String name;

  const BusinessCode(this.code, this.name);

  /// 根据代码值获取枚举
  static BusinessCode? fromCode(String code) {
    try {
      return BusinessCode.values.firstWhere(
        (business) => business.code == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取代码值
  String toCode() => code;

  @override
  String toString() => code;
}
