import 'dart:convert';
import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('User')
class UserTable extends BaseTable {
  TextColumn get username => text().named('username')();
  TextColumn get nickname => text().named('nickname')();
  TextColumn get avatar => text().nullable().named('avatar')();
  TextColumn get password => text().named('password')();
  TextColumn get email => text().nullable().named('email')();
  TextColumn get phone => text().nullable().named('phone')();
  TextColumn get inviteCode => text().named('invite_code')();
  TextColumn get language => text().named('language').withDefault(const Constant('zh-CN'))();
  TextColumn get timezone => text().named('timezone').withDefault(const Constant('Asia/Shanghai'))();

  /// 生成创建数据的伴生对象
  static UserTableCompanion toCreateCompanion({
    required String username,
    required String nickname,
    required String password,
    String? email,
    String? phone,
    required String inviteCode,
    String language = 'zh-CN',
    String timezone = 'Asia/Shanghai',
  }) =>
      UserTableCompanion(
        id: Value(IdUtil.genId()),
        username: Value(username),
        nickname: Value(nickname),
        password: Value(password),
        email: Value.absentIfNull(email),
        phone: Value.absentIfNull(phone),
        inviteCode: Value(inviteCode),
        language: Value(language),
        timezone: Value(timezone),
        createdAt: Value(DateUtil.now()),
        updatedAt: Value(DateUtil.now()),
      );

  /// 生成更新数据的伴生对象
  static UserTableCompanion toUpdateCompanion({
    String? nickname,
    String? password,
    String? email,
    String? phone,
    String? language,
    String? timezone,
  }) {
    return UserTableCompanion(
      nickname: Value.absentIfNull(nickname),
      password: Value.absentIfNull(password),
      email: Value.absentIfNull(email),
      phone: Value.absentIfNull(phone),
      language: Value.absentIfNull(language),
      timezone: Value.absentIfNull(timezone),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(UserTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'username', companion.username);
    MapUtil.setIfPresent(map, 'nickname', companion.nickname);
    MapUtil.setIfPresent(map, 'password', companion.password);
    MapUtil.setIfPresent(map, 'email', companion.email);
    MapUtil.setIfPresent(map, 'phone', companion.phone);
    MapUtil.setIfPresent(map, 'inviteCode', companion.inviteCode);
    MapUtil.setIfPresent(map, 'language', companion.language);
    MapUtil.setIfPresent(map, 'timezone', companion.timezone);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    return jsonEncode(map);
  }
}
