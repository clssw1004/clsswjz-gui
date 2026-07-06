import 'dart:io';
import 'package:drift/native.dart';
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

  /// 检查数据库版本信息
  static Future<void> checkDatabaseVersion({File? file}) async {
    try {
      final dbFile = file;
      if (dbFile == null) {
        print('No database file specified for version check');
        return;
      }
      if (await dbFile.exists()) {
        final db = AppDatabase(NativeDatabase(dbFile));
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
} 