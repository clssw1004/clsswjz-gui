import 'dart:convert';

class UiConfigDTO {
  UiConfigDTO({
    this.itemTabShowDebt = true,
    this.itemTabShowDailyBar = true,
    this.itemTabShowDailyCalendar = true,
    this.itemTabShowPeriodStatus = true,
    this.calendarShowIncome = true,
    this.calendarShowExpense = true,
    this.itemTabShowUserMonthly = true,
    this.itemTabShowProjectMonthly = true,
    this.statisticsShowBookStatistic = true,
    this.statisticsShowProjectStatistic = true,
    this.statisticsShowCategoryStatistic = true,
    this.statisticsShowActivityStatistic = true,
    this.statisticsSelectedRange = 'month',
    this.statisticsCustomRangeStart,
    this.statisticsCustomRangeEnd,
    this.statisticsSelectedProjects = const [],
    this.mineTabShowActivityCheckin = true,
    this.useNewItemForm = true,
    this.itemTabComponentOrder = const [
      'daily_bar',
      'period_status',
      'daily_calendar',
      'user_monthly',
      'activity_recent',
      'debt',
    ],
  });

  final bool itemTabShowDebt;
  final bool itemTabShowDailyBar;
  final bool itemTabShowDailyCalendar;
  final bool itemTabShowPeriodStatus;
  final bool calendarShowIncome;
  final bool calendarShowExpense;

  /// 是否使用新版账目表单
  final bool useNewItemForm;

  /// 记账页组件显示顺序
  final List<String> itemTabComponentOrder;

  /// 是否在「我的」页面显示活动打卡入口
  final bool mineTabShowActivityCheckin;

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

