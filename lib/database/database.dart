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
import 'tables/gift_card_table.dart';

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
    GiftCardTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;

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
          if (from < 3) {
            // 版本2到版本3的迁移：添加 gift_card_table
            await m.createAll();
          }
          if (from < 4) {
            // 版本3到版本4的迁移：重建 gift_card_table（移除amount，添加sentTime和receivedTime）
            await m.deleteTable('gift_card_table');
            await m.createTable(giftCardTable);
          }
          if (from < 5) {
            // 版本4到版本5的迁移：移除昵称字段，改为查询时翻译
            await m.deleteTable('gift_card_table');
            await m.createTable(giftCardTable);
          }
        },
      );
}
