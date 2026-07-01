# 记账标签多选功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将账目（account_item）标签从单选改为多选，支持一笔账关联多个标签

**Architecture:** 新增 `item_rel_field` 通用内部属性表（`fieldCode='TAG'` 标识标签），取代 `account_item.tag_code` 单列。`ItemCULog` 在事务内同时写 item + item_rel_field，同步回放兼容旧日志格式。UI 用 `MultiSelectSheet` 多选 + Chip 行展示。

**Tech Stack:** Flutter, Drift (SQLite), Provider

---

### Task 1: 新增 `item_rel_field` 表定义

**Files:**
- Create: `lib/database/tables/item_rel_field_table.dart`

- [ ] **Step 1: 创建表文件**

参照 `item_relation_table.dart` 的风格和 `BaseTable` 继承模式，新建 `ItemRelFieldTable`。

```dart
import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../../utils/date_util.dart';
import 'base_table.dart';

@DataClassName('ItemRelField')
class ItemRelFieldTable extends BaseTable {
  TextColumn get itemId => text()();
  TextColumn get fieldCode => text()();
  TextColumn get fieldValue => text()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {itemId, fieldCode, fieldValue};

  static ItemRelFieldTableCompanion toCreateCompanion({
    required String itemId,
    required String fieldCode,
    required String fieldValue,
    int? sortOrder,
  }) {
    return ItemRelFieldTableCompanion(
      id: Value(IdUtil.genId()),
      itemId: Value(itemId),
      fieldCode: Value(fieldCode),
      fieldValue: Value(fieldValue),
      sortOrder: Value.absentIfNull(sortOrder),
      createdAt: Value(DateUtil.now()),
      updatedAt: Value(DateUtil.now()),
    );
  }

  static String toJsonString(ItemRelFieldTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'itemId', companion.itemId);
    MapUtil.setIfPresent(map, 'fieldCode', companion.fieldCode);
    MapUtil.setIfPresent(map, 'fieldValue', companion.fieldValue);
    MapUtil.setIfPresent(map, 'sortOrder', companion.sortOrder);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    return jsonEncode(map);
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/database/tables/item_rel_field_table.dart
git commit -m "feat: add item_rel_field table for multi-tag support"
```

### Task 2: 新增 `ItemRelFieldDao`

**Files:**
- Create: `lib/database/dao/item_rel_field_dao.dart`

- [ ] **Step 1: 创建 DAO**

```dart
import 'package:drift/drift.dart';
import '../../utils/collection_util.dart';
import '../database.dart';
import '../tables/item_rel_field_table.dart';
import 'base_dao.dart';

class ItemRelFieldDao extends BaseDao<ItemRelFieldTable, ItemRelField> {
  ItemRelFieldDao(super.db);

  Future<List<ItemRelField>> findByItemId(String itemId) {
    return (db.select(table)..where((t) => t.itemId.equals(itemId))).get();
  }

  Future<Map<String, List<ItemRelField>>> findByItemIds(
    List<String> itemIds, {
    String? fieldCode,
  }) {
    var query = db.select(table)..where((t) => t.itemId.isIn(itemIds));
    if (fieldCode != null) {
      query = query..where((t) => t.fieldCode.equals(fieldCode));
    }
    return query.get().then(
        (rows) => CollectionUtil.groupBy(rows, (r) => r.itemId));
  }

  Future<List<ItemRelField>> findByFieldCodeAndValues(
      String fieldCode, List<String> values) {
    return (db.select(table)
      ..where((t) =>
          t.fieldCode.equals(fieldCode) &
          t.fieldValue.isIn(values))
    ).get();
  }

  Future<int> deleteByItemAndCode(String itemId, String fieldCode) {
    return (db.delete(table)
      ..where((t) =>
          t.itemId.equals(itemId) &
          t.fieldCode.equals(fieldCode))
    ).go();
  }

  Future<void> insert(ItemRelFieldTableCompanion companion) async {
    await db.into(table).insert(companion);
  }

  @override
  TableInfo<ItemRelFieldTable, ItemRelField> get table => db.itemRelFieldTable;
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/database/dao/item_rel_field_dao.dart
git commit -m "feat: add ItemRelFieldDao"
```

### Task 3: 注册表、DAO、迁移 v18

**Files:**
- Modify: `lib/database/database.dart`
- Modify: `lib/manager/dao_manager.dart`

- [ ] **Step 1: 在 `database.dart` 中注册表和 DAO**

在 `import` 区块添加：
```dart
import 'tables/item_rel_field_table.dart';
```

在 `@DriftDatabase(tables: [...])` 列表中添加 `ItemRelFieldTable`。

在 `@ConstructedBy(...)` / DAO 注册处添加 `ItemRelFieldDao`（参照 `ItemRelationDao` 的方式）。

修改 `schemaVersion` 为 18。

在 `onUpgrade` 的 `from < 17` 后面追加：
```dart
if (from < 18) {
  await m.create(itemRelFieldTable);
  // 迁移已有 tag_code 数据
  await db.customStatement('''
    INSERT INTO item_rel_field (id, item_id, field_code, field_value, created_at, updated_at)
    SELECT lower(hex(randomblob(16))), id, 'TAG', tag_code, created_at, updated_at
    FROM account_item WHERE tag_code IS NOT NULL
  ''');
}
```

> 注意：SQLite 没有 `gen_id()`，用 `lower(hex(randomblob(16)))` 生成 32 字符 hex 字符串作为 id。或使用 Drift 的迁移 API 逐行插入。

实际上，更稳妥的方式是用 Dart 在迁移中逐行插入：
```dart
if (from < 18) {
  await m.create(itemRelFieldTable);
  // 逐行迁移已有标签数据
  final items = await db.select(db.accountItemTable).get();
  for (final item in items) {
    if (item.tagCode != null) {
      await db.into(db.itemRelFieldTable).insert(ItemRelFieldTableCompanion(
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
```

- [ ] **Step 2: 在 `dao_manager.dart` 中注册**

```dart
import '../database/dao/item_rel_field_dao.dart';

// 在类中加静态属性
static late ItemRelFieldDao itemRelFieldDao;

// 在 refreshDaos 中初始化
itemRelFieldDao = ItemRelFieldDao(DatabaseManager.db);
```

- [ ] **Step 3: 提交**

```bash
git add lib/database/database.dart lib/manager/dao_manager.dart
git commit -m "feat: register ItemRelFieldTable, migration v18"
```

### Task 4: 从 `AccountItemTable` 移除 `tagCode` companion 方法

**Files:**
- Modify: `lib/database/tables/account_item_table.dart`

- [ ] **Step 1: 移除 `toUpdateCompanion` 中的 `tagCode`**

```dart
static AccountItemTableCompanion toUpdateCompanion(
  String who, {
  double? amount,
  String? description,
  AccountItemType? type,
  String? categoryCode,
  String? accountDate,
  String? accountBookId,
  String? fundId,
  String? shopCode,
  // String? tagCode,  ← 移除
  String? projectCode,
}) {
  return AccountItemTableCompanion(
    updatedBy: Value(who),
    updatedAt: Value(DateUtil.now()),
    amount: Value.absentIfNull(amount),
    description: Value.absentIfNull(description),
    type: Value.absentIfNull(type?.code),
    categoryCode: Value.absentIfNull(categoryCode),
    accountDate: Value.absentIfNull(accountDate),
    accountBookId: Value.absentIfNull(accountBookId),
    fundId: Value.absentIfNull(fundId),
    shopCode: Value.absentIfNull(shopCode),
    // tagCode: Value.absentIfNull(tagCode),  ← 移除
    projectCode: Value.absentIfNull(projectCode),
    createdBy: const Value.absent(),
    createdAt: const Value.absent(),
  );
}
```

- [ ] **Step 2: 移除 `toCreateCompanion` 中的 `tagCode`**

```dart
static AccountItemTableCompanion toCreateCompanion(
  String who,
  String accountBookId, {
  required double amount,
  String? description,
  required AccountItemType type,
  String? categoryCode,
  required String accountDate,
  String? fundId,
  String? shopCode,
  // String? tagCode,  ← 移除
  String? projectCode,
  String? source,
  String? sourceId,
}) =>
    AccountItemTableCompanion(
      id: Value(IdUtil.genId()),
      accountBookId: Value(accountBookId),
      amount: Value(amount),
      description: Value.absentIfNull(description),
      type: Value(type.code),
      categoryCode: Value.absentIfNull(categoryCode),
      accountDate: Value(accountDate),
      fundId: Value.absentIfNull(fundId),
      shopCode: Value.absentIfNull(shopCode),
      // tagCode: Value.absentIfNull(tagCode),  ← 移除
      projectCode: Value.absentIfNull(projectCode),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      source: Value.absentIfNull(source),
      sourceId: Value.absentIfNull(sourceId),
    );
```

- [ ] **Step 3: 移除 `toJsonString` 中的 `tagCode`**

```dart
// 移除这一行:
// MapUtil.setIfPresent(map, 'tagCode', companion.tagCode);
```

- [ ] **Step 4: 提交**

```bash
git add lib/database/tables/account_item_table.dart
git commit -m "feat: remove tagCode from AccountItemTable companion methods"
```

### Task 5: 修改 `UserItemVO` — 支持多标签

**Files:**
- Modify: `lib/models/vo/user_item_vo.dart`

- [ ] **Step 1: 替换 tagCode/tagName 为 tags 列表**

```dart
// 替换这两行：
// String? tagCode;       (line 45)
// String? tagName;       (line 72)
// 为：
List<AccountSymbol> tags = [];

// 保留兼容 getter
String? get firstTagCode => tags.isNotEmpty ? tags.first.code : null;
String? get firstTagName => tags.isNotEmpty ? tags.first.name : null;
```

- [ ] **Step 2: 更新 `copyWith`**

```dart
// 替换参数中的:
// String? tagCode,
// String? tagName,
// 为:
List<AccountSymbol>? tags,

// 在构造调用中替换:
// tagCode: tagCode ?? this.tagCode,
// tagName: tagName ?? this.tagName,
// 为:
tags: tags ?? this.tags,
```

- [ ] **Step 3: 更新构造方法**

```dart
// 替换:
// this.tagCode,
// this.tagName,
// 为:
this.tags = const [],
```

- [ ] **Step 4: 更新 `fromAccountItem`**

```dart
// 移除参数 String? tagName,
// 添加参数 List<AccountSymbol>? tags,
// 在构造调用中:
// tagCode: item.tagCode,  ← 移除
// tagName: tagName,       ← 移除
// tags: tags ?? [],       ← 添加
```

- [ ] **Step 5: 更新 `toAccountItem`**

```dart
// tagCode: vo.tagCode,  ← 改为:
tagCode: vo.firstTagCode,
```

- [ ] **Step 6: 更新 `setTag` → `addTag`/`removeTag`**

```dart
void addTag(AccountSymbol tag) {
  tags = [...tags, tag];
}

void removeTag(String tagCode) {
  tags = tags.where((t) => t.code != tagCode).toList();
}
```

- [ ] **Step 7: 提交**

```bash
git add lib/models/vo/user_item_vo.dart
git commit -m "feat: update UserItemVO with multi-tag support"
```

### Task 6: 修改 `VOTansfer` — 批量加载多标签

**Files:**
- Modify: `lib/drivers/vo_transfer.dart`

- [ ] **Step 1: 在 `transferItems` 中添加多标签加载**

在现有查询之后（`tags` map 查询之前或替代它），添加 `item_rel_field` 批量查询：

```dart
// 替换旧的标签查询（lines 60-61）:
// final tags = CollectionUtil.toMap(
//     symbolMap[SymbolType.tag.code] ?? [], (s) => s.code);
// 为：

// 批量加载 item_rel_field（取 TAG 类型）
final relFieldMap = await DaoManager.itemRelFieldDao.findByItemIds(
  items.map((i) => i.id).toList(),
  fieldCode: 'TAG',
);
// 收集所有 tag code → 查 symbol 拿 name
final allTagCodes = relFieldMap.values
    .expand((fields) => fields.map((f) => f.fieldValue))
    .toSet()
    .toList();
final tagSymbols = CollectionUtil.toMap(
  await DaoManager.symbolDao.findByCodes(allTagCodes),
  (s) => s.code,
);
```

- [ ] **Step 2: 在组装 VO 时传递 tags**

```dart
// 替换:
// final tag = tags[item.tagCode];  (line 77)
// 和:
// tagName: tag?.name,             (line 90)
// 为:
final itemRelFields = relFieldMap[item.id] ?? [];
final itemTags = itemRelFields
    .map((f) => tagSymbols[f.fieldValue])
    .whereType<AccountSymbol>()
    .toList();

// 替换 fromAccountItem 调用中的 tagName: tag?.name,
// 改为 tags: itemTags,
```

- [ ] **Step 3: 提交**

```bash
git add lib/drivers/vo_transfer.dart
git commit -m "feat: batch load tags from item_rel_field in VO transfer"
```

### Task 7: 修改 `ItemDao` 标签过滤

**Files:**
- Modify: `lib/database/dao/item_dao.dart`

- [ ] **Step 1: 替换标签过滤逻辑**

```dart
// 替换 (lines 70-73):
// // 标签筛选
// if (filter.tagCodes?.isNotEmpty == true) {
//   query = query..where((t) => t.tagCode.isIn(filter.tagCodes!));
// }
// 为:
// 标签筛选（通过 item_rel_field 反查 item_id）
if (filter.tagCodes?.isNotEmpty == true) {
  final relFields = await DaoManager.itemRelFieldDao
      .findByFieldCodeAndValues('TAG', filter.tagCodes!);
  final matchingIds = relFields.map((f) => f.itemId).toSet().toList();
  if (matchingIds.isEmpty) {
    // 无匹配，返回空结果
    query = query..where((t) => t.id.equals('__no_match__'));
  } else {
    query = query..where((t) => t.id.isIn(matchingIds));
  }
}
```

- [ ] **Step 2: 添加 `DaoManager` 导入**（如果尚未导入）

```dart
import '../../manager/dao_manager.dart';
```

- [ ] **Step 3: 提交**

```bash
git add lib/database/dao/item_dao.dart
git commit -m "feat: update tag filtering to use item_rel_field"
```

### Task 8: 修改 `ItemCULog` — 核心改动

**Files:**
- Modify: `lib/drivers/special/log/builder/book_item.builder.dart`

- [ ] **Step 1: 添加 `_tagCodes` 字段，新增导入**

```dart
import '../../../../database/tables/item_rel_field_table.dart';
import '../../../../manager/dao_manager.dart';
```

在类体中添加：
```dart
List<String>? _tagCodes;
```

- [ ] **Step 2: 修改 `executeLog`**

```dart
@override
Future<String> executeLog() async {
  if (operateType == OperateType.create) {
    await DaoManager.itemDao.insert(data!);
    target(data!.id.value);
    // 插入标签关联
    if (_tagCodes != null) {
      for (final code in _tagCodes!) {
        await DaoManager.itemRelFieldDao.insert(
          ItemRelFieldTable.toCreateCompanion(
            itemId: data!.id.value,
            fieldCode: 'TAG',
            fieldValue: code,
          ),
        );
      }
    }
    return data!.id.value;
  } else if (operateType == OperateType.update) {
    await DaoManager.itemDao.update(businessId!, data!);
    // 全删重建标签关联
    await DaoManager.itemRelFieldDao.deleteByItemAndCode(businessId!, 'TAG');
    if (_tagCodes != null) {
      for (final code in _tagCodes!) {
        await DaoManager.itemRelFieldDao.insert(
          ItemRelFieldTable.toCreateCompanion(
            itemId: businessId!,
            fieldCode: 'TAG',
            fieldValue: code,
          ),
        );
      }
    }
  }
  return businessId!;
}
```

- [ ] **Step 3: 修改 `data2Json`**

```dart
@override
String data2Json() {
  if (data == null) return '';
  if (operateType == OperateType.delete) {
    return data!.toString();
  } else {
    final json =
        AccountItemTable.toJsonString(data as AccountItemTableCompanion);
    final map = jsonDecode(json) as Map<String, dynamic>;
    map.remove('tagCode'); // 废弃字段不写入
    if (_tagCodes != null && _tagCodes!.isNotEmpty) {
      map['tagCodes'] = _tagCodes;
    }
    return jsonEncode(map);
  }
}
```

