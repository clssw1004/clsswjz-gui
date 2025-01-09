import 'package:drift/drift.dart';

class MapUtil {
  static void setIfPresent(Map<String, dynamic> map, String key, Value<dynamic> value) {
    if (value.present && value.value != null) {
      map[key] = value.value;
    }
  }
}
