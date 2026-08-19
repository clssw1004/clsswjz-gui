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

  /// 查找用户所有未结束的周期（endDate IS NULL），按开始日期降序
  ///
  /// 用于处理日志同步/异常场景下可能存在的多个活跃周期。
  Future<List<PeriodCycle>> findAllActiveCycles(String userId) {
    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) & t.endDate.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .get();
  }

  /// 查询与指定月份有交集的周期
  ///
  /// 周期与月份重叠的条件：开始日 <= 月末 AND (结束日为空 或 结束日 >= 月初)
  Future<List<PeriodCycle>> findByMonth(String userId, int year, int month) {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    // 月末 = 下月初 - 1 天
    final lastDay = DateTime(year, month + 1, 0);
    final lastDayStr =
        '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day.toString().padLeft(2, '0')}';

    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) &
              // 开始日不晚于月末
              t.startDate.isSmallerOrEqualValue(lastDayStr) &
              // 结束日不早于月初（未结束周期视为覆盖未来）
              (t.endDate.isNull() | t.endDate.isBiggerOrEqualValue(startDate)))
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
