import 'package:drift/native.dart';
import '../constants/constant.dart';
import '../database/database.dart';

class DatabaseManager {
  static DatabaseManager? _instance;
  static late AppDatabase _db;

  DatabaseManager._();

  static Future<void> init() async {
    if (_instance != null) return;

    final file = await getDatabaseFile();
    _db = AppDatabase(NativeDatabase(file));
    _instance ??= DatabaseManager._();
  }

  static Future<DatabaseManager> get instance async {
    return _instance!;
  }

  static AppDatabase get db => _db;

  Future<void> closeDatabase() async {
    await _db.close();
  }
}
