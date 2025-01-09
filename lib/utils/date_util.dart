import 'package:intl/intl.dart';

class DateUtil {
  static int now() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// 格式化时间戳：YYYY-MM-DD HH:mm:ss
  static String format(int timestamp) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
  }
}
