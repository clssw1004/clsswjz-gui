import 'package:clsswjz_gui/database/dao/period_cycle_dao.dart';
import 'package:clsswjz_gui/database/dao/period_daily_record_dao.dart';
import 'package:clsswjz_gui/database/database.dart';
import 'package:clsswjz_gui/database/tables/period_cycle_table.dart';
import 'package:clsswjz_gui/database/tables/period_daily_record_table.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PeriodCycleDao cycleDao;
  late PeriodDailyRecordDao dailyDao;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    cycleDao = PeriodCycleDao(db);
    dailyDao = PeriodDailyRecordDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// 创建两个日期范围重叠的周期并返回它们的 id
  ///
  /// 两个周期都覆盖 08-03，用于验证明细按 (cycleId, recordDate) 唯一定位。
  Future<(String, String)> setupTwoCycles() async {
    await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
      'user-1',
      startDate: '2026-08-01',
      endDate: '2026-08-05',
    ));
    await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
      'user-1',
      startDate: '2026-08-03',
      endDate: '2026-08-04',
    ));
    final cycles = await cycleDao.findAllCycles('user-1');
    return (cycles[0].id, cycles[1].id);
  }

  test('findByCycleAndDate locates record by cycle + date', () async {
    final (id1, id2) = await setupTwoCycles();
    // 两个周期在同一天（08-03）都有明细？第二周期是 09 月，无冲突；构造跨周期同日期场景：
    // 第二周期改为 08 月内的另一周期，与第一周期日期范围重叠
    // 为测试"按 (cycleId, recordDate) 唯一定位"，先插入两条同日期不同周期的明细
    await dailyDao.insert(PeriodDailyRecordTable.toCreateCompanion(
      'user-1',
      cycleId: id1,
      recordDate: '2026-08-03',
      flowLevel: 'light',
    ));
    await dailyDao.insert(PeriodDailyRecordTable.toCreateCompanion(
      'user-1',
      cycleId: id2,
      recordDate: '2026-08-03', // 与 id1 同日期，但属于不同周期
      flowLevel: 'heavy',
    ));

    final r1 = await dailyDao.findByCycleAndDate(id1, '2026-08-03');
    expect(r1, isNotNull);
    expect(r1!.cycleId, id1);
    expect(r1.flowLevel, 'light');

    final r2 = await dailyDao.findByCycleAndDate(id2, '2026-08-03');
    expect(r2, isNotNull);
    expect(r2!.cycleId, id2);
    expect(r2.flowLevel, 'heavy');
  });

  test('deleteByCycleAndDate only removes the target cycle record', () async {
    final (id1, id2) = await setupTwoCycles();
    await dailyDao.insert(PeriodDailyRecordTable.toCreateCompanion(
      'user-1',
      cycleId: id1,
      recordDate: '2026-08-03',
      flowLevel: 'light',
    ));
    await dailyDao.insert(PeriodDailyRecordTable.toCreateCompanion(
      'user-1',
      cycleId: id2,
      recordDate: '2026-08-03',
      flowLevel: 'heavy',
    ));

    final deleted = await dailyDao.deleteByCycleAndDate(id1, '2026-08-03');
    expect(deleted, 1);

    // 另一周期的同日期记录保留
    final remaining = await dailyDao.findByCycleAndDate(id2, '2026-08-03');
    expect(remaining, isNotNull);
  });

  test('findByDate without cycleId can collide across cycles', () async {
    final (id1, id2) = await setupTwoCycles();
    await dailyDao.insert(PeriodDailyRecordTable.toCreateCompanion(
      'user-1',
      cycleId: id1,
      recordDate: '2026-08-03',
      flowLevel: 'light',
    ));
    await dailyDao.insert(PeriodDailyRecordTable.toCreateCompanion(
      'user-1',
      cycleId: id2,
      recordDate: '2026-08-03',
      flowLevel: 'heavy',
    ));

    // 旧 API 按 (userId, recordDate) 查询时 getSingleOrNull 会因多行而抛错
    // —— 这正是 P0-1 修复点，此测试记录该行为已被 findByCycleAndDate 取代
    expect(
      () => dailyDao.findByDate('user-1', '2026-08-03'),
      throwsA(anything),
    );
  });
}
