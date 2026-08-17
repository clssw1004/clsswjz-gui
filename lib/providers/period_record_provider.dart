import 'package:flutter/material.dart';
import 'package:clsswjz_gui/drivers/driver_factory.dart';
import 'package:clsswjz_gui/enums/operate_type.dart';
import 'package:clsswjz_gui/events/event_bus.dart';
import 'package:clsswjz_gui/events/special/event_period.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/models/vo/period_record_vo.dart';
import 'package:clsswjz_gui/models/vo/period_statistics_vo.dart';
import '../models/common.dart';

/// 经期记录数据提供者
class PeriodRecordProvider extends ChangeNotifier {
  List<PeriodRecordVO> _records = [];
  PeriodStatisticsVO _statistics = PeriodStatisticsVO.empty;
  bool _loading = false;
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  List<PeriodRecordVO> get records => _records;
  PeriodStatisticsVO get statistics => _statistics;
  bool get loading => _loading;
  int get currentYear => _currentYear;
  int get currentMonth => _currentMonth;

  /// 加载指定月份的记录
  Future<void> loadRecords({int? year, int? month}) async {
    _loading = true;
    notifyListeners();

    if (year != null) _currentYear = year;
    if (month != null) _currentMonth = month;

    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.listPeriodRecords(
      userId,
      year: _currentYear,
      month: _currentMonth,
    );
    if (result.ok) {
      _records = result.data ?? [];
    }

    // 加载统计数据
    final statsResult = await DriverFactory.driver.getPeriodStatistics(userId);
    if (statsResult.ok) {
      _statistics = statsResult.data ?? PeriodStatisticsVO.empty;
    }

    _loading = false;
    notifyListeners();
  }

  /// 切换月份
  Future<void> changeMonth(int year, int month) async {
    await loadRecords(year: year, month: month);
  }

  /// 记录/更新某日经期状态
  Future<OperateResult<void>> updatePeriodDay(
    String recordDate, {
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.updatePeriodDay(
      userId,
      recordDate,
      periodStatus: periodStatus,
      flowLevel: flowLevel,
      symptoms: symptoms,
      mood: mood,
      remark: remark,
    );
    if (result.ok) {
      await loadRecords();
      EventBus.instance.emit(PeriodRecordChangedEvent(
        periodStatus == null ? OperateType.update : OperateType.create,
      ));
    }
    return result;
  }

  /// 删除某日记录
  Future<OperateResult<void>> deletePeriodDay(String recordDate) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.deletePeriodDay(userId, recordDate);
    if (result.ok) {
      await loadRecords();
      EventBus.instance.emit(PeriodRecordChangedEvent(OperateType.delete));
    }
    return result;
  }

  /// 获取指定日期的记录
  PeriodRecordVO? getRecordByDate(String recordDate) {
    try {
      return _records.firstWhere((r) => r.recordDate == recordDate);
    } catch (_) {
      return null;
    }
  }
}
