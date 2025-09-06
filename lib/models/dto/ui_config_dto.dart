import 'dart:convert';

class UiConfigDTO {
  UiConfigDTO({
    this.itemTabShowDebt = true,
    this.itemTabShowDailyBar = true,
    this.itemTabShowDailyCalendar = true,
    this.calendarShowIncome = true,
    this.calendarShowExpense = true,
  });

  final bool itemTabShowDebt;
  final bool itemTabShowDailyBar;
  final bool itemTabShowDailyCalendar;
  final bool calendarShowIncome;
  final bool calendarShowExpense;

  static UiConfigDTO _fromJson(Map<String, dynamic> json) {
    return UiConfigDTO(
      itemTabShowDebt: json['itemTabShowDebt'] ?? true,
      itemTabShowDailyBar: json['itemTabShowDailyBar'] ?? true,
      itemTabShowDailyCalendar: json['itemTabShowDailyCalendar'] ?? true,
      calendarShowIncome: json['calendarShowIncome'] ?? true,
      calendarShowExpense: json['calendarShowExpense'] ?? true,
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
    };
  }

  static String toJsonString(UiConfigDTO uiConfig) {
    return jsonEncode(_toJson(uiConfig));
  }
}
