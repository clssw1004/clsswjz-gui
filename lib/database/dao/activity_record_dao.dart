import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/activity_record_table.dart';
import 'base_dao.dart';

class ActivityRecordDao extends BaseBookDao<ActivityRecordTable, ActivityRecord> {
  ActivityRecordDao(super.db);

  @override
  TableInfo<ActivityRecordTable, ActivityRecord> get table => db.activityRecordTable;

  @override
  List<OrderClauseGenerator<ActivityRecordTable>> defaultOrderBy() {
    return [
      (t) => OrderingTerm.desc(t.recordDate),
      (t) => OrderingTerm.desc(t.createdAt),
    ];
  }

  /// 查询用户有权限的活动记录（自己创建的 + 共享者创建的）
  Future<List<ActivityRecord>> findByCreatorOrShared(
    String userId, List<String> sharedByUserIds, {
    int? limit,
    int? offset,
    String? activityDefId,
    String? startDate,
    String? endDate,
  }) {
    final query = (db.select(table)
      ..where((t) {
        var predicate = t.createdBy.equals(userId);
        if (sharedByUserIds.isNotEmpty) {
          predicate = predicate | t.createdBy.isIn(sharedByUserIds);
        }
        if (activityDefId != null) {
          predicate = predicate & t.activityDefId.equals(activityDefId);
        }
        if (startDate != null && endDate != null) {
          predicate = predicate & t.recordDate.isBetweenValues(startDate, endDate);
        }
        return predicate;
      })
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate), (t) => OrderingTerm.desc(t.createdAt)]));
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }

  /// 按日期范围查询（可选按活动定义筛选）
  Future<List<ActivityRecord>> listByDateRange(
    String bookId,
    String startDate,
    String endDate, {
    int? limit,
    int? offset,
    String? activityDefId,
  }) {
    final a = db.activityRecordTable;
    var where = a.accountBookId.equals(bookId) &
        a.recordDate.isBetweenValues(startDate, endDate);
    if (activityDefId != null) {
      where = where & a.activityDefId.equals(activityDefId);
    }
    final query = (db.select(table)
      ..where((_) => where)
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate), (t) => OrderingTerm.desc(t.createdAt)]));
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }

  /// 获取去重的活动名称列表（用于自动补全）
  Future<List<String>> listDistinctActivityNames(String bookId) {
    final activityTable = db.activityRecordTable;
    final query = db.selectOnly(activityTable)
      ..addColumns([activityTable.activityName])
      ..where(activityTable.accountBookId.equals(bookId))
      ..groupBy([activityTable.activityName])
      ..orderBy([OrderingTerm.asc(activityTable.activityName)]);
    return query.get().then((rows) => rows.map((r) => r.read(activityTable.activityName)!).toList());
  }
}