- [ ] **Step 4: 修改静态方法签名**

```dart
static ItemCULog create(String who, String bookId,
    {required double amount,
    String? description,
    required AccountItemType type,
    String? categoryCode,
    required String accountDate,
    String? fundId,
    String? shopCode,
    List<String>? tagCodes,    // String? tagCode → List<String>? tagCodes
    String? projectCode,
    String? source,
    String? sourceId,
    List<AttachmentVO>? attachments}) {
  return ItemCULog()
      .who(who)
      .inBook(bookId)
      .doCreate()
      .withData(AccountItemTable.toCreateCompanion(who, bookId,
          amount: amount,
          description: description,
          type: type,
          categoryCode: categoryCode,
          accountDate: accountDate,
          fundId: fundId,
          shopCode: shopCode,
          // tagCode: tagCode,  ← 移除
          projectCode: projectCode,
          source: source,
          sourceId: sourceId))
    .._tagCodes = tagCodes as ItemCULog;  // 注意：需要强制类型转换
}
```

> 注意：`.._tagCodes = tagCodes` 需要在 `as ItemCULog` 之后。更准确的方式：

```dart
  final builder = ItemCULog().who(who).inBook(bookId).doCreate().withData(
    AccountItemTable.toCreateCompanion(...)
  ) as ItemCULog;
  builder._tagCodes = tagCodes;
  return builder;
```

同样更新 `update` 方法：

```dart
static ItemCULog update(String userId, String bookId, String itemId,
    {double? amount,
    String? description,
    AccountItemType? type,
    String? categoryCode,
    String? accountDate,
    String? fundId,
    String? shopCode,
    List<String>? tagCodes,    // String? tagCode → List<String>? tagCodes
    String? projectCode}) {
  final builder = ItemCULog()
      .who(userId)
      .inBook(bookId)
      .target(itemId)
      .doUpdate()
      .withData(AccountItemTable.toUpdateCompanion(userId,
          amount: amount,
          description: description,
          type: type,
          categoryCode: categoryCode,
          accountDate: accountDate,
          fundId: fundId,
          shopCode: shopCode,
          // tagCode: tagCode,  ← 移除
          projectCode: projectCode)) as ItemCULog;
  builder._tagCodes = tagCodes;
  return builder;
}
```

- [ ] **Step 5: 修改 `fromCreateLog` — 兼容旧日志**

```dart
static ItemCULog fromCreateLog(LogSync log) {
  Map<String, dynamic> data = jsonDecode(log.operateData);
  // 提取 tag codes（兼容新旧格式）
  List<String>? tagCodes;
  if (data.containsKey('tagCodes')) {
    tagCodes = (data['tagCodes'] as List).cast<String>();
  } else if (data.containsKey('tagCode') && data['tagCode'] != null) {
    tagCodes = [data['tagCode'] as String]; // 旧日志兼容
  }
  data.remove('tagCode');
  data.remove('tagCodes');
  final builder = ItemCULog()
      .who(log.operatorId)
      .inBook(log.parentId)
      .doCreate()
      .withData(AccountItem.fromJson(data).toCompanion(true)) as ItemCULog;
  builder._tagCodes = tagCodes;
  return builder;
}
```

- [ ] **Step 6: 修改 `fromUpdateLog` — 兼容旧日志**

```dart
static ItemCULog fromUpdateLog(LogSync log) {
  Map<String, dynamic> data = jsonDecode(log.operateData);
  List<String>? tagCodes;
  if (data.containsKey('tagCodes')) {
    tagCodes = (data['tagCodes'] as List).cast<String>();
  } else if (data.containsKey('tagCode') && data['tagCode'] != null) {
    tagCodes = [data['tagCode'] as String];
  }
  data.remove('tagCode');
  data.remove('tagCodes');
  final builder = ItemCULog.update(
    log.operatorId,
    log.parentId,
    log.businessId,
    amount: data['amount'],
    description: data['description'],
    type: data['type'] != null
        ? AccountItemType.fromCode(data['type'])
        : null,
    categoryCode: data['categoryCode'],
    accountDate: data['accountDate'],
    fundId: data['fundId'],
    shopCode: data['shopCode'],
    // tagCode: data['tagCode'],  ← 不再传
    projectCode: data['projectCode'],
  );
  builder._tagCodes = tagCodes;
  return builder;
}
```

