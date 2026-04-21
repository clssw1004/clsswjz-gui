import 'dart:convert';

class UiConfigDTO {
  UiConfigDTO({
    this.itemTabShowDebt = true,
    this.itemTabShowDailyBar = true,
    this.itemTabShowDailyCalendar = true,
    this.calendarShowIncome = true,
    this.calendarShowExpense = true,
    this.itemTabShowUserMonthly = true,
    this.itemTabShowProjectMonthly = true,
    this.statisticsSelectedRange = 'month',
    this.statisticsCustomRangeStart,
    this.statisticsCustomRangeEnd,
  });

  final bool itemTabShowDebt;
  final bool itemTabShowDailyBar;
  final bool itemTabShowDailyCalendar;
  final bool calendarShowIncome;
  final bool calendarShowExpense;

  /// 是否在账目页显示按用户当月统计图
  final bool itemTabShowUserMonthly;

  /// 是否在账目页显示按项目当月统计图
  final bool itemTabShowProjectMonthly;

  /// 统计页面选择的时间范围 (month/year/week/custom/all)
  final String statisticsSelectedRange;

  /// 自定义时间范围开始日期 (milliseconds since epoch)
  final int? statisticsCustomRangeStart;

  /// 自定义时间范围结束日期 (milliseconds since epoch)
  final int? statisticsCustomRangeEnd;

  static UiConfigDTO _fromJson(Map<String, dynamic> json) {
    return UiConfigDTO(
      itemTabShowDebt: json['itemTabShowDebt'] ?? true,
      itemTabShowDailyBar: json['itemTabShowDailyBar'] ?? true,
      itemTabShowDailyCalendar: json['itemTabShowDailyCalendar'] ?? true,
      calendarShowIncome: json['calendarShowIncome'] ?? true,
      calendarShowExpense: json['calendarShowExpense'] ?? true,
      itemTabShowUserMonthly: json['itemTabShowUserMonthly'] ?? true,
      itemTabShowProjectMonthly: json['itemTabShowProjectMonthly'] ?? true,
      statisticsSelectedRange: json['statisticsSelectedRange'] ?? 'month',
      statisticsCustomRangeStart: json['statisticsCustomRangeStart'],
      statisticsCustomRangeEnd: json['statisticsCustomRangeEnd'],
    );
  }

  static UiConfigDTO fromJsonString(String jsonString) {
    return _fromJson(jsonDecode(jsonString));
  }

  static Map<String, dynamic> _toJson(UiConfigDTO uiConfig) {
    return {
      'itemTabShowDebt': uiConfig.itemTabShowDebt,
      'itemTabShowDailyBar': uiConfig.itemTabShowDailyBar,
      'itemTabShowDailyCalendar': uiConfig.itemTabShowDailyCalendar,
      'calendarShowIncome': uiConfig.calendarShowIncome,
      'calendarShowExpense': uiConfig.calendarShowExpense,
      'itemTabShowUserMonthly': uiConfig.itemTabShowUserMonthly,
      'itemTabShowProjectMonthly': uiConfig.itemTabShowProjectMonthly,
      'statisticsSelectedRange': uiConfig.statisticsSelectedRange,
      'statisticsCustomRangeStart': uiConfig.statisticsCustomRangeStart,
      'statisticsCustomRangeEnd': uiConfig.statisticsCustomRangeEnd,
    };
  }

  static String toJsonString(UiConfigDTO uiConfig) {
    return jsonEncode(_toJson(uiConfig));
  }
}
