import 'package:nanoid/nanoid.dart';
import 'package:uuid/uuid.dart';

const _alphabet =
    '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
const uuid = Uuid();

String genId() {
  return uuid.v4().replaceAll('-', '');
}

String genNanoId(int length) {
  return customAlphabet(_alphabet, length);
}

String genNanoId6() {
  return genNanoId(6);
}

String genNanoId8() {
  return genNanoId(8);
}

String genNanoId10() {
  return genNanoId(10);
}

String genNanoId16() {
  return genNanoId(16);
}