- [ ] **Step 7: 提交**

```bash
git add lib/drivers/special/log/builder/book_item.builder.dart
git commit -m "feat: update ItemCULog for multi-tag support with old log compat"
```

### Task 9: 修改 Driver 接口

**Files:**
- Modify: `lib/drivers/data_driver.dart`

- [ ] **Step 1: 修改 `createItem` 接口**

```dart
/// 创建账目
Future<OperateResult<String>> createItem(String userId, String bookId,
    {required double amount,
    String? description,
    required AccountItemType type,
    String? categoryCode,
    required String accountDate,
    String? fundId,
    String? shopCode,
    List<String>? tagCodes,    // String? tagCode →
    String? projectCode,
    String? source,
    String? sourceId,
    List<File>? files});
```

- [ ] **Step 2: 修改 `updateItem` 接口**

```dart
/// 更新账目
Future<OperateResult<void>> updateItem(
  String userId,
  String bookId,
  String itemId, {
  double? amount,
  String? description,
  AccountItemType? type,
  String? categoryCode,
  String? accountDate,
  String? fundId,
  String? shopCode,
  List<String>? tagCodes,    // String? tagCode →
  String? projectCode,
  List<AttachmentVO>? attachments,
});
```

- [ ] **Step 3: 提交**

```bash
git add lib/drivers/data_driver.dart
git commit -m "feat: update driver interface tagCode to tagCodes"
```

### Task 10: 修改 `LogDataDriver` 实现

**Files:**
- Modify: `lib/drivers/special/log.data_driver.dart`

- [ ] **Step 1: 找到 `createItem` 和 `updateItem` 实现**

使用 grep 定位行号：
```bash
grep -n 'createItem\|updateItem' lib/drivers/special/log.data_driver.dart | head -10
```

- [ ] **Step 2: 修改参数传递**

```dart
// createItem 内部:
// 旧: tagCode: tagCode,
// 新: tagCodes: tagCodes,

// updateItem 内部:
// 旧: tagCode: tagCode,
// 新: tagCodes: tagCodes,
```

- [ ] **Step 3: 提交**

```bash
git add lib/drivers/special/log.data_driver.dart
git commit -m "feat: update LogDataDriver tagCode to tagCodes"
```

### Task 11: 修改 `ItemFormProvider` — updateTag → updateTags

**Files:**
- Modify: `lib/providers/item_form_provider.dart`

- [ ] **Step 1: 修改 `updateTag` → `updateTags`**

```dart
// 替换 (lines 493-500):
void updateTags(List<AccountSymbol> tags) {
  _item.tags = tags;
  _applyRules('tagCodes');
  notifyListeners();
}
```

- [ ] **Step 2: 修改 `updateTagAndSave` → `updateTagsAndSave`**

```dart
// 替换 (lines 189-193):
Future<void> updateTagsAndSave(List<AccountSymbol> tags) async {
  updateTags(tags);
  await partUpdate(tagCodes: tags.map((t) => t.code).toList());
}
```

- [ ] **Step 3: 修改 `create` 方法**

```dart
// 替换 (line 361):
// tagCode: _item.tagCode,
// 为:
tagCodes: _item.tags.map((t) => t.code).toList(),
```

- [ ] **Step 4: 修改 `partUpdate` 方法**

```dart
// 替换参数:
// String? tagCode,   →  List<String>? tagCodes,

// 替换调用:
// tagCode: tagCode,  →  tagCodes: tagCodes,
```

- [ ] **Step 5: 提交**

```bash
git add lib/providers/item_form_provider.dart
git commit -m "feat: update ItemFormProvider for multi-tag support"
```

### Task 12: 规则引擎适配

**Files:**
- Modify: `lib/services/rule_engine.dart`

