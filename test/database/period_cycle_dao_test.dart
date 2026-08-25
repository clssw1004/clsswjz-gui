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

  test('findAllActiveCycles returns all open cycles sorted desc', () async {
    await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
      'user-1',
      startDate: '2026-07-01', // 未结束
    ));
    await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
      'user-1',
      startDate: '2026-08-01', // 未结束
    ));
    // 已结束的周期不应出现在活跃列表中
    await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
      'user-1',
      startDate: '2026-06-01',
      endDate: '2026-06-05',
    ));
    // 其他用户的数据不应干扰
    await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
      'user-2',
      startDate: '2026-08-10', // 未结束
    ));

    final actives = await cycleDao.findAllActiveCycles('user-1');
    expect(actives.length, 2);
    // 按开始日期降序：最新的在前
    expect(actives.first.startDate, '2026-08-01');
    expect(actives.last.startDate, '2026-07-01');
    expect(actives.every((c) => c.endDate == null), isTrue);
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

  // ── findByCreatorOrShared 系列测试 ──

  group('findByCreatorOrShared', () {
    test('返回自己的周期 + 共享用户的周期', () async {
      // user-1 的周期
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-1',
        startDate: '2026-08-01',
        endDate: '2026-08-05',
      ));
      // user-2（共享者）的周期
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-2',
        startDate: '2026-08-03',
        endDate: '2026-08-07',
      ));
      // user-3（未共享）的周期 — 不应出现
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-3',
        startDate: '2026-08-10',
        endDate: '2026-08-12',
      ));

      final cycles = await cycleDao.findByCreatorOrShared(
          'user-1', ['user-2'], 2026, 8);
      expect(cycles.length, 2);
      expect(cycles.every((c) => c.createdBy == 'user-1' || c.createdBy == 'user-2'),
          isTrue);
    });

    test('sharedByUserIds 为空时只返回自己的数据', () async {
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-1',
        startDate: '2026-08-01',
        endDate: '2026-08-05',
      ));
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-2',
        startDate: '2026-08-03',
        endDate: '2026-08-07',
      ));

      final cycles =
          await cycleDao.findByCreatorOrShared('user-1', [], 2026, 8);
      expect(cycles.length, 1);
      expect(cycles.first.createdBy, 'user-1');
    });
  });

  group('findRecentCyclesByCreatorOrShared', () {
    test('返回自己 + 共享用户近期有交集的周期', () async {
      final now = DateTime.now();
      final recent =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-1',
        startDate: recent,
      ));
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-2',
        startDate: recent,
      ));
      // 很久以前的周期不应出现
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-1',
        startDate: '2020-01-01',
        endDate: '2020-01-05',
      ));

      final cycles = await cycleDao.findRecentCyclesByCreatorOrShared(
          'user-1', ['user-2'], 30);
      expect(cycles.length, 2);
    });
  });

  group('findAllCyclesByCreatorOrShared', () {
    test('返回自己 + 共享用户的所有周期', () async {
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-1',
        startDate: '2026-05-01',
        endDate: '2026-05-05',
      ));
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-2',
        startDate: '2026-06-01',
        endDate: '2026-06-05',
      ));
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-3',
        startDate: '2026-07-01',
        endDate: '2026-07-05',
      ));

      final cycles = await cycleDao.findAllCyclesByCreatorOrShared(
          'user-1', ['user-2']);
      expect(cycles.length, 2);
    });
  });

  group('findActiveCycleByCreatorOrShared', () {
    test('返回自己或共享用户的活跃周期', () async {
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-1',
        startDate: '2026-08-10',
        // 未结束
      ));
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-2',
        startDate: '2026-08-12',
        // 未结束
      ));

      final active = await cycleDao.findActiveCycleByCreatorOrShared(
          'user-1', ['user-2']);
      expect(active, isNotNull);
      // 应返回其中一个活跃周期
      expect(
          active!.createdBy == 'user-1' || active.createdBy == 'user-2', isTrue);
    });

    test('无活跃周期时返回 null', () async {
      await cycleDao.insert(PeriodCycleTable.toCreateCompanion(
        'user-1',
        startDate: '2026-08-01',
        endDate: '2026-08-05',
      ));
      final active = await cycleDao.findActiveCycleByCreatorOrShared(
          'user-1', ['user-2']);
      expect(active, isNull);
    });
  });
}