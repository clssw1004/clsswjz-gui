import 'dart:io';
import '../database/database.dart';

/// 数据库调试工具
class DatabaseDebug {
  /// 检查数据库文件是否存在
  static Future<bool> checkDatabaseExists({required File file}) async {
    final exists = await file.exists();
    print('Database file exists: $exists');
    print('Database file path: ${file.path}');
    return exists;
  }

  /// 检查数据库版本信息 (需传入已打开的 AppDatabase 实例)
  static Future<void> checkDatabaseVersion(AppDatabase db) async {
    try {
      final result = await db.customSelect('PRAGMA user_version').get();
      final version = result.first.data.values.first as int;
      print('Current database schema version: $version');
    } catch (e) {
      print('Error checking database version: $e');
    }
  }
} 