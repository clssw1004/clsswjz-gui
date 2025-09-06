import 'package:drift/native.dart';
import '../database/database.dart';
import '../constants/constant.dart';

/// 数据库调试工具
class DatabaseDebug {
  /// 检查数据库文件是否存在
  static Future<bool> checkDatabaseExists() async {
    final file = await getDatabaseFile(null);
    final exists = await file.exists();
    print('Database file exists: $exists');
    print('Database file path: ${file.path}');
    return exists;
  }

  /// 检查数据库版本信息
  static Future<void> checkDatabaseVersion() async {
    try {
      final file = await getDatabaseFile(null);
      if (await file.exists()) {
        final db = AppDatabase(NativeDatabase(file));
        // 通过查询系统表来获取版本信息
        final result = await db.customSelect('PRAGMA user_version').get();
        final version = result.first.data.values.first as int;
        print('Current database schema version: $version');
        await db.close();
      } else {
        print('Database file does not exist');
      }
    } catch (e) {
      print('Error checking database version: $e');
    }
  }

  /// 强制触发迁移
  static Future<void> forceMigration() async {
    try {
      final file = await getDatabaseFile(null);
      if (await file.exists()) {
        print('Deleting existing database file to force recreation');
        await file.delete();
      }
      
      print('Creating new database with schema version 2');
      final db = AppDatabase(NativeDatabase(file));
      // 通过查询系统表来获取版本信息
      final result = await db.customSelect('PRAGMA user_version').get();
      final version = result.first.data.values.first as int;
      print('New database schema version: $version');
      await db.close();
    } catch (e) {
      print('Error during forced migration: $e');
    }
  }
} 