import 'package:clsswjz_gui/database/database.dart';
import 'package:clsswjz_gui/database/tables/period_cycle_table.dart';
import 'package:clsswjz_gui/database/tables/period_daily_record_table.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/manager/cache_manager.dart';
import 'package:clsswjz_gui/manager/dao_manager.dart';
import 'package:clsswjz_gui/manager/database_manager.dart';
import 'package:clsswjz_gui/models/vo/period_cycle_vo.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const userId = 'test-user-1';
  late AppDatabase db;
  late PeriodRecordProvider provider;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({'user_id': userId});
    await CacheManager.init();
    await AppConfigManager.init();
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    DatabaseManager.setDbForTest(db);
    provider = PeriodRecordProvider();
    await provider.loadRecords();
  });

  tearDown(() async {
    await db.close();
  });

  String fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 直接向数据库插入周期并刷新 provider
  Future<PeriodCycleVO> insertCycle(
    String start, {
    String? end,
    int? typicalCycleDays,
    int? typicalPeriodDays,
  }) async {
    await DaoManager.periodCycleDao.insert(PeriodCycleTable.toCreateCompanion(
      userId,
      startDate: start,
      endDate: end,
      typicalCycleDays: typicalCycleDays,
      typicalPeriodDays: typicalPeriodDays,
    ));
    await provider.loadRecords();
    return provider.allCycles.last;
  }

  group('PeriodRecordProvider.startPeriod', () {
    test('拒绝未来日期', () async {
      final ok = await provider.startPeriod('2999-01-01');
      expect(ok, isFalse);
      expect(provider.activeCycle, isNull);
    });

    test('开始日落在已结束周期区间内时拒绝', () async {
      await insertCycle('2026-05-10', end: '2026-05-14');
      final ok = await provider.startPeriod('2026-05-12');
      expect(ok, isFalse);
    });

    test('正常开始新周期', () async {
      final ok = await provider.startPeriod('2026-08-10');
      expect(ok, isTrue);
      expect(provider.activeCycle?.startDate, '2026-08-10');
    });

    test('自动结束所有未结束周期（多活跃兜底）', () async {
      await insertCycle('2026-07-01'); // 异常活跃周期 A
      await insertCycle('2026-08-01'); // 异常活跃周期 B
      final ok = await provider.startPeriod('2026-08-10');
      expect(ok, isTrue);

      final active = provider.allCycles
          .where((c) => c.startDate == '2026-07-01' || c.startDate == '2026-08-01')
          .toList();
      // 旧活跃周期全部以新开始日前一天结束
      expect(active.every((c) => c.endDate == '2026-08-09'), isTrue);
      expect(provider.activeCycle?.startDate, '2026-08-10');
    });
  });

  group('PeriodRecordProvider.endPeriod', () {
    test('结束日早于开始日时拒绝', () async {
      await insertCycle('2026-08-01');
      final ok = await provider.endPeriod('2026-07-25');
      expect(ok, isFalse);
    });

    test('未来结束日拒绝', () async {
      await insertCycle('2026-08-01');
      final ok = await provider.endPeriod('2999-01-01');
      expect(ok, isFalse);
    });

    test('正常结束周期', () async {
      await insertCycle('2026-08-01');
      final ok = await provider.endPeriod('2026-08-05');
      expect(ok, isTrue);
      await provider.loadRecords();
      expect(provider.activeCycle, isNull);
      expect(provider.allCycles.first.endDate, '2026-08-05');
    });
  });

  group('PeriodRecordProvider.backfillPeriod', () {
    test('endDate 为 null 时创建活跃周期', () async {
      await provider.backfillPeriod('2026-06-01', null);
      expect(provider.activeCycle?.startDate, '2026-06-01');
      expect(provider.activeCycle?.endDate, isNull);
    });

    test('与已有周期重叠时拒绝', () async {
      await insertCycle('2026-05-10', end: '2026-05-14');
      await provider.backfillPeriod('2026-05-12', '2026-05-20');
      expect(provider.allCycles.length, 1);
    });

    test('未来开始日期拒绝', () async {
      await provider.backfillPeriod('2999-01-01', '2999-01-05');
      expect(provider.allCycles, isEmpty);
    });
  });

  group('PeriodRecordProvider 周期查找（基于全量周期）', () {
    test('findCycleForDate 可命中超出 44 天窗口的历史周期', () async {
      await insertCycle('2024-03-10', end: '2024-03-14');
      final cycle = provider.findCycleForDate('2024-03-12');
      expect(cycle, isNotNull);
      expect(cycle!.startDate, '2024-03-10');
    });

    test('findPreviousCycle / findNextCycle 基于全量历史', () async {
      await insertCycle('2024-03-10', end: '2024-03-14');
      await insertCycle('2024-04-07', end: '2024-04-11');
      final prev = provider.findPreviousCycle('2024-04-07');
      expect(prev?.startDate, '2024-03-10');
      final next = provider.findNextCycle('2024-03-14');
      expect(next?.startDate, '2024-04-07');
    });
  });

  group('PeriodRecordProvider 每日明细', () {
    test('loadDailyRecordsForCycle 可加载历史周期明细', () async {
      final cycle = await insertCycle('2024-03-10', end: '2024-03-14');
      await DaoManager.periodDailyRecordDao.insert(
        PeriodDailyRecordTable.toCreateCompanion(
          userId,
          cycleId: cycle.id,
          recordDate: '2024-03-11',
          flowLevel: 'medium',
          symptoms: ['cramps'],
          mood: 'bad',
        ),
      );
      await provider.loadDailyRecordsForCycle(cycle.id);
      final rec = provider.getDailyRecordByDate('2024-03-11');
      expect(rec, isNotNull);
      expect(rec!.flowLevel.code, 'medium');
    });

    test('upsertDailyRecord 拒绝超出目标周期范围的日期', () async {
      final cycle = await insertCycle('2026-08-01', end: '2026-08-05');
      await provider.upsertDailyRecord('2026-08-10', cycleId: cycle.id);
      expect(provider.dailyRecords, isEmpty);
    });

    test('upsertDailyRecord 写入目标周期', () async {
      final cycle = await insertCycle('2026-08-01', end: '2026-08-05');
      await provider.upsertDailyRecord(
        '2026-08-03',
        flowLevel: 'light',
        symptoms: ['headache'],
        cycleId: cycle.id,
      );
      final rec = provider.getDailyRecordByDate('2026-08-03');
      expect(rec, isNotNull);
      expect(rec!.flowLevel.code, 'light');
    });

    test('deleteDailyRecord 按周期+日期删除', () async {
      final cycle = await insertCycle('2026-08-01', end: '2026-08-05');
      await provider.upsertDailyRecord('2026-08-03', cycleId: cycle.id);
      expect(provider.getDailyRecordByDate('2026-08-03'), isNotNull);

      await provider.deleteDailyRecord(cycle.id, '2026-08-03');
      expect(provider.getDailyRecordByDate('2026-08-03'), isNull);
    });
  });

  group('PeriodRecordProvider 统计与状态', () {
    test('单周期 + 典型参数即可预测', () async {
      await insertCycle('2026-08-01', end: '2026-08-05',
          typicalCycleDays: 28, typicalPeriodDays: 5);
      expect(provider.statistics.canPredict, isTrue);
      expect(provider.statistics.averageCycleLength, 28);
      expect(provider.statistics.averagePeriodLength, 5);
    });

    test('预测窗口内 isPredictedPeriodDue 为 true', () async {
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);
      // 周期 28 天：s1 = 今天-28 → next = s1+28 = 今天（处于预测窗口内）
      final s2 = todayOnly.subtract(const Duration(days: 56));
      final s1 = todayOnly.subtract(const Duration(days: 28));
      await insertCycle(fmt(s2), end: fmt(s2.add(const Duration(days: 4))));
      await insertCycle(fmt(s1), end: fmt(s1.add(const Duration(days: 4))));
      expect(provider.statistics.canPredict, isTrue);
      expect(provider.statistics.nextPeriodDate, fmt(todayOnly));
      expect(provider.isPredictedPeriodDue, isTrue);
    });

    test('预测已过很久时 periodOverdueDays 为正数', () async {
      await insertCycle('2025-01-01', end: '2025-01-05');
      await insertCycle('2025-01-29', end: '2025-02-02');
      // next = 2025-02-26，远早于今天 → overdue
      expect(provider.statistics.canPredict, isTrue);
      expect(provider.periodOverdueDays, isNotNull);
      expect(provider.periodOverdueDays!, greaterThan(0));
      expect(provider.isPredictedPeriodDue, isFalse);
    });

    test('currentPeriodDay 从开始日计数', () async {
      await insertCycle('2026-08-01');
      final day = provider.currentPeriodDay;
      expect(day, isNotNull);
      expect(day!, greaterThanOrEqualTo(1));
    });
  });

  group('PeriodRecordProvider 查看模式', () {
    test('初始状态非查看模式', () {
      expect(provider.isViewingShared, isFalse);
      expect(provider.viewUserId, isNull);
      expect(provider.viewUserName, isNull);
    });

    test('switchViewUser 设置查看目标', () async {
      await provider.switchViewUser('user-2', '张三');
      expect(provider.isViewingShared, isTrue);
      expect(provider.viewUserId, 'user-2');
      expect(provider.viewUserName, '张三');
    });

    test('switchViewUser(null) 恢复查看自己', () async {
      await provider.switchViewUser('user-2', '张三');
      expect(provider.isViewingShared, isTrue);
      await provider.switchViewUser(null, null);
      expect(provider.isViewingShared, isFalse);
      expect(provider.viewUserId, isNull);
    });

    test('查看模式下 startPeriod 被拒绝', () async {
      await provider.switchViewUser('user-2', '张三');
      final ok = await provider.startPeriod('2026-08-10');
      expect(ok, isFalse);
    });

    test('查看模式下 endPeriod 被拒绝', () async {
      // 先插入一个活跃周期（以当前用户身份）
      await insertCycle('2026-08-01');
      expect(provider.activeCycle, isNotNull);
      await provider.switchViewUser('user-2', '张三');
      final ok = await provider.endPeriod('2026-08-05');
      expect(ok, isFalse);
    });

    test('查看模式下 backfillPeriod 被拒绝', () async {
      await provider.switchViewUser('user-2', '张三');
      await provider.backfillPeriod('2026-06-01', '2026-06-05');
      // 不应创建任何周期
      expect(provider.allCycles, isEmpty);
    });

    test('查看模式下 deleteCycle 被拒绝', () async {
      final cycle = await insertCycle('2026-08-01', end: '2026-08-05');
      final beforeCount = provider.allCycles.length;
      await provider.switchViewUser('user-2', '张三');
      await provider.deleteCycle(cycle.id);
      // 切回自己查看，周期应仍然存在
      await provider.switchViewUser(null, null);
      expect(provider.allCycles.length, beforeCount);
    });

    test('查看模式下 upsertDailyRecord 被拒绝', () async {
      final cycle = await insertCycle('2026-08-01', end: '2026-08-05');
      await provider.switchViewUser('user-2', '张三');
      await provider.upsertDailyRecord('2026-08-03',
          flowLevel: 'light', cycleId: cycle.id);
      expect(provider.dailyRecords, isEmpty);
    });
  });
}
