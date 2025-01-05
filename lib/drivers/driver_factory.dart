import 'data_driver.dart';
import 'special/log.data_driver.dart';

class DriverFactory {
  static final DriverFactory _instance = DriverFactory._();
  factory DriverFactory() => _instance;
  DriverFactory._();

  static final BookDataDriver _driver = LogDataDriver();

  static BookDataDriver get driver {
    return _driver;
  }
}
