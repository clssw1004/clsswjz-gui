import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';
import '../tables/user_table.dart';
import 'base_dao.dart';

class UserDao extends BaseDao<UserTable, User> {
  UserDao(super.db);

  Future<User?> findByUsername(String username) {
    return (db.select(db.userTable)..where((t) => t.username.equals(username))).getSingleOrNull();
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
    return (db.select(db.userTable)..where((t) => t.inviteCode.equals(inviteCode))).getSingleOrNull();
  }

  /// 获取当前用户可选择的接收人列表（从账本关联成员中获取，去重、去掉自己）
  Future<List<User>> findSelectableRecipients(String userId) async {
    // 获取用户所属的所有账本
    final userBooks = await (db.select(db.relAccountbookUserTable)
          ..where((t) => t.userId.equals(userId)))
        .get();

    if (userBooks.isEmpty) {
      return [];
    }

    final bookIds = userBooks.map((ub) => ub.accountBookId).toList();

    // 获取这些账本的所有成员
    final allMembers = await (db.select(db.relAccountbookUserTable)
          ..where((t) => t.accountBookId.isIn(bookIds)))
        .get();

    // 收集所有成员的用户ID（去重、去掉自己）
    final memberUserIds = allMembers
        .map((m) => m.userId)
        .where((id) => id != userId)
        .toSet()
        .toList();

    if (memberUserIds.isEmpty) {
      return [];
    }

    // 查找这些用户的详细信息
    return findByIds(memberUserIds);
  }

  @override
  TableInfo<UserTable, User> get table => db.userTable;
}
