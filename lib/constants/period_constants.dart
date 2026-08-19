/// 经期记录模块常量
class PeriodConstants {
  PeriodConstants._();

  /// isInPeriod 回溯检查天数
  static const int inPeriodLookbackDays = 7;

  /// endPeriod 向前搜索最大天数
  static const int endPeriodSearchMaxDays = 30;

  /// 周期长度过滤范围（天）- 低于此值视为异常
  static const int minCycleLength = 15;

  /// 周期长度过滤范围（天）- 高于此值视为异常
  static const int maxCycleLength = 60;

  /// 黄体期固定天数（用于排卵日计算）
  static const int lutealPhaseDays = 14;

  /// 危险期：排卵日前几天
  static const int fertileWindowBeforeOvulation = 5;

  /// 危险期：排卵日后几天
  static const int fertileWindowAfterOvulation = 1;

  /// 默认经期天数（无历史数据时）
  static const int defaultPeriodDays = 5;

  /// 预测迭代次数（每次覆盖一个周期，用于未来多个月的日历标记）
  static const int predictIterations = 6;

  /// 典型周期天数合法范围（用于校验用户配置）
  static const int typicalCycleMin = 15;
  static const int typicalCycleMax = 60;

  /// 典型经期天数合法范围
  static const int typicalPeriodMin = 2;
  static const int typicalPeriodMax = 14;
}
