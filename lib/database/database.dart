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
import 'tables/account_book_log_table.dart';
part 'database.g.dart';

@DriftDatabase(
  tables: [
    AccountBookTable,
    AccountBookLogTable,
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
}
