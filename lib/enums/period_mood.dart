/// 经期情绪
enum PeriodMood {
  good('good'),
  normal('normal'),
  bad('bad'),
  terrible('terrible');

  final String code;
  const PeriodMood(this.code);

  static PeriodMood fromCode(String code) =>
    values.firstWhere((e) => e.code == code, orElse: () => normal);

  String get text => switch(this) {
    good => '好',
    normal => '一般',
    bad => '差',
    terrible => '很差',
  };
}
