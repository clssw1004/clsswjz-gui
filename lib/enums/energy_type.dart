/// 能源类型
enum EnergyType {
  gasoline('gasoline', '汽油'),
  diesel('diesel', '柴油');

  final String code;
  final String text;
  const EnergyType(this.code, this.text);

  static EnergyType fromCode(String code) {
    return EnergyType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => EnergyType.gasoline,
    );
  }
}
