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
import 'tables/activity_definition_table.dart';
import 'tables/activity_record_table.dart';
import 'tables/vehicle_table.dart';
import 'tables/fuel_record_table.dart';
import 'tables/item_relation_table.dart';
import 'tables/user_share_table.dart';

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
    ActivityDefinitionTable,
    ActivityRecordTable,
    VehicleTable,
    FuelRecordTable,
    ItemRelationTable,
    UserShareTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 11;

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
            // 版本3到版本4的迁移：添加 activity_record_table
            await m.create(activityRecordTable);
          }
          if (from < 5) {
            // 版本4到版本5的迁移：添加 vehicle_table 和 fuel_record_table
            await m.create(vehicleTable);
            await m.create(fuelRecordTable);
          }
          if (from < 6) {
            // 版本5到版本6的迁移：添加 item_relation_table
            await m.create(itemRelationTable);
          }
          if (from < 7) {
            // 版本6到版本7的迁移：添加活动定义表，activityRecord表新增activityDefId列
            await m.create(activityDefinitionTable);
            await m.addColumn(
                activityRecordTable, activityRecordTable.activityDefId);
          }
          if (from < 8) {
            await m.create(userShareTable);
          }
          if (from < 9) {
            // 版本8到版本9的迁移：activityRecord表新增maxDailyCount列
            await m.addColumn(
                activityRecordTable, activityRecordTable.maxDailyCount);
          }
          if (from < 10) {
            // 版本9到版本10的迁移：activityDefinition表新增maxDailyCount列
            await m.addColumn(
                activityDefinitionTable, activityDefinitionTable.maxDailyCount);
          }
          if (from < 11) {
            // 版本10到版本11的迁移：activityRecord表新增remark列
            try {
              await m.addColumn(
                  activityRecordTable, activityRecordTable.remark);
            } catch (_) {
              // 列已存在时忽略
            }
          }
        },
      );
}
