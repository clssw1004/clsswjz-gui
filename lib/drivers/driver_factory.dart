import 'book_data_driver.dart';
import 'log.data_driver.dart';

class DriverFactory {
  static final DriverFactory _instance = DriverFactory._();
  factory DriverFactory() => _instance;
  DriverFactory._();

  static final BookDataDriver _bookDataDriver = LogDataDriver();

  static BookDataDriver get bookDataDriver {
    return _bookDataDriver;
  }
}
