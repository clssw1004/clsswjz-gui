import '../../database/database.dart';

/// 活动定义视图对象
class ActivityDefinitionVO {
  final String id;
  final String accountBookId;
  final String name;
  final String emoji;
  final int color;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;

  const ActivityDefinitionVO({
    required this.id,
    required this.accountBookId,
    required this.name,
    required this.emoji,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  static ActivityDefinitionVO fromEntity(ActivityDefinition entity) {
    return ActivityDefinitionVO(
      id: entity.id,
      accountBookId: entity.accountBookId,
      name: entity.name,
      emoji: entity.emoji,
      color: entity.color,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
