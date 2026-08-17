/// 经期状态
enum PeriodStatus {
  none('none'),
  period('period'),
  spotting('spotting');

  final String code;
  const PeriodStatus(this.code);

  static PeriodStatus fromCode(String code) =>
    values.firstWhere((e) => e.code == code, orElse: () => none);

  String get text => switch(this) {
    none => '非经期',
    period => '经期',
    spotting => '少量出血',
  };
}
