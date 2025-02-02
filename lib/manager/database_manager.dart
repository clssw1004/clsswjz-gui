import 'package:drift/native.dart';
import '../constants/constant.dart';
import '../database/database.dart';
import 'app_config_manager.dart';
import 'dao_manager.dart';

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
    // 初始化DAO管理器
    await DaoManager.refreshDaos();
    _isInit = true;
  }

  static Future<void> clearDatabase() async {
    try {
      _isInit = false;
      await _db.close();
      _instance = null;
    } catch (e) {
      // do nothing
    }
    // 删除数据库文件
    final file = await getDatabaseFile(AppConfigManager.instance.databaseName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<DatabaseManager> get instance async {
    return _instance!;
  }

  static AppDatabase get db => _db;

  Future<void> closeDatabase() async {
    await _db.close();
  }
}
