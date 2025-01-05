import 'package:nanoid/nanoid.dart';
import 'package:uuid/uuid.dart';

class IdUtil {
  static const _alphabet =
      '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const uuid = Uuid();

  static String genId() {
    return uuid.v4().replaceAll('-', '');
  }

  static String genNanoId(int length) {
    return customAlphabet(_alphabet, length);
  }

  static String genNanoId6() {
    return genNanoId(6);
  }

  static String genNanoId8() {
    return genNanoId(8);
  }

  static String genNanoId10() {
    return genNanoId(10);
  }

  static String genNanoId16() {
    return genNanoId(16);
  }
}
