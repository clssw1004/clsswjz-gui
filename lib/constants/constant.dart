import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const dbName = 'clsswjz';
Future<File> getDatabaseFile(String? fileName) async {
  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(path.join(dbFolder.path, '${fileName ?? dbName}.sqlite'));
  return file;
}

const defaultAvatar = 'default_avatar';
