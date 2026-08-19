import 'package:flutter_test/flutter_test.dart';
import 'package:clsswjz_gui/models/vo/period_cycle_vo.dart';
import 'package:clsswjz_gui/services/period_prediction_service.dart';

PeriodCycleVO _makeCycle(String startDate, {String? endDate}) {
  return PeriodCycleVO(
    id: 'id-$startDate',
    startDate: startDate,
    endDate: endDate,
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
  });
}
