import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/period_daily_record_table.dart';
import 'base_dao.dart';

class PeriodDailyRecordDao extends BaseDao<PeriodDailyRecordTable, PeriodDailyRecord> {
  PeriodDailyRecordDao(super.db);

  @override
  TableInfo<PeriodDailyRecordTable, PeriodDailyRecord> get table => db.periodDailyRecordTable;

  /// 查询某周期的所有明细
  Future<List<PeriodDailyRecord>> findByCycleId(String cycleId) {
    return (db.select(table)
          ..where((t) => t.cycleId.equals(cycleId))
          ..orderBy([(t) => OrderingTerm.asc(t.recordDate)]))
        .get();
  }

  /// 查询指定日期的明细
  Future<PeriodDailyRecord?> findByDate(String userId, String recordDate) {
    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) & t.recordDate.equals(recordDate)))
        .getSingleOrNull();
  }

  /// 查询指定周期内指定日期的明细（按表唯一键 (cycleId, recordDate) 定位）
  Future<PeriodDailyRecord?> findByCycleAndDate(
      String cycleId, String recordDate) {
    return (db.select(table)
          ..where((t) =>
              t.cycleId.equals(cycleId) & t.recordDate.equals(recordDate)))
        .getSingleOrNull();
  }

  /// 查询周期内最后一条明细
  Future<PeriodDailyRecord?> findLastRecordInCycle(String cycleId) {
    return (db.select(table)
          ..where((t) => t.cycleId.equals(cycleId))
          ..orderBy([(t) => OrderingTerm.desc(t.recordDate)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// 按日期删除某条明细
  Future<int> deleteByDate(String userId, String recordDate) {
    final query = db.delete(table)
      ..where((t) =>
          t.createdBy.equals(userId) & t.recordDate.equals(recordDate));
    return query.go();
  }

  /// 按周期 + 日期删除某条明细（按表唯一键定位，避免误删其他周期）
  Future<int> deleteByCycleAndDate(String cycleId, String recordDate) {
    final query = db.delete(table)
      ..where((t) =>
          t.cycleId.equals(cycleId) & t.recordDate.equals(recordDate));
    return query.go();
  }
}
