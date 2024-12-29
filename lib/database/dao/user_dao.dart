import 'package:drift/drift.dart';
import '../database.dart';

class UserDao {
  final AppDatabase db;

  UserDao(this.db);

  Future<int> insert(UserTableCompanion entity) {
    return db.into(db.userTable).insert(entity);
  }

  Future<void> batchInsert(List<UserTableCompanion> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(db.userTable, entity, mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> update(UserTableCompanion entity) {
    return db.update(db.userTable).replace(entity);
  }

  Future<int> delete(User entity) {
    return db.delete(db.userTable).delete(entity);
  }

  Future<List<User>> findAll() {
    return db.select(db.userTable).get();
  }

  Future<User?> findById(String id) {
    return (db.select(db.userTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<User>> findByIds(List<String> ids) {
    return (db.select(db.userTable)..where((t) => t.id.isIn(ids))).get();
  }

  Future<User?> findByUsername(String username) {
    return (db.select(db.userTable)..where((t) => t.username.equals(username)))
        .getSingleOrNull();
  }

  Future<bool> isUsernameExists(String username) async {
    final user = await findByUsername(username);
    return user != null;
  }

  Future<int> createUser({
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
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Future<User?> findByInviteCode(String inviteCode) {
    return (db.select(db.userTable)
          ..where((t) => t.inviteCode.equals(inviteCode)))
        .getSingleOrNull();
  }
}
