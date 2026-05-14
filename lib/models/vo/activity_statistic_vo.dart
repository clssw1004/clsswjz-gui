/// 活动统计视图对象（按活动名聚合）
class ActivityStatisticVO {
  /// 活动名称
  final String activityName;

  /// 活动次数
  final int count;

  const ActivityStatisticVO({
    required this.activityName,
    required this.count,
  });
}
