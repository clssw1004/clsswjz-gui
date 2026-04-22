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
    this.statisticsShowBookStatistic = true,
    this.statisticsShowProjectStatistic = true,
    this.statisticsShowCategoryStatistic = true,
    this.statisticsSelectedRange = 'month',
    this.statisticsCustomRangeStart,
    this.statisticsCustomRangeEnd,
    this.statisticsSelectedProjects = const [],
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

  /// 是否在统计页显示账本统计卡片
  final bool statisticsShowBookStatistic;

  /// 是否在统计页显示按项目统计图
  final bool statisticsShowProjectStatistic;

  /// 是否在统计页显示分类统计图
  final bool statisticsShowCategoryStatistic;

  /// 统计页面选择展示的项目列表（项目code）
  final List<String> statisticsSelectedProjects;

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
      statisticsShowBookStatistic: json['statisticsShowBookStatistic'] ?? true,
      statisticsShowProjectStatistic: json['statisticsShowProjectStatistic'] ?? true,
      statisticsShowCategoryStatistic: json['statisticsShowCategoryStatistic'] ?? true,
      statisticsSelectedRange: json['statisticsSelectedRange'] ?? 'month',
      statisticsCustomRangeStart: json['statisticsCustomRangeStart'],
      statisticsCustomRangeEnd: json['statisticsCustomRangeEnd'],
      statisticsSelectedProjects: (json['statisticsSelectedProjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
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
      'statisticsShowBookStatistic': uiConfig.statisticsShowBookStatistic,
      'statisticsShowProjectStatistic': uiConfig.statisticsShowProjectStatistic,
      'statisticsShowCategoryStatistic': uiConfig.statisticsShowCategoryStatistic,
      'statisticsSelectedRange': uiConfig.statisticsSelectedRange,
      'statisticsCustomRangeStart': uiConfig.statisticsCustomRangeStart,
      'statisticsCustomRangeEnd': uiConfig.statisticsCustomRangeEnd,
      'statisticsSelectedProjects': uiConfig.statisticsSelectedProjects,
    };
  }

  static String toJsonString(UiConfigDTO uiConfig) {
    return jsonEncode(_toJson(uiConfig));
  }
}
