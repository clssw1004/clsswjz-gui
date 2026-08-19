import 'package:flutter_test/flutter_test.dart';
import 'package:clsswjz_gui/models/vo/period_cycle_vo.dart';
import 'package:clsswjz_gui/models/vo/period_statistics_vo.dart';
import 'package:clsswjz_gui/services/period_prediction_service.dart';

PeriodCycleVO _makeCycle(String startDate, {String? endDate, int? typicalPeriodDays, int? typicalCycleDays}) {
  return PeriodCycleVO(
    id: 'id-$startDate',
    startDate: startDate,
    endDate: endDate,
    typicalPeriodDays: typicalPeriodDays,
    typicalCycleDays: typicalCycleDays,
    createdAt: 0,
    updatedAt: 0,
  );
}

void main() {
  group('PeriodPredictionService.calculateFromCycles', () {
    test('returns empty for no cycles', () {
      final result = PeriodPredictionService.calculateFromCycles([]);
      expect(result.canPredict, isFalse);
      expect(result.totalRecords, 0);
    });

    test('single cycle - no prediction', () {
      final cycles = [
        _makeCycle('2026-08-01', endDate: '2026-08-05'),
      ];
      final result = PeriodPredictionService.calculateFromCycles(cycles);
      expect(result.canPredict, isFalse);
      expect(result.averagePeriodLength, 5);
      expect(result.lastPeriodStart, '2026-08-01');
    });

    test('two cycles - can predict', () {
      final cycles = [
        _makeCycle('2026-08-01', endDate: '2026-08-05'),
        _makeCycle('2026-08-29', endDate: '2026-09-02'),
      ];
      final result = PeriodPredictionService.calculateFromCycles(cycles);
      expect(result.canPredict, isTrue);
      expect(result.recentCycleLengths, [28]);
      expect(result.averageCycleLength, 28);
    });

    test('three cycles - predicts correctly', () {
      // 28-day cycles: Jul 4, Aug 1, Aug 29
      final cycles = [
        _makeCycle('2026-07-04', endDate: '2026-07-08'),
        _makeCycle('2026-08-01', endDate: '2026-08-05'),
        _makeCycle('2026-08-29', endDate: '2026-09-02'),
      ];
      final result = PeriodPredictionService.calculateFromCycles(cycles);
      expect(result.canPredict, isTrue);
      expect(result.recentCycleLengths, [28, 28]);
      expect(result.averageCycleLength, 28);
      expect(result.averagePeriodLength, 5);
      // lastPeriodStart = Aug 29, next = Aug 29 + 28 = Sep 26
      expect(result.nextPeriodDate, '2026-09-26');
      // Ovulation: Sep 26 - 14 = Sep 12
      expect(result.ovulationDate, '2026-09-12');
      // Fertile: Sep 7 - Sep 13
      expect(result.fertileWindowStart, '2026-09-07');
      expect(result.fertileWindowEnd, '2026-09-13');
    });

    test('filters anomalous cycle lengths', () {
      final cycles = [
        _makeCycle('2026-06-01', endDate: '2026-06-03'),
        _makeCycle('2026-06-06', endDate: '2026-06-08'), // 3-day gap (anomalous)
        _makeCycle('2026-07-04', endDate: '2026-07-06'), // 28-day gap
        _makeCycle('2026-08-01', endDate: '2026-08-03'), // 28-day gap
      ];
      final result = PeriodPredictionService.calculateFromCycles(cycles);
      // Gaps: 3 (filtered), 28, 28
      expect(result.recentCycleLengths, [28, 28]);
      expect(result.canPredict, isTrue);
    });

    test('single cycle with typical params - can predict', () {
      // 仅有 1 个周期，但用户配置了典型周期参数 → 应可预测
      final cycles = [
        _makeCycle('2026-08-01', endDate: '2026-08-05',
            typicalPeriodDays: 5, typicalCycleDays: 28),
      ];
      final result = PeriodPredictionService.calculateFromCycles(cycles);
      expect(result.canPredict, isTrue);
      expect(result.averageCycleLength, 28);
      expect(result.averagePeriodLength, 5);
      // next = Aug 1 + 28 = Aug 29
      expect(result.nextPeriodDate, '2026-08-29');
      // Ovulation: Aug 29 - 14 = Aug 15
      expect(result.ovulationDate, '2026-08-15');
    });

    test('typical params ignored when history exists', () {
      final cycles = [
        _makeCycle('2026-07-04', endDate: '2026-07-08',
            typicalCycleDays: 35, typicalPeriodDays: 7),
        _makeCycle('2026-08-01', endDate: '2026-08-05',
            typicalCycleDays: 35, typicalPeriodDays: 7),
      ];
      final result = PeriodPredictionService.calculateFromCycles(cycles);
      // 历史 28 天优先于典型参数 35 天
      expect(result.recentCycleLengths, [28]);
      expect(result.averageCycleLength, 28);
      expect(result.averagePeriodLength, 5);
    });

    test('invalid typical params are ignored', () {
      final cycles = [
        _makeCycle('2026-08-01', endDate: '2026-08-05',
            typicalCycleDays: 3, typicalPeriodDays: 100), // 越界
      ];
      final result = PeriodPredictionService.calculateFromCycles(cycles);
      expect(result.canPredict, isFalse);
      expect(result.averageCycleLength, 28); // 回退默认
    });
  });

  group('PeriodPredictionService.getMonthDateTypes', () {
    test('marks period days from cycles', () {
      final cycles = [
        _makeCycle('2026-08-10', endDate: '2026-08-12'),
      ];
      final types = PeriodPredictionService.getMonthDateTypes(cycles, null);
      expect(types['2026-08-10'], DateType.period);
      expect(types['2026-08-11'], DateType.period);
      expect(types['2026-08-12'], DateType.period);
      expect(types['2026-08-13'], isNull);
    });

    test('marks active cycle period days', () {
      final cycles = [
        _makeCycle('2026-08-10'), // no endDate = active
      ];
      final types = PeriodPredictionService.getMonthDateTypes(cycles, null);
      expect(types['2026-08-10'], DateType.period);
      expect(types['2026-08-11'], DateType.period);
    });

    test('marks predicted and ovulation', () {
      final cycles = [
        _makeCycle('2026-08-01', endDate: '2026-08-05'),
        _makeCycle('2026-08-29', endDate: '2026-09-02'),
      ];
      final stats = PeriodPredictionService.calculateFromCycles(cycles);
      final types = PeriodPredictionService.getMonthDateTypes(cycles, stats);
      expect(types['2026-08-01'], DateType.period);
      expect(types['2026-08-29'], DateType.period);
    });

    test('iterates predictions across multiple future cycles', () {
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
        nextPeriodDate: '2026-09-01',
        ovulationDate: '2026-08-18',
        fertileWindowStart: '2026-08-13',
        fertileWindowEnd: '2026-08-19',
      );
      final types = PeriodPredictionService.getMonthDateTypes(
        [], stats, today: '2026-08-19');
      // 第一轮预测：09-01 ~ 09-05
      expect(types['2026-09-01'], DateType.predictedPeriod);
      expect(types['2026-09-05'], DateType.predictedPeriod);
      // 第二轮迭代：09-29 ~ 10-03
      expect(types['2026-09-29'], DateType.predictedPeriod);
      expect(types['2026-10-03'], DateType.predictedPeriod);
      // 第三轮迭代：10-27 ~ 10-31
      expect(types['2026-10-27'], DateType.predictedPeriod);
      // 排卵日 + 易孕（第二轮）
      expect(types['2026-09-15'], DateType.ovulation);
      expect(types['2026-09-10'], DateType.fertile);
    });

    test('marks safe days between today and farthest prediction', () {
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
        nextPeriodDate: '2026-09-01',
        ovulationDate: '2026-08-18',
        fertileWindowStart: '2026-08-13',
        fertileWindowEnd: '2026-08-19',
      );
      final types = PeriodPredictionService.getMonthDateTypes(
        [], stats, today: '2026-08-05');
      // 今天及未来的非特殊日期应标记为安全期
      expect(types['2026-08-05'], DateType.safe);
      expect(types['2026-08-10'], DateType.safe);
      // 易孕窗口内仍是 fertile（不被 safe 覆盖）
      expect(types['2026-08-13'], DateType.fertile);
      // 预测窗口内是 predictedPeriod（不被 safe 覆盖）
      expect(types['2026-09-01'], DateType.predictedPeriod);
    });

    test('does not mark expired prediction windows', () {
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
        nextPeriodDate: '2026-08-10', // 窗口 [08-10, 08-14] 已完全过去
        ovulationDate: '2026-07-27',
        fertileWindowStart: '2026-07-22',
        fertileWindowEnd: '2026-07-28',
      );
      final types = PeriodPredictionService.getMonthDateTypes(
        [], stats, today: '2026-08-19');
      // 已过期的预测窗口不标记
      expect(types['2026-08-10'], isNull);
      expect(types['2026-08-14'], isNull);
      // 但后续迭代的预测仍标记（08-10 + 28 = 09-07）
      expect(types['2026-09-07'], DateType.predictedPeriod);
      // 第二轮预测的易孕窗为 [08-19, 08-25]，窗内是 fertile
      expect(types['2026-08-19'], DateType.fertile);
      // 易孕窗之外、下一轮预测之前（08-26 起）是安全期
      expect(types['2026-08-26'], DateType.safe);
    });

    test('renders ovulation and fertile window for past cycles', () {
      final cycles = [
        _makeCycle('2026-08-01', endDate: '2026-08-05'),
        _makeCycle('2026-08-29', endDate: '2026-09-02'),
      ];
      final stats = PeriodPredictionService.calculateFromCycles(cycles);
      final types = PeriodPredictionService.getMonthDateTypes(
        cycles, stats, today: '2026-08-19');
      // 实际周期1 的排卵日 = 下一周期开始日 - 14
      expect(types['2026-08-15'], DateType.ovulation);
      // 易孕窗（含已过去的日期，供回顾）
      expect(types['2026-08-12'], DateType.fertile);
      // 经期日
      expect(types['2026-08-03'], DateType.period);
      // 周期之间无标记日期标为安全期（回顾）
      expect(types['2026-08-06'], DateType.safe);
      // 预测经期照常渲染
      expect(types['2026-09-26'], DateType.predictedPeriod);
    });

    test('renders prediction while currently in period', () {
      // 当前处于经期：活跃周期 08-18 未结束
      final cycles = [
        _makeCycle('2026-07-21', endDate: '2026-07-25'),
        _makeCycle('2026-08-18'), // 活跃（未结束）
      ];
      final stats = PeriodPredictionService.calculateFromCycles(cycles);
      expect(stats.canPredict, isTrue);
      final types = PeriodPredictionService.getMonthDateTypes(
        cycles, stats, today: '2026-08-19');
      // 活跃经期标记到今天
      expect(types['2026-08-19'], DateType.period);
      // 当前处于经期时，预测的下次经期照常渲染（08-18 + 28 = 09-15）
      expect(types['2026-09-15'], DateType.predictedPeriod);
      // 活跃周期预测排卵日（08-18 + 28 - 14 = 09-01）
      expect(types['2026-09-01'], DateType.ovulation);
      // 前一周期排卵回顾（08-18 - 14 = 08-04）
      expect(types['2026-08-04'], DateType.ovulation);
      // 前一周期易孕窗回顾
      expect(types['2026-08-02'], DateType.fertile);
    });

    test('active period days after today are not marked safe', () {
      // 当前处于经期：活跃周期 08-19 今天开始，未结束
      final cycles = [
        _makeCycle('2026-07-22', endDate: '2026-07-26'),
        _makeCycle('2026-08-19'), // 活跃（今天开始）
      ];
      final stats = PeriodPredictionService.calculateFromCycles(cycles);
      expect(stats.canPredict, isTrue);
      final types = PeriodPredictionService.getMonthDateTypes(
        cycles, stats, today: '2026-08-19');
      // 今天是经期
      expect(types['2026-08-19'], DateType.period);
      // 明天及预期延续日（08-20 ~ 08-23）是预测经期，而不是安全期
      expect(types['2026-08-20'], DateType.predictedPeriod);
      expect(types['2026-08-22'], DateType.predictedPeriod);
      expect(types['2026-08-23'], isNot(DateType.safe));
      // 预期结束后（08-24 起）才是安全期
      expect(types['2026-08-24'], DateType.safe);
      // 下一个预测经期照常
      expect(types['2026-09-16'], DateType.predictedPeriod);
    });
  });
}
