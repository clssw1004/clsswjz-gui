/// 当前所处周期阶段
enum PeriodPhase {
  /// 经期进行中
  period,

  /// 预测经期窗口内（预计经期将至/已至但未记录）
  predicted,

  /// 排卵期（排卵日 ± 易孕窗口内）
  ovulation,

  /// 安全期
  safe,

  /// 无数据
  noData,
}