  /// 是否在统计页显示活动统计
  final bool statisticsShowActivityStatistic;

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
      itemTabShowPeriodStatus: json['itemTabShowPeriodStatus'] ?? true,
      calendarShowIncome: json['calendarShowIncome'] ?? true,
      calendarShowExpense: json['calendarShowExpense'] ?? true,
      itemTabShowUserMonthly: json['itemTabShowUserMonthly'] ?? true,
      itemTabShowProjectMonthly: json['itemTabShowProjectMonthly'] ?? true,
      statisticsShowBookStatistic: json['statisticsShowBookStatistic'] ?? true,
      statisticsShowProjectStatistic: json['statisticsShowProjectStatistic'] ?? true,
      statisticsShowCategoryStatistic: json['statisticsShowCategoryStatistic'] ?? true,
      statisticsShowActivityStatistic: json['statisticsShowActivityStatistic'] ?? true,
      statisticsSelectedRange: json['statisticsSelectedRange'] ?? 'month',
      statisticsCustomRangeStart: json['statisticsCustomRangeStart'],
      statisticsCustomRangeEnd: json['statisticsCustomRangeEnd'],
      statisticsSelectedProjects: (json['statisticsSelectedProjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      mineTabShowActivityCheckin: json['mineTabShowActivityCheckin'] ?? true,
      useNewItemForm: json['useNewItemForm'] ?? true,
      itemTabComponentOrder: _migrateComponentOrder(
        (json['itemTabComponentOrder'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList(),
      ),
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
      'itemTabShowPeriodStatus': uiConfig.itemTabShowPeriodStatus,
      'calendarShowIncome': uiConfig.calendarShowIncome,
      'calendarShowExpense': uiConfig.calendarShowExpense,
      'itemTabShowUserMonthly': uiConfig.itemTabShowUserMonthly,
      'itemTabShowProjectMonthly': uiConfig.itemTabShowProjectMonthly,
      'statisticsShowBookStatistic': uiConfig.statisticsShowBookStatistic,
      'statisticsShowProjectStatistic': uiConfig.statisticsShowProjectStatistic,
      'statisticsShowCategoryStatistic': uiConfig.statisticsShowCategoryStatistic,
      'statisticsShowActivityStatistic': uiConfig.statisticsShowActivityStatistic,
      'statisticsSelectedRange': uiConfig.statisticsSelectedRange,
      'statisticsCustomRangeStart': uiConfig.statisticsCustomRangeStart,
      'statisticsCustomRangeEnd': uiConfig.statisticsCustomRangeEnd,
      'statisticsSelectedProjects': uiConfig.statisticsSelectedProjects,
      'mineTabShowActivityCheckin': uiConfig.mineTabShowActivityCheckin,
      'useNewItemForm': uiConfig.useNewItemForm,
      'itemTabComponentOrder': uiConfig.itemTabComponentOrder,
    };
  }

  static String toJsonString(UiConfigDTO uiConfig) {
    return jsonEncode(_toJson(uiConfig));
  }

  /// 基于当前配置生成仅修改指定字段的新副本（其余字段原样保留）。
  ///
  /// 用于各设置页在保存时避免手写全量字段而【静默重置】未提及字段的 bug。
  UiConfigDTO copyWith({
    bool? itemTabShowDebt,
    bool? itemTabShowDailyBar,
    bool? itemTabShowDailyCalendar,
    bool? itemTabShowPeriodStatus,
    bool? calendarShowIncome,
    bool? calendarShowExpense,
    bool? itemTabShowUserMonthly,
    bool? itemTabShowProjectMonthly,
    bool? statisticsShowBookStatistic,
    bool? statisticsShowProjectStatistic,
    bool? statisticsShowCategoryStatistic,
    bool? statisticsShowActivityStatistic,
    List<String>? statisticsSelectedProjects,
    String? statisticsSelectedRange,
    int? statisticsCustomRangeStart,
    int? statisticsCustomRangeEnd,
    bool? mineTabShowActivityCheckin,
    bool? useNewItemForm,
    List<String>? itemTabComponentOrder,
  }) {
    return UiConfigDTO(
      itemTabShowDebt: itemTabShowDebt ?? this.itemTabShowDebt,
      itemTabShowDailyBar: itemTabShowDailyBar ?? this.itemTabShowDailyBar,
      itemTabShowDailyCalendar:
          itemTabShowDailyCalendar ?? this.itemTabShowDailyCalendar,
      itemTabShowPeriodStatus:
          itemTabShowPeriodStatus ?? this.itemTabShowPeriodStatus,
      calendarShowIncome: calendarShowIncome ?? this.calendarShowIncome,
      calendarShowExpense: calendarShowExpense ?? this.calendarShowExpense,
      itemTabShowUserMonthly:
          itemTabShowUserMonthly ?? this.itemTabShowUserMonthly,
      itemTabShowProjectMonthly:
          itemTabShowProjectMonthly ?? this.itemTabShowProjectMonthly,
      statisticsShowBookStatistic:
          statisticsShowBookStatistic ?? this.statisticsShowBookStatistic,
      statisticsShowProjectStatistic:
          statisticsShowProjectStatistic ?? this.statisticsShowProjectStatistic,
      statisticsShowCategoryStatistic:
          statisticsShowCategoryStatistic ?? this.statisticsShowCategoryStatistic,
      statisticsShowActivityStatistic:
          statisticsShowActivityStatistic ?? this.statisticsShowActivityStatistic,
      statisticsSelectedProjects:
          statisticsSelectedProjects ?? this.statisticsSelectedProjects,
      statisticsSelectedRange:
          statisticsSelectedRange ?? this.statisticsSelectedRange,
      statisticsCustomRangeStart:
          statisticsCustomRangeStart ?? this.statisticsCustomRangeStart,
      statisticsCustomRangeEnd:
          statisticsCustomRangeEnd ?? this.statisticsCustomRangeEnd,
      mineTabShowActivityCheckin:
          mineTabShowActivityCheckin ?? this.mineTabShowActivityCheckin,
      useNewItemForm: useNewItemForm ?? this.useNewItemForm,
      itemTabComponentOrder:
          itemTabComponentOrder ?? this.itemTabComponentOrder,
    );
  }

  /// 迁移组件顺序：确保 period_status 存在
  static List<String> _migrateComponentOrder(List<String>? saved) {
    const defaultOrder = [
      'daily_bar',
      'period_status',
      'daily_calendar',
      'user_monthly',
      'activity_recent',
      'debt',
    ];
    if (saved == null) return defaultOrder;
    if (saved.contains('period_status')) return saved;
    // 插入到 daily_bar 之后
    final result = List<String>.from(saved);
    final idx = result.indexOf('daily_bar');
    result.insert(idx >= 0 ? idx + 1 : 0, 'period_status');
    return result;
  }
}
