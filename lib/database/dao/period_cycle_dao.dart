import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/period_cycle_table.dart';
import 'base_dao.dart';

class PeriodCycleDao extends BaseDao<PeriodCycleTable, PeriodCycle> {
  PeriodCycleDao(super.db);

  @override
  TableInfo<PeriodCycleTable, PeriodCycle> get table => db.periodCycleTable;

  /// 查找用户当前未结束的周期（endDate IS NULL）
  Future<PeriodCycle?> findActiveCycle(String userId) {
    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) & t.endDate.isNull())
          ..limit(1))
        .getSingleOrNull();
  }

  /// 查询指定月份的周期（与月份有交集即可）
  Future<List<PeriodCycle>> findByMonth(String userId, int year, int month) {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final endDate = '$nextYear-${nextMonth.toString().padLeft(2, '0')}-01';

    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) &
              // 周期开始日在当月范围内，或周期跨越当月
              (t.startDate.isBiggerOrEqualValue(startDate) |
                  t.startDate.isSmallerThanValue(endDate)))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
        .get();
  }

  /// 查询最近 N 天内有交集的周期
  Future<List<PeriodCycle>> findRecentCycles(String userId, int days) {
    final since = DateTime.now().subtract(Duration(days: days));
    final sinceStr =
        '${since.year}-${since.month.toString().padLeft(2, '0')}-${since.day.toString().padLeft(2, '0')}';

    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) &
              (t.startDate.isBiggerOrEqualValue(sinceStr) |
                  t.endDate.isBiggerOrEqualValue(sinceStr) |
                  t.endDate.isNull()))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
        .get();
  }

  /// 查询指定日期前后的相邻周期（用于补记范围约束）
  Future<List<PeriodCycle>> findAdjacentCycles(String userId, String date) {
    return (db.select(table)
          ..where((t) => t.createdBy.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
        .get();
  }

  /// 查询所有周期（用于统计计算）
  Future<List<PeriodCycle>> findAllCycles(String userId) {
    return (db.select(table)
          ..where((t) => t.createdBy.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
        .get();
  }

  /// 更新周期结束日期
  Future<bool> updateEndDate(String cycleId, String endDate, String userId) {
    final query = db.update(table)..where((t) => t.id.equals(cycleId));
    return query
        .write(PeriodCycleTableCompanion(
          endDate: Value(endDate),
          updatedBy: Value(userId),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ))
        .then((rows) => rows > 0);
  }
}
