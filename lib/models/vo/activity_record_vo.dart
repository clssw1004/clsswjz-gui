import '../../database/database.dart';

/// 活动记录视图对象
class ActivityRecordVO {
  /// ID
  final String id;

  /// 所属账本ID
  final String accountBookId;

  /// 活动名称
  final String activityName;

  /// 地点
  final String? location;

  /// 关联的活动定义ID
  final String? activityDefId;

  /// 活动日期 (yyyy-MM-dd)
  final String recordDate;

  /// 创建时间
  final int createdAt;

  /// 更新时间
  final int updatedAt;

  /// 创建人ID
  final String createdBy;

  /// 更新人ID
  final String updatedBy;

  const ActivityRecordVO({
    required this.id,
    required this.accountBookId,
    required this.activityName,
    this.location,
    this.activityDefId,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  /// 从数据库实体创建视图对象
  static ActivityRecordVO fromActivityRecord(ActivityRecord record) {
    return ActivityRecordVO(
      id: record.id,
      accountBookId: record.accountBookId,
      activityName: record.activityName,
      location: record.location,
      activityDefId: record.activityDefId,
      recordDate: record.recordDate,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      createdBy: record.createdBy,
      updatedBy: record.updatedBy,
    );
  }

  /// 复制并更新字段
  ActivityRecordVO copyWith({
    String? activityName,
    String? location,
    String? activityDefId,
    String? recordDate,
  }) {
    return ActivityRecordVO(
      id: id,
      accountBookId: accountBookId,
      activityName: activityName ?? this.activityName,
      location: location ?? this.location,
      activityDefId: activityDefId ?? this.activityDefId,
      recordDate: recordDate ?? this.recordDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

}
