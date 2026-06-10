import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/activity_definition_table.dart';
import 'base_dao.dart';

class ActivityDefinitionDao extends BaseBookDao<ActivityDefinitionTable, ActivityDefinition> {
  ActivityDefinitionDao(super.db);

  @override
  TableInfo<ActivityDefinitionTable, ActivityDefinition> get table => db.activityDefinitionTable;

  @override
  List<OrderClauseGenerator<ActivityDefinitionTable>> defaultOrderBy() {
    return [
      (t) => OrderingTerm.asc(t.sortOrder),
      (t) => OrderingTerm.asc(t.createdAt),
    ];
  }

  /// 查询用户有权限的活动定义（自己创建的 + 共享者创建的）
  Future<List<ActivityDefinition>> findByCreatorOrShared(
      String userId, List<String> sharedByUserIds) {
    final query = (db.select(table)
      ..where((t) {
        var predicate = t.createdBy.equals(userId);
        if (sharedByUserIds.isNotEmpty) {
          predicate = predicate | t.createdBy.isIn(sharedByUserIds);
        }
        return predicate;
      })
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.createdAt)]));
    return query.get();
  }
}
