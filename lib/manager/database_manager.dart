import 'package:drift/native.dart';
import '../constants/constant.dart';
import '../database/database.dart';
import 'app_config_manager.dart';
import 'dao_manager.dart';
import '../utils/database_debug.dart';

class DatabaseManager {
  static DatabaseManager? _instance;
  static late AppDatabase _db;

  static bool _isInit = false;

  DatabaseManager._();

  static Future<void> init() async {
    if (_isInit) return;
    
    // 添加调试信息
    print('DatabaseManager: Starting database initialization');
    final exists = await DatabaseDebug.checkDatabaseExists();
    print('DatabaseManager: Database exists before init: $exists');
    
    final configDbName = AppConfigManager.instance.databaseName;
    final file = await getDatabaseFile(configDbName);
    _db = AppDatabase(NativeDatabase(file));
    
    // 检查数据库版本
    await DatabaseDebug.checkDatabaseVersion();
    
    _instance ??= DatabaseManager._();
    // 初始化DAO管理器
    DaoManager.refreshDaos();
    _isInit = true;
    
    print('DatabaseManager: Database initialization completed');
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