- [ ] **Step 1: 读取 `tagCode` 规则条件**

```dart
// 替换 (lines 322-323):
// case 'tagCode':
//   return item.tagCode;
// 为：
case 'tagCode':
case 'tagCodes':
  return item.firstTagCode;
```

- [ ] **Step 2: 写入 `tagCode` 规则动作（保守适配）**

```dart
// 替换 (lines 349-350):
// case 'tagCode':
//   item.tagCode = value as String?;
// 为：
case 'tagCode':
case 'tagCodes':
  // 规则引擎保持对单标签的向后兼容
  if (value != null) {
    item.tags = [AccountSymbol(
      code: value as String,
      name: '',
      symbolType: SymbolType.tag.code,
      accountBookId: item.accountBookId,
    )];
  } else {
    item.tags = [];
  }
```

> 注意：创建 `AccountSymbol` 对象需要完整字段。更安全的方式是查找已有 symbol：

```dart
case 'tagCode':
case 'tagCodes':
  if (value != null) {
    // 规则写入单标签，保持向后兼容
    item.tags = [AccountSymbol(
      code: value as String,
      name: '',
      symbolType: SymbolType.tag.code,
      accountBookId: item.accountBookId,
      id: '',
      createdAt: 0,
      updatedAt: 0,
      createdBy: '',
      updatedBy: '',
    )];
  }
```

- [ ] **Step 3: 提交**

```bash
git add lib/services/rule_engine.dart
git commit -m "feat: adapt rule engine for multi-tag, keep backward compat"
```

### Task 13: UI — 表单多标签选择

**Files:**
- Modify: `lib/pages/book/modern_item_form.dart`
- Modify: `lib/pages/book/item_add_page.dart`
- Modify: `lib/pages/book/item_edit_page.dart`

**模式：** 三个表单的标签字段做同样的改造。

- [ ] **Step 1: 改造 `modern_item_form.dart` 标签字段**

替换 lines 624-658 的 `CommonSelectFormField`：

```dart
// 旧代码 (lines 624-658):
CommonSelectFormField<AccountSymbol>(
  items: provider.tags.cast<AccountSymbol>(),
  value: item.tagCode,
  label: L10nManager.l10n.tag,
  displayMode: DisplayMode.badge,
  displayField: (e) => e.name,
  keyField: (e) => e.code,
  icon: Icons.local_offer_outlined,
  hint: L10nManager.l10n.tag,
  onCreateItem: (value) async { ... },
  onChanged: (value) {
    final tag = value as AccountSymbol?;
    if (widget.autoSave) {
      provider.updateTagAndSave(tag?.code, tag?.name);
    } else {
      provider.updateTag(tag?.code, tag?.name);
    }
  },
),

// 新代码：
...item.tags.map((tag) => Chip(
  avatar: Icon(Icons.local_offer_outlined, size: 16),
  label: Text(tag.name),
  onDeleted: () {
    final newTags = List<AccountSymbol>.from(item.tags)
      ..removeWhere((t) => t.code == tag.code);
    if (widget.autoSave) {
      provider.updateTagsAndSave(newTags);
    } else {
      provider.updateTags(newTags);
    }
  },
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.compact,
)),
ActionChip(
  avatar: Icon(Icons.add, size: 16),
  label: Text(L10nManager.l10n.tag),
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  visualDensity: VisualDensity.compact,
  onPressed: () async {
    final options = provider.tags.cast<AccountSymbol>().map((t) =>
      MultiSelectOption(key: t.code, name: t.name)).toList();
    final selectedIds = item.tags.map((t) => t.code).toList();
    final result = await MultiSelectSheet.show(
      context,
      title: L10nManager.l10n.tag,
      options: options,
      selectedIds: selectedIds,
    );
    if (result != null && context.mounted) {
      final selectedTags = provider.tags.cast<AccountSymbol>()
          .where((t) => result.contains(t.code))
          .toList();
      if (widget.autoSave) {
        provider.updateTagsAndSave(selectedTags);
      } else {
        provider.updateTags(selectedTags);
      }
    }
  },
),
```

- [ ] **Step 2: 同样改造 `item_add_page.dart`（参照上述模式）**

