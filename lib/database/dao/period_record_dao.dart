import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/period_record_table.dart';
import 'base_dao.dart';

class PeriodRecordDao extends BaseDao<PeriodRecordTable, PeriodRecord> {
  PeriodRecordDao(super.db);

  @override
  TableInfo<PeriodRecordTable, PeriodRecord> get table => db.periodRecordTable;

  /// 查询指定月份的记录
  Future<List<PeriodRecord>> findByMonth(String userId, int year, int month) {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final endDate = '$nextYear-${nextMonth.toString().padLeft(2, '0')}-01';

    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) &
              t.recordDate.isBiggerOrEqualValue(startDate) &
              t.recordDate.isSmallerThanValue(endDate))
          ..orderBy([(t) => OrderingTerm.asc(t.recordDate)]))
        .get();
  }

  /// 查询所有 period/spotting 状态的记录（用于周期计算）
  Future<List<PeriodRecord>> findAllPeriodDays(String userId) {
    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) &
              (t.periodStatus.equals('period') | t.periodStatus.equals('spotting')))
          ..orderBy([(t) => OrderingTerm.asc(t.recordDate)]))
        .get();
  }

  /// 查询指定日期的记录
  Future<PeriodRecord?> findByDate(String userId, String recordDate) {
    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) & t.recordDate.equals(recordDate)))
        .getSingleOrNull();
  }

  /// 按用户查询（用于共享查看）
  Future<List<PeriodRecord>> findByUser(String userId) {
    return (db.select(table)
          ..where((t) => t.createdBy.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.recordDate)]))
        .get();
  }
}
