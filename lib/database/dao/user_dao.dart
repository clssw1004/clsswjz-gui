import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';
import '../tables/user_table.dart';
import 'base_dao.dart';

class UserDao extends BaseDao<UserTable, User> {
  UserDao(super.db);

  Future<User?> findByUsername(String username) {
    return (db.select(db.userTable)..where((t) => t.username.equals(username)))
        .getSingleOrNull();
  }

  Future<bool> isUsernameExists(String username) async {
    final user = await findByUsername(username);
    return user != null;
  }

  Future<void> createUser({
    required String id,
    required String username,
    required String nickname,
    required String password,
    required String inviteCode,
    String? email,
    String? phone,
    String language = 'zh-CN',
    String timezone = 'Asia/Shanghai',
  }) {
    return insert(
      UserTableCompanion.insert(
        id: id,
        username: username,
        nickname: nickname,
        password: password,
        inviteCode: inviteCode,
        email: Value(email),
        phone: Value(phone),
        language: Value(language),
        timezone: Value(timezone),
        createdAt: DateUtil.now(),
        updatedAt: DateUtil.now(),
      ),
    );
  }

  Future<User?> findByInviteCode(String inviteCode) {
    return (db.select(db.userTable)
          ..where((t) => t.inviteCode.equals(inviteCode)))
        .getSingleOrNull();
  }

  @override
  TableInfo<UserTable, User> get table => db.userTable;
}
