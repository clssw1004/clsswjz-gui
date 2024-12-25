import 'package:drift/native.dart';
import '../constants/constant.dart';
import 'database.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static late AppDatabase _db;

  DatabaseService._();

  static Future<DatabaseService> get instance async {
    await _initDatabase();
    _instance ??= DatabaseService._();
    return _instance!;
  }

  static AppDatabase get db => _db;

  static Future<void> _initDatabase() async {
    if (_instance != null) return;

    final file = await getDatabaseFile();
    _db = AppDatabase(NativeDatabase(file));
  }

  Future<void> closeDatabase() async {
    await _db.close();
  }
}
