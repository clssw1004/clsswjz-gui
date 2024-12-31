import 'package:uuid/uuid.dart';

/// 生成UUID
String generateUuid() {
  return const Uuid().v4().replaceAll('-', '');
}
