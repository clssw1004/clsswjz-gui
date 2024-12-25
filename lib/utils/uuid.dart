import 'package:uuid/uuid.dart';

/// 生成 UUID
String generateUuid() {
  return const Uuid().v4();
}
