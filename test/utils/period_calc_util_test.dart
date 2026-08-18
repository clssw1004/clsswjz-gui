import 'package:flutter_test/flutter_test.dart';
import 'package:clsswjz_gui/enums/period_status.dart';
import 'package:clsswjz_gui/enums/flow_level.dart';
import 'package:clsswjz_gui/models/vo/period_record_vo.dart';
import 'package:clsswjz_gui/models/vo/period_statistics_vo.dart';
import 'package:clsswjz_gui/utils/period_calc_util.dart';

PeriodRecordVO _makeRecord(String date, {PeriodStatus status = PeriodStatus.period}) {
  return PeriodRecordVO(
    id: 'id-$date',
    recordDate: date,
    periodStatus: status,
    flowLevel: FlowLevel.medium,
    symptoms: [],
    createdAt: 0,
    updatedAt: 0,
  );
}

void main() {
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

    test('returns ovulation when today is in fertile window', () {
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
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
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
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

  group('PeriodCalcUtil.calcCurrentPeriodDay', () {
    test('returns null when not in period', () {
      final result = PeriodCalcUtil.calcCurrentPeriodDay(
        isInPeriod: false,
        records: [],
      );
      expect(result, isNull);
    });

    test('returns 1 for first day', () {
      final records = [_makeRecord('2026-08-18')];
      final result = PeriodCalcUtil.calcCurrentPeriodDay(
        isInPeriod: true,
        records: records,
        today: '2026-08-18',
      );
      expect(result, 1);
    });

    test('returns 3 for third consecutive day', () {
      final records = [
        _makeRecord('2026-08-16'),
        _makeRecord('2026-08-17'),
        _makeRecord('2026-08-18'),
      ];
      final result = PeriodCalcUtil.calcCurrentPeriodDay(
        isInPeriod: true,
        records: records,
        today: '2026-08-18',
      );
      expect(result, 3);
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
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
        nextPeriodDate: '2026-08-25',
      );
      final result = PeriodCalcUtil.calcDaysUntilNextPeriod(
        statistics: stats,
        today: '2026-08-18',
      );
      expect(result, 7);
    });

    test('returns null when past date', () {
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
        nextPeriodDate: '2026-08-10',
      );
      final result = PeriodCalcUtil.calcDaysUntilNextPeriod(
        statistics: stats,
        today: '2026-08-18',
      );
      expect(result, isNull);
    });
  });

  group('PeriodCalcUtil.calcPeriodStartDate', () {
    test('returns null when not in period', () {
      final result = PeriodCalcUtil.calcPeriodStartDate(
        isInPeriod: false,
        records: [],
      );
      expect(result, isNull);
    });

    test('returns correct start date', () {
      final records = [
        _makeRecord('2026-08-16'),
        _makeRecord('2026-08-17'),
        _makeRecord('2026-08-18'),
      ];
      final result = PeriodCalcUtil.calcPeriodStartDate(
        isInPeriod: true,
        records: records,
        today: '2026-08-18',
      );
      expect(result, '2026-08-16');
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
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
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
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
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
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
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
      final stats = PeriodStatisticsVO(
        averageCycleLength: 28,
        averagePeriodLength: 5,
        totalRecords: 30,
        recentCycleLengths: [28, 28],
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
