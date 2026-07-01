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
import 'tables/recurring_config_table.dart';
import 'tables/bookkeeping_rule_table.dart';
import 'tables/item_rel_field_table.dart';
import '../utils/id_util.dart';
import '../utils/date_util.dart';

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
    RecurringConfigTable,
    BookkeepingRuleTable,
    ItemRelFieldTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 18;

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
          if (from < 12) {
            // 版本11到版本12的迁移：account_note_table新增scope列
            try {
              await m.addColumn(accountNoteTable, accountNoteTable.scope);
            } catch (_) {
              // 列已存在时忽略
            }
          }
          if (from < 13) {
            // 版本12到版本13的迁移：account_note_table新增template列
            try {
              await m.addColumn(accountNoteTable, accountNoteTable.template);
            } catch (_) {
              // 列已存在时忽略
            }
          }
          if (from < 14) {
            // 版本13到版本14的迁移：新增固定收支配置表
            await m.create(recurringConfigTable);
          }
          if (from < 15) {
            // 版本14到版本15的迁移：新增记账规则表
            await m.create(bookkeepingRuleTable);
          }
          if (from < 16) {
            // 版本15到版本16的迁移：分类/商户表新增树形字段
            try {
              await m.addColumn(accountCategoryTable, accountCategoryTable.parentId);
              await m.addColumn(accountCategoryTable, accountCategoryTable.sortOrder);
              await m.addColumn(accountShopTable, accountShopTable.parentId);
              await m.addColumn(accountShopTable, accountShopTable.sortOrder);
            } catch (_) {
              // 列已存在时忽略
            }
          }
          if (from < 17) {
            // 版本16到版本17的迁移：分类/商户表新增isBookkeepingSelectable列
            try {
              await m.addColumn(accountCategoryTable, accountCategoryTable.isBookkeepingSelectable);
              await m.addColumn(accountShopTable, accountShopTable.isBookkeepingSelectable);
            } catch (_) {
              // 列已存在时忽略
            }
          }
          if (from < 18) {
            // 版本17到版本18的迁移：新增 item_rel_field 表，迁移 tag_code 数据
            await m.create(itemRelFieldTable);
            // ignore: invalid_use_of_protected_member
            final items = await select(accountItemTable).get();
            for (final item in items) {
              if (item.tagCode != null) {
                // ignore: invalid_use_of_protected_member
                await into(itemRelFieldTable).insert(ItemRelFieldTableCompanion(
                  id: Value(IdUtil.genId()),
                  itemId: Value(item.id),
                  fieldCode: const Value('TAG'),
                  fieldValue: Value(item.tagCode!),
                  createdAt: Value(DateUtil.now()),
                  updatedAt: Value(DateUtil.now()),
                ));
              }
            }
          }
        },
      );
}
