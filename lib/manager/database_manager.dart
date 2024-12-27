import 'package:drift/native.dart';
import '../constants/constant.dart';
import '../database/database.dart';
import 'app_config_manager.dart';

class DatabaseManager {
  static DatabaseManager? _instance;
  static late AppDatabase _db;

  static bool _isInit = false;

  DatabaseManager._();

  static Future<void> init() async {
    if (_isInit) return;
    final configDbName = AppConfigManager.instance.databaseName;
    final file = await getDatabaseFile(configDbName);
    _db = AppDatabase(NativeDatabase(file));
    _instance ??= DatabaseManager._();
    _isInit = true;
  }

  static Future<DatabaseManager> get instance async {
    return _instance!;
  }

  static AppDatabase get db => _db;

  Future<void> closeDatabase() async {
    await _db.close();
  }
}
