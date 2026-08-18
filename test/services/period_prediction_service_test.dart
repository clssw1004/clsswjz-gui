import 'package:flutter_test/flutter_test.dart';
import 'package:clsswjz_gui/enums/period_status.dart';
import 'package:clsswjz_gui/enums/flow_level.dart';
import 'package:clsswjz_gui/models/vo/period_record_vo.dart';
import 'package:clsswjz_gui/services/period_prediction_service.dart';

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
  group('PeriodPredictionService.calculate', () {
    test('returns empty for no records', () {
      final result = PeriodPredictionService.calculate([]);
      expect(result.canPredict, isFalse);
      expect(result.totalRecords, 0);
    });

    test('returns empty for no period records', () {
      final records = [
        _makeRecord('2026-08-01', status: PeriodStatus.none),
      ];
      final result = PeriodPredictionService.calculate(records);
      expect(result.canPredict, isFalse);
    });

    test('single cycle - no prediction', () {
      final records = [
        _makeRecord('2026-08-01'),
        _makeRecord('2026-08-02'),
        _makeRecord('2026-08-03'),
      ];
      final result = PeriodPredictionService.calculate(records);
      expect(result.canPredict, isFalse);
      expect(result.averagePeriodLength, 3);
      expect(result.lastPeriodStart, '2026-08-01');
    });

    test('two cycles - one gap, can predict', () {
      final records = [
        _makeRecord('2026-08-01'),
        _makeRecord('2026-08-02'),
        _makeRecord('2026-08-03'),
        _makeRecord('2026-08-29'),
        _makeRecord('2026-08-30'),
        _makeRecord('2026-08-31'),
      ];
      final result = PeriodPredictionService.calculate(records);
      expect(result.canPredict, isTrue);
      expect(result.recentCycleLengths, [28]);
      expect(result.averageCycleLength, 28);
    });

    test('three cycles - predicts correctly', () {
      // 28-day cycles: Jul 4, Aug 1, Aug 29
      final records = [
        _makeRecord('2026-07-04'),
        _makeRecord('2026-07-05'),
        _makeRecord('2026-07-06'),
        _makeRecord('2026-07-07'),
        _makeRecord('2026-07-08'),
        _makeRecord('2026-08-01'),
        _makeRecord('2026-08-02'),
        _makeRecord('2026-08-03'),
        _makeRecord('2026-08-04'),
        _makeRecord('2026-08-05'),
        _makeRecord('2026-08-29'),
        _makeRecord('2026-08-30'),
        _makeRecord('2026-08-31'),
        _makeRecord('2026-09-01'),
        _makeRecord('2026-09-02'),
      ];
      final result = PeriodPredictionService.calculate(records);
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
      // Cycle 1: Jun 1-3, anomalous gap (5 days), Cycle 2: Jun 6-8,
      // normal gap (28 days), Cycle 3: Jul 4-6, normal gap (28 days), Cycle 4: Aug 1-3
      final records = [
        _makeRecord('2026-06-01'),
        _makeRecord('2026-06-02'),
        _makeRecord('2026-06-03'),
        // 3-day gap (anomalous, < 15)
        _makeRecord('2026-06-06'),
        _makeRecord('2026-06-07'),
        _makeRecord('2026-06-08'),
        // 26-day gap from Jun 6 (valid: > 15)
        _makeRecord('2026-07-04'),
        _makeRecord('2026-07-05'),
        _makeRecord('2026-07-06'),
        // 26-day gap from Jul 4 (valid: > 15)
        _makeRecord('2026-08-01'),
        _makeRecord('2026-08-02'),
        _makeRecord('2026-08-03'),
      ];
      final result = PeriodPredictionService.calculate(records);
      // Gaps: 5 (filtered), 28, 28
      expect(result.recentCycleLengths, [28, 28]);
      expect(result.canPredict, isTrue);
    });

    test('handles contiguous days across months', () {
      final records = [
        // Cycle 1: Jan 30 - Feb 2
        _makeRecord('2026-01-30'),
        _makeRecord('2026-01-31'),
        _makeRecord('2026-02-01'),
        _makeRecord('2026-02-02'),
        // Cycle 2: Feb 28 - Mar 3
        _makeRecord('2026-02-28'),
        _makeRecord('2026-03-01'),
        _makeRecord('2026-03-02'),
        _makeRecord('2026-03-03'),
        // Cycle 3: Mar 29 - Apr 1
        _makeRecord('2026-03-29'),
        _makeRecord('2026-03-30'),
        _makeRecord('2026-03-31'),
        _makeRecord('2026-04-01'),
      ];
      final result = PeriodPredictionService.calculate(records);
      expect(result.canPredict, isTrue);
      // Jan 30 -> Feb 28 = 29, Feb 28 -> Mar 29 = 29
      expect(result.averageCycleLength, 29);
    });
  });

  group('PeriodPredictionService.getMonthDateTypes', () {
    test('marks period days and predicted continuation', () {
      final records = [
        _makeRecord('2026-08-10'),
        _makeRecord('2026-08-11'),
      ];
      final types = PeriodPredictionService.getMonthDateTypes(records, null);
      expect(types['2026-08-10'], DateType.period);
      expect(types['2026-08-11'], DateType.period);
      // 2 days recorded, default 5 → 3 predicted days
      expect(types['2026-08-12'], DateType.predictedPeriod);
      expect(types['2026-08-13'], DateType.predictedPeriod);
      expect(types['2026-08-14'], DateType.predictedPeriod);
      expect(types['2026-08-15'], isNull);
    });

    test('marks actual period days with stats', () {
      final records = [
        _makeRecord('2026-08-01'),
        _makeRecord('2026-08-02'),
        _makeRecord('2026-08-03'),
        _makeRecord('2026-08-29'),
        _makeRecord('2026-08-30'),
        _makeRecord('2026-08-31'),
      ];
      final stats = PeriodPredictionService.calculate(records);
      final types = PeriodPredictionService.getMonthDateTypes(records, stats);
      expect(types['2026-08-01'], DateType.period);
      expect(types['2026-08-29'], DateType.period);
    });
  });
}
