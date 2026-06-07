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
}
