import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

import 'database.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static late AppDatabase _db;

  DatabaseService._();

  static Future<DatabaseService> get instance async {
    _instance ??= DatabaseService._();
    await _initDatabase();
    return _instance!;
  }

  static AppDatabase get db => _db;

  static Future<void> _initDatabase() async {
    if (_instance != null) return;

    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    _db = AppDatabase(NativeDatabase(file));
  }

  Future<void> closeDatabase() async {
    await _db.close();
  }
}
