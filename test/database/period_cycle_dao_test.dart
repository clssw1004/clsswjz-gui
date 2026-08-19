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

  test('create historical period cycle persists', () async {
    // 创建历史周期：2026-05-15 ~ 2026-05-19
    final companion = PeriodCycleTable.toCreateCompanion(
      'user-1',
      startDate: '2026-05-15',
      endDate: '2026-05-19',
    );
    await cycleDao.insert(companion);

    // 验证能查询到
    final cycles = await cycleDao.findAllCycles('user-1');
    expect(cycles.length, 1);
    expect(cycles.first.startDate, '2026-05-15');
    expect(cycles.first.endDate, '2026-05-19');
  });

  test('find active cycle returns null when none open', () async {
    // 历史周期 endDate 不为 null，不应返回为当前周期
    await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
      'user-1',
      startDate: '2026-05-15',
      endDate: '2026-05-19',
    ));
    final active = await cycleDao.findActiveCycle('user-1');
    expect(active, isNull);
  });

  test('find active cycle returns open cycle', () async {
    await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
      'user-1',
      startDate: '2026-08-01', // 未结束
    ));
    final active = await cycleDao.findActiveCycle('user-1');
    expect(active, isNotNull);
    expect(active!.startDate, '2026-08-01');
    expect(active.endDate, isNull);
  });

  test('findByMonth returns cycles overlapping the month', () async {
    await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
      'user-1',
      startDate: '2026-04-28',
      endDate: '2026-05-02', // 跨月
    ));
    final may = await cycleDao.findByMonth('user-1', 2026, 5);
    expect(may.length, 1);
  });

  test('daily record persists and queries by cycle', () async {
    final companion = PeriodCycleTable.toCreateCompanion(
      'user-1',
      startDate: '2026-08-01',
      endDate: '2026-08-05',
    );
    await cycleDao.insert(companion);
    final cycles = await cycleDao.findAllCycles('user-1');

    final dailyCompanion = PeriodDailyRecordTable.toCreateCompanion(
      'user-1',
      cycleId: cycles.first.id,
      recordDate: '2026-08-03',
      flowLevel: 'medium',
      symptoms: ['cramps'],
      mood: 'bad',
    );
    await dailyDao.insert(dailyCompanion);

    final records = await dailyDao.findByCycleId(cycles.first.id);
    expect(records.length, 1);
    expect(records.first.flowLevel, 'medium');
  });
}