import 'package:flutter_test/flutter_test.dart';
import 'package:clsswjz_gui/enums/period_status.dart';
import 'package:clsswjz_gui/models/vo/period_statistics_vo.dart';
import 'package:clsswjz_gui/utils/period_calc_util.dart';

void main() {
  PeriodStatisticsVO makeStats({
    List<int> cycleLengths = const [28, 28],
    String? nextPeriodDate,
    String? ovulationDate,
    String? fertileWindowStart,
    String? fertileWindowEnd,
    int averagePeriodLength = 5,
    int? typicalCycleDays,
  }) {
    return PeriodStatisticsVO(
      averageCycleLength: cycleLengths.isNotEmpty
          ? (cycleLengths.reduce((a, b) => a + b) ~/ cycleLengths.length)
          : (typicalCycleDays ?? 28),
      averagePeriodLength: averagePeriodLength,
      totalRecords: 30,
      recentCycleLengths: cycleLengths,
      nextPeriodDate: nextPeriodDate,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileWindowStart,
      fertileWindowEnd: fertileWindowEnd,
      typicalCycleDays: typicalCycleDays,
    );
  }

  group('PeriodCalcUtil.determinePhase', () {
    test('returns period when isInPeriod is true', () {
      final result = PeriodCalcUtil.determinePhase(
        isInPeriod: true,
        statistics: PeriodStatisticsVO.empty,
      );
      expect(result, PeriodPhase.period);
    });

    test('returns noData when cannot predict', () {
      final result = PeriodCalcUtil.determinePhase(
        isInPeriod: false,
        statistics: PeriodStatisticsVO.empty,
      );
      expect(result, PeriodPhase.noData);
    });

    test('returns predicted when today is in predicted period window', () {
      final stats = makeStats(nextPeriodDate: '2026-08-25');
      // window: 08-25 ~ 08-29
      final result = PeriodCalcUtil.determinePhase(
        isInPeriod: false,
        statistics: stats,
        today: '2026-08-27',
      );
      expect(result, PeriodPhase.predicted);
    });

    test('returns ovulation when today is in fertile window', () {
      final stats = makeStats(
        nextPeriodDate: '2026-09-26',
        ovulationDate: '2026-09-12',
        fertileWindowStart: '2026-09-07',
        fertileWindowEnd: '2026-09-13',
      );
      final result = PeriodCalcUtil.determinePhase(
        isInPeriod: false,
        statistics: stats,
        today: '2026-09-10',
      );
      expect(result, PeriodPhase.ovulation);
    });

    test('returns safe when today is outside fertile window', () {
      final stats = makeStats(
        nextPeriodDate: '2026-09-26',
        ovulationDate: '2026-09-12',
        fertileWindowStart: '2026-09-07',
        fertileWindowEnd: '2026-09-13',
      );
      final result = PeriodCalcUtil.determinePhase(
        isInPeriod: false,
        statistics: stats,
        today: '2026-08-20',
      );
      expect(result, PeriodPhase.safe);
    });
  });

  group('PeriodCalcUtil.calcDaysUntilNextPeriod', () {
    test('returns null when cannot predict', () {
      final result = PeriodCalcUtil.calcDaysUntilNextPeriod(
        statistics: PeriodStatisticsVO.empty,
      );
      expect(result, isNull);
    });

    test('returns correct days', () {
      final stats = makeStats(nextPeriodDate: '2026-08-25');
      final result = PeriodCalcUtil.calcDaysUntilNextPeriod(
        statistics: stats,
        today: '2026-08-18',
      );
      expect(result, 7);
    });

    test('returns null when past date', () {
      final stats = makeStats(nextPeriodDate: '2026-08-10');
      final result = PeriodCalcUtil.calcDaysUntilNextPeriod(
        statistics: stats,
        today: '2026-08-18',
      );
      expect(result, isNull);
    });
  });

  group('PeriodCalcUtil.isInFertileWindow', () {
    test('returns false when cannot predict', () {
      final result = PeriodCalcUtil.isInFertileWindow(
        statistics: PeriodStatisticsVO.empty,
      );
      expect(result, isFalse);
    });

    test('returns true when in window', () {
      final stats = makeStats(
        fertileWindowStart: '2026-09-07',
        fertileWindowEnd: '2026-09-13',
      );
      final result = PeriodCalcUtil.isInFertileWindow(
        statistics: stats,
        today: '2026-09-10',
      );
      expect(result, isTrue);
    });

    test('returns false when outside window', () {
      final stats = makeStats(
        fertileWindowStart: '2026-09-07',
        fertileWindowEnd: '2026-09-13',
      );
      final result = PeriodCalcUtil.isInFertileWindow(
        statistics: stats,
        today: '2026-08-20',
      );
      expect(result, isFalse);
    });
  });

  group('PeriodCalcUtil.isInSafePeriod', () {
    test('returns true when not in period and not in fertile window', () {
      final stats = makeStats(
        fertileWindowStart: '2026-09-07',
        fertileWindowEnd: '2026-09-13',
      );
      final result = PeriodCalcUtil.isInSafePeriod(
        isInPeriod: false,
        statistics: stats,
        today: '2026-08-20',
      );
      expect(result, isTrue);
    });

    test('returns false when in period', () {
      final result = PeriodCalcUtil.isInSafePeriod(
        isInPeriod: true,
        statistics: PeriodStatisticsVO.empty,
      );
      expect(result, isFalse);
    });

    test('returns false when in fertile window', () {
      final stats = makeStats(
        fertileWindowStart: '2026-09-07',
        fertileWindowEnd: '2026-09-13',
      );
      final result = PeriodCalcUtil.isInSafePeriod(
        isInPeriod: false,
        statistics: stats,
        today: '2026-09-10',
      );
      expect(result, isFalse);
    });
  });
}
