import 'package:drift/drift.dart';
import 'tables/account_book_table.dart';
import 'tables/account_category_table.dart';
import 'tables/account_fund_table.dart';
import 'tables/account_item_table.dart';
import 'tables/account_note_table.dart';
import 'tables/account_shop_table.dart';
import 'tables/account_symbol_table.dart';
import 'tables/attachment_table.dart';
import 'tables/log_sync_table.dart';
import 'tables/rel_accountbook_user_table.dart';
import 'tables/user_table.dart';
import 'tables/account_debt_table.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    UserTable,
    AccountBookTable,
    AccountItemTable,
    AccountCategoryTable,
    AccountFundTable,
    AccountShopTable,
    AccountSymbolTable,
    RelAccountbookUserTable,
    LogSyncTable,
    AttachmentTable,
    AccountNoteTable,
    AccountDebtTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // 处理数据库升级
          if (from < 2) {
            // 版本1到版本2的迁移：为 account_note_table 添加 groupCode 字段
            await m.addColumn(accountNoteTable, accountNoteTable.groupCode);
          }
        },
      );
}