- [ ] **Step 3: 同样改造 `item_edit_page.dart`（参照上述模式）**

- [ ] **Step 4: 提交**

```bash
git add lib/pages/book/modern_item_form.dart lib/pages/book/item_add_page.dart lib/pages/book/item_edit_page.dart
git commit -m "feat: update tag selection UI to multi-select chip + MultiSelectSheet"
```

### Task 14: UI — 多标签展示

**Files:**
- Modify: `lib/widgets/book/item_tile_advance.dart`
- Modify: `lib/widgets/book/item_tile_timeline.dart`
- Modify: `lib/widgets/item_widgets/items_container.dart`

- [ ] **Step 1: 三处文件做同样的展示改造**

```dart
// item_tile_advance.dart lines 163-172:
// 旧:
if (item.tagName != null) ...[
  CommonTag(
    icon: Icons.local_offer_outlined,
    label: item.tagName!,
  ),
]

// 新:
if (item.tags.isNotEmpty) ...[
  for (var i = 0; i < min(3, item.tags.length); i++)
    CommonTag(
      icon: Icons.local_offer_outlined,
      label: item.tags[i].name,
    ),
  if (item.tags.length > 3)
    CommonTag(label: '+${item.tags.length - 3}'),
],
```

同样地，在 `item_tile_timeline.dart`（lines 146-154）和 `items_container.dart`（lines 266-278）做相同替换。

- [ ] **Step 2: 提交**

```bash
git add lib/widgets/book/item_tile_advance.dart lib/widgets/book/item_tile_timeline.dart lib/widgets/item_widgets/items_container.dart
git commit -m "feat: update tag display in item list for multi-tag"
```

### Task 15: 退款/加油等关联场景

**Files:**
- Modify: `lib/pages/book/refund_form_page.dart`
- Modify: `lib/pages/fuel/fuel_record_form_page.dart`

- [ ] **Step 1: 修改 `refund_form_page.dart`**

```dart
// 替换 (line 112):
// tagCode: widget.originalItem.tagCode,
// 为:
tagCodes: widget.originalItem.tags.map((t) => t.code).toList(),
```

- [ ] **Step 2: 修改 `fuel_record_form_page.dart`**

```dart
// 替换 (line 1130):
// preFilledItem.tagCode = lastItem.tagCode;
// 为:
preFilledItem.tags = List.from(lastItem.tags);
```

- [ ] **Step 3: 提交**

```bash
git add lib/pages/book/refund_form_page.dart lib/pages/fuel/fuel_record_form_page.dart
git commit -m "fix: update refund/fuel pages for multi-tag"
```

### Task 16: 代码生成 + 编译验证

- [ ] **Step 1: 运行代码生成**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 2: 检查 lint**

```bash
flutter analyze
```

修复所有报错。

- [ ] **Step 3: 提交代码生成产物**

```bash
git add -A
git commit -m "chore: run codegen for multi-tag support"
```

### Task 17: 完整性检查

- [ ] **检查所有 `tagCode` 旧引用**

```bash
grep -rn '\.tagCode\|\.tagName' lib/ --include='*.dart' | grep -v '\.g\.dart' | grep -v '/generated/'
```

确认没有遗漏的引用（已知允许保留的：`firstTagCode` getter、rule_engine 的 `case 'tagCode'`、`AccountItem.tagCode` 列定义）。

- [ ] **检查所有 `tagCode:` 命名参数**

```bash
grep -rn 'tagCode:' lib/ --include='*.dart' | grep -v '\.g\.dart' | grep -v '/generated/' | grep -v 'firstTagCode'
```

确认 `tagCode:` 只出现在 Driver 接口的旧格式兼容处。

## 验证

1. `flutter analyze` 无错误
2. 升级数据库后既有 `tag_code` 数据正确迁移到 `item_rel_field`
3. 新增账目：选择多个标签 → 保存 → 列表正确展示
4. 编辑账目：增删标签 → 保存 → 重新打开看到正确的标签
5. 标签过滤：按 tag 过滤账目，多标签账目能正确命中
6. 同步回放：旧日志含 `tagCode` 字段不报错
