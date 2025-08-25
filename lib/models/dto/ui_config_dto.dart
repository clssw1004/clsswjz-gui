import 'dart:convert';

class UiConfigDTO {
  UiConfigDTO({
    this.itemTabShowDebt = true,
  });

  final bool itemTabShowDebt;

  static UiConfigDTO _fromJson(Map<String, dynamic> json) {
    return UiConfigDTO(
      itemTabShowDebt: json['itemTabShowDebt'] ?? true,
    );
  }

  static UiConfigDTO fromJsonString(String jsonString) {
    return _fromJson(jsonDecode(jsonString));
  }

  static Map<String, dynamic> _toJson(UiConfigDTO uiConfig) {
    return {
      'itemTabShowDebt': uiConfig.itemTabShowDebt,
    };
  }

  static String toJsonString(UiConfigDTO uiConfig) {
    return jsonEncode(_toJson(uiConfig));
  }
}
