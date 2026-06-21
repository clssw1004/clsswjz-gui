import 'activity_definition_vo.dart';

/// 活动统计视图对象（按活动名聚合）
class ActivityStatisticVO {
  /// 活动名称
  final String activityName;

  /// 活动次数
  final int count;

  /// 活动标识符号（emoji/图标）
  final String emoji;

  /// 关联的活动定义（用于跳转详情）
  final ActivityDefinitionVO? definition;

  const ActivityStatisticVO({
    required this.activityName,
    required this.count,
    this.emoji = '',
    this.definition,
  });
}
