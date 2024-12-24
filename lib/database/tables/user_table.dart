import 'package:drift/drift.dart';
import 'base_table.dart';

@DataClassName('User')
class UserTable extends BaseTable {
  TextColumn get username => text().named('username')();
  TextColumn get nickname => text().named('nickname')();
  TextColumn get password => text().named('password')();
  TextColumn get email => text().nullable().named('email')();
  TextColumn get phone => text().nullable().named('phone')();
  TextColumn get inviteCode => text().named('invite_code')();
  TextColumn get language =>
      text().named('language').withDefault(const Constant('zh-CN'))();
  TextColumn get timezone =>
      text().named('timezone').withDefault(const Constant('Asia/Shanghai'))();
}
