import 'dart:convert';
import 'package:crypto/crypto.dart';

class DigestUtil {
  static String toSha256(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  static String toMd5(String data) {
    return md5.convert(utf8.encode(data)).toString();
  }
}

