import 'package:drift/drift.dart';
import 'tables/account_book_table.dart';
import 'tables/account_category_table.dart';
import 'tables/account_fund_table.dart';
import 'tables/account_item_table.dart';
import 'tables/account_shop_table.dart';
import 'tables/account_symbol_table.dart';
import 'tables/rel_accountbook_fund_table.dart';
import 'tables/rel_accountbook_user_table.dart';
import 'tables/user_table.dart';
import 'tables/attachment_table.dart';
import '../../utils/date_util.dart';
part 'database.g.dart';

@DriftDatabase(
  tables: [
    AccountBookTable,
    AccountCategoryTable,
    AccountFundTable,
    AccountItemTable,
    AccountShopTable,
    AccountSymbolTable,
    RelAccountbookFundTable,
    RelAccountbookUserTable,
    UserTable,
    AttachmentTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // 处理数据库升级
        },
      );

  // 根据用户名查询用户
  Future<User?> findUserByUsername(String username) async {
    return (select(userTable)..where((t) => t.username.equals(username)))
        .getSingleOrNull();
  }

  // 用户登录验证
  Future<User?> verifyUser(String username, String password) async {
    return (select(userTable)
          ..where(
              (t) => t.username.equals(username) & t.password.equals(password)))
        .getSingleOrNull();
  }

  // 检查用户名是否已存在
  Future<bool> isUsernameExists(String username) async {
    final query = select(userTable)..where((t) => t.username.equals(username));
    final user = await query.getSingleOrNull();
    return user != null;
  }

  // 创建新用户
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
    return into(userTable).insert(
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
}
