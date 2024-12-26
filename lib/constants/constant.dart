import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const dbName = 'db.sqlite';
Future<File> getDatabaseFile() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(path.join(dbFolder.path, dbName));
  return file;
}

const SYMBOL_TYPE_TAG = 'TAG';
const SYMBOL_TYPE_PROJECT = 'PROJECT';
