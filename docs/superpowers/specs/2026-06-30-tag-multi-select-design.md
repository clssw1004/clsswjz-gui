# 记账标签支持多选 — 设计文档

## 概述

将账目（account_item）的标签从**单选**（一个 `tag_code` 字段）改为**多选**，支持一笔账关联多个标签。

## 改动范围总览

```
改动前:  account_item.tag_code (String?) —— 存单个标签 code
改动后:  item_rel_field 表 (item_id, field_code, field_value) —— field_code='TAG' 表示标签

读: 从 item_rel_field 批量加载 → 分组附加到 UserItemVO
写: 通过 ItemCULog 在事务内同时写 item + item_rel_field
```

## 一、数据库层

### 1.1 新增表 `item_rel_field`

路径：`lib/database/tables/item_rel_field_table.dart`

```dart
@DataClassName('ItemRelField')
class ItemRelFieldTable extends BaseTable {
  TextColumn get itemId => text()();
  TextColumn get fieldCode => text()();
  TextColumn get fieldValue => text()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {itemId, fieldCode, fieldValue};
}
```

- 继承 `BaseTable`（含 `id`, `createdAt`, `updatedAt`）
- 联合主键 `(itemId, fieldCode, fieldValue)` 防止重复
- `fieldCode='TAG'` 表示标签，未来可扩展其他类型
- 创建 `toCreateCompanion`、`toJsonString` 等辅助方法

### 1.2 数据库迁移 v17→18

路径：`lib/database/database.dart`

```sql
-- 创建 item_rel_field 表
-- 迁移已有 tag_code 数据
INSERT INTO item_rel_field (id, item_id, field_code, field_value, created_at, updated_at)
SELECT gen_id(), id, 'TAG', tag_code, created_at, updated_at
FROM account_item
WHERE tag_code IS NOT NULL
```

- `account_item.tag_code` 列保留不删（兼容旧日志回放时写入该列）
- schemaVersion 改为 18

### 1.3 新增 DAO

路径：`lib/database/dao/item_rel_field_dao.dart`

```dart
class ItemRelFieldDao extends BaseDao<ItemRelFieldTable, ItemRelField> {
  // 查某个 item 的所有属性字段
  Future<List<ItemRelField>> findByItemId(String itemId);

  // 批量查（VO transfer 用），按 itemId 分组返回 Map
  Future<Map<String, List<ItemRelField>>> findByItemIds(
    List<String> itemIds, {
    String? fieldCode,   // 可选过滤类型
  });

  // 删除某 item 的某类所有字段（update 时全删重建）
  Future<int> deleteByItemAndCode(String itemId, String fieldCode);

  // 插入
  Future<void> insert(ItemRelFieldTableCompanion companion);
}
```

路径：`lib/manager/dao_manager.dart` — 注册 `ItemRelFieldDao`

### 1.4 修改 `AccountItemTable`

路径：`lib/database/tables/account_item_table.dart`

- `toUpdateCompanion`：移除 `tagCode` 参数（不再通过 item 表写标签）
- `toCreateCompanion`：移除 `tagCode` 参数
- `toJsonString`：移除 `tagCode` 序列化
- 列定义保留不动（兼容性）

## 二、模型层

### 2.1 修改 `UserItemVO`

路径：`lib/models/vo/user_item_vo.dart`

变化：
```dart
// 旧
String? tagCode;
String? tagName;

// 新
List<AccountSymbol> tags = [];

// 保留只读兼容 getter（供规则引擎等用到 tagCode 的地方过渡）
String? get firstTagCode => tags.isNotEmpty ? tags.first.code : null;
String? get firstTagName => tags.isNotEmpty ? tags.first.name : null;
```

- `fromAccountItem`：改为接受 `List<AccountSymbol>? tags`，不再从 `item.tagCode` 取
- `toAccountItem`：不再写 `tagCode`
- `copyWith`：`tagCode/tagName` 改为 `List<AccountSymbol>? tags`
- `setTag`：改为 `addTag(AccountSymbol tag)` / `removeTag(String tagCode)`

### 2.2 `ItemFilterDTO` 无需改动

路径：`lib/models/dto/item_filter_dto.dart`

已有 `List<String>? tagCodes`，过滤语义不变。

## 三、VO 数据装配

### 3.1 修改 `VOTansfer`

路径：`lib/drivers/vo_transfer.dart`

现有流程（简化）：
```
SQL 查询 account_item + LEFT JOIN account_symbol（拿 tag_name） → 组装 List<UserItemVO>
```

新流程：
```
1. SQL 查询 account_item（去掉 tag 的 LEFT JOIN） → 得到 List<AccountItem>
2. 收集所有 item.id → 批量查询 item_rel_field（fieldCode='TAG'）
3. 收集所有 tag code → 批量查询 account_symbol（取 name）
4. 组装 Map<String, List<AccountSymbol>> keyed by itemId
5. 创建 UserItemVO 时填入 tags
```

## 四、LogBuilder 层

### 4.1 修改 `ItemCULog`

路径：`lib/drivers/special/log/builder/book_item.builder.dart`

```
LogBuilder<AccountItemTableCompanion, String>
         ↑ 不变，仍以 item companion 为主数据
```

新增字段：
```dart
List<String>? _tagCodes;  // 携带的 tag codes
```

#### executeLog 改动

```dart
Future<String> executeLog() async {
  return DatabaseManager.db.transaction(() async {
    if (operateType == OperateType.create) {
      // 1. 插入 item（companion 不含 tagCode）
      await DaoManager.itemDao.insert(data!);
      target(data!.id.value);
      // 2. 插入标签关联
      if (_tagCodes != null) {
        for (final code in _tagCodes!) {
          await DaoManager.itemRelFieldDao.insert(
            ItemRelFieldTable.toCreateCompanion(
              data!.id.value, fieldCode: 'TAG', fieldValue: code
            )
          );
        }
      }
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      // 1. 更新 item
      await DaoManager.itemDao.update(businessId!, data!);
      // 2. 全删重建标签关联
      await DaoManager.itemRelFieldDao.deleteByItemAndCode(businessId!, 'TAG');
      if (_tagCodes != null) {
        for (final code in _tagCodes!) {
          await DaoManager.itemRelFieldDao.insert(...);
        }
      }
    }
    return businessId!;
  });
}
```

#### data2Json 改动

```dart
String data2Json() {
  final json = data != null ? AccountItemTable.toJsonString(data!) : '{}';
  final map = jsonDecode(json) as Map<String, dynamic>;
  map.remove('tagCode');      // 废弃字段不写入
  if (_tagCodes != null) {
    map['tagCodes'] = _tagCodes;
  }
  return jsonEncode(map);
}
```

#### fromLog 兼容旧日志

```dart
// fromUpdateLog
static ItemCULog fromUpdateLog(LogSync log) {
  Map<String, dynamic> data = jsonDecode(log.operateData);
  // 提取 tag codes（兼容新旧格式）
  List<String>? tagCodes;
  if (data.containsKey('tagCodes')) {
    tagCodes = (data['tagCodes'] as List).cast<String>();     // 新格式
  } else if (data.containsKey('tagCode') && data['tagCode'] != null) {
    tagCodes = [data['tagCode'] as String];                    // 旧格式兼容
  }
  data.remove('tagCode');
  data.remove('tagCodes');
  // 其余字段照常解析
  final builder = ItemCULog.update(...);
  builder._tagCodes = tagCodes;
  return builder;
}

// fromCreateLog
static ItemCULog fromCreateLog(LogSync log) {
  Map<String, dynamic> data = jsonDecode(log.operateData);
  List<String>? tagCodes;
  if (data.containsKey('tagCodes')) {
    tagCodes = (data['tagCodes'] as List).cast<String>();
  } else if (data.containsKey('tagCode') && data['tagCode'] != null) {
    tagCodes = [data['tagCode'] as String];
  }
  data.remove('tagCode');
  data.remove('tagCodes');
  // 用剩余数据重建 companion
  final builder = ItemCULog()
      .who(log.operatorId).inBook(log.parentId).doCreate()
      .withData(AccountItem.fromJson(data).toCompanion(true)) as ItemCULog;
  builder._tagCodes = tagCodes;
  return builder;
}
```

#### `create` / `update` 静态方法签名

```dart
static ItemCULog create(String who, String bookId, {
  ...
  List<String>? tagCodes,    // String? tagCode 改为 List<String>? tagCodes
  ...
});

static ItemCULog update(String who, String bookId, String itemId, {
  ...
  List<String>? tagCodes,    // String? tagCode 改为 List<String>? tagCodes
  ...
});
```

## 五、Driver 层

### 5.1 接口

路径：`lib/drivers/data_driver.dart`

```dart
// 旧
Future<OperateResult<String>> createItem(String userId, String bookId, {
  ..., String? tagCode, ...
});
Future<OperateResult<void>> updateItem(String userId, String bookId, String itemId, {
  ..., String? tagCode, ...
});

// 新
Future<OperateResult<String>> createItem(String userId, String bookId, {
  ..., List<String>? tagCodes, ...
});
Future<OperateResult<void>> updateItem(String userId, String bookId, String itemId, {
  ..., List<String>? tagCodes, ...
});
```

### 5.2 实现

路径：`lib/drivers/special/log.data_driver.dart`

`createItem` / `updateItem`：参数透传，`tagCode` → `tagCodes` 列表传入 `ItemCULog`。

## 六、Provider 层

### 6.1 `ItemFormProvider`

路径：`lib/providers/item_form_provider.dart`

```dart
// 新增状态
List<AccountSymbol> _selectedTags = [];
List<AccountSymbol> get selectedTags => _selectedTags;

// 旧: updateTag(String? code, String? name)
// 新: updateTags(List<AccountSymbol> tags)
void updateTags(List<AccountSymbol> tags) {
  _selectedTags = tags;
  _item = _item.copyWith(
    // tags 字段替换
    tags: tags,
  );
  // _applyRules 的 'tagCode' 改为 'tagCodes'
  _applyRules('tagCodes');
  notifyListeners();
}

// 旧: updateTagAndSave(String? code, String? name)
// 新: updateTagsAndSave(List<AccountSymbol> tags)
Future<void> updateTagsAndSave(List<AccountSymbol> tags) async {
  updateTags(tags);
  // 参数改为 tagCodes 列表
  await partUpdate(tagCodes: tags.map((t) => t.code).toList());
}

// partUpdate 方法内，tagCode 改为 tagCodes
```

### 6.2 规则引擎适配

路径：`lib/services/rule_engine.dart`

现有规则以 `tagCode` 为条件/动作字段：
```dart
// 条件读取（line 322-323）
case 'tagCode':
  return item.tagCode;

// 动作写入（line 349-350）
case 'tagCode':
  item.tagCode = value as String?;
```

修改为：
```dart
// 条件：检查多标签中是否包含某标签
case 'tagCodes':
  return item.tags.map((t) => t.code).join(',');

// 动作：追加/覆盖标签列表（按规则语义决定）
case 'tagCodes':
  // 规则动作设为覆盖：用规则指定标签替换
  final codes = (value as String).split(',').where((s) => s.isNotEmpty);
  // ...
```

> 注意：规则引擎多标签适配可能影响现有规则行为。可在实现时先保持向后兼容——规则条件 `tagCode` 继续工作（检查 `firstTagCode`），规则动作暂不支持写入标签（需要评估使用场景）。

## 七、UI 层

### 7.1 标签选择组件

三处表单统一改造（`modern_item_form.dart`, `item_add_page.dart`, `item_edit_page.dart`）：

```dart
// 改造前：CommonSelectFormField + DisplayMode.badge（单选）
CommonSelectFormField<AccountSymbol>(
  value: item.tagCode,
  displayMode: DisplayMode.badge,
  ...
)

// 改造后：已选标签展示 + 添加按钮 + MultiSelectSheet
Wrap(
  children: [
    // 已选标签
    ...selectedTags.map((tag) => Chip(
      avatar: Icon(Icons.local_offer_outlined, size: 16),
      label: Text(tag.name),
      onDeleted: () => removeTag(tag.code),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    )),
    // 添加按钮
    ActionChip(
      avatar: Icon(Icons.add, size: 16),
      label: Text(L10nManager.l10n.tag),
      onPressed: () async {
        final result = await MultiSelectSheet.show<AccountSymbol>(
          context,
          items: provider.tags.cast<AccountSymbol>(),
          selectedIds: provider.selectedTagCodes,
          displayField: (e) => e.name,
          idField: (e) => e.code,
          searchable: true,
          onCreate: /* 即时创建标签 */,
        );
        if (result != null) {
          provider.updateTags(result);
        }
      },
    ),
  ],
)
```

`MultiSelectSheet` 已是现有组件（用于过滤面板标签选择），直接复用。

### 7.2 标签展示

三处列表标签展示（`item_tile_advance.dart`, `item_tile_timeline.dart`, `items_container.dart`）：

```dart
// 旧
if (item.tagName != null) Text(item.tagName!)

// 新
Wrap(children: [
  for (var i = 0; i < min(3, item.tags.length); i++)
    CommonTag(label: item.tags[i].name),
  if (item.tags.length > 3)
    CommonTag(label: '+${item.tags.length - 3}'),
])
```

### 7.3 退款/加油等关联场景

- `refund_form_page.dart`：`tagCode` → `tagCodes`，传入原始账目的所有标签 codes
- `fuel_record_form_page.dart`：`tagCode` → `tagCodes`，传入上一条的标签 codes

## 八、查询适配

### 8.1 `ItemDao` 过滤

路径：`lib/database/dao/item_dao.dart`

现有过滤 `filter.tagCodes` 直接查 `account_item.tag_code`：

```dart
// 旧
t.tagCode.isIn(filter.tagCodes!)

// 新：通过 item_rel_field 反查 item_id
// 方案 A（推荐）：先查出匹配 tag 的 item_id 列表，再走主查询
final taggedItemIds = await DaoManager.itemRelFieldDao
    .findByFieldCodeAndValues('TAG', filter.tagCodes!);
// 然后主查询追加: t.id.isIn(taggedItemIds)

// 或 方案 B：子查询（如果 Drift 支持）
```

选方案 A 更清晰，对 SQLite 本地库性能影响可忽略。

## 九、文件清单

### 新增文件

| # | 文件 | 说明 |
|---|------|------|
| 1 | `lib/database/tables/item_rel_field_table.dart` | 新表定义 |
| 2 | `lib/database/dao/item_rel_field_dao.dart` | 新 DAO |

### 修改文件

| # | 文件 | 改动程度 |
|---|------|----------|
| 3 | `lib/database/database.dart` | 注册表 + DAO + 迁移 v18 |
| 4 | `lib/manager/dao_manager.dart` | 注册新 DAO |
| 5 | `lib/database/tables/account_item_table.dart` | 移除 companion 中的 tagCode |
| 6 | `lib/models/vo/user_item_vo.dart` | tagCode/tagName → List tags |
| 7 | `lib/drivers/vo_transfer.dart` | 批量加载 tags |
| 8 | `lib/database/dao/item_dao.dart` | 过滤改用 item_rel_field 反查 |
| 9 | `lib/drivers/special/log/builder/book_item.builder.dart` | 核心改动：_tagCodes + executeLog + data2Json + fromLog |
| 10 | `lib/drivers/data_driver.dart` | 接口参数 tagCode → tagCodes |
| 11 | `lib/drivers/special/log.data_driver.dart` | 实现参数透传 |
| 12 | `lib/providers/item_form_provider.dart` | updateTag → updateTags |
| 13 | `lib/services/rule_engine.dart` | 适配 tagCodes |
| 14 | `lib/pages/book/modern_item_form.dart` | UI 多选 |
| 15 | `lib/pages/book/item_add_page.dart` | UI 多选 |
| 16 | `lib/pages/book/item_edit_page.dart` | UI 多选 |
| 17 | `lib/pages/book/refund_form_page.dart` | 传递多标签 |
| 18 | `lib/pages/fuel/fuel_record_form_page.dart` | 传递多标签 |
| 19 | `lib/widgets/book/item_tile_advance.dart` | 展示多标签 |
| 20 | `lib/widgets/book/item_tile_timeline.dart` | 展示多标签 |
| 21 | `lib/widgets/item_widgets/items_container.dart` | 展示多标签 |

### 无需改动

| 文件 | 原因 |
|------|------|
| `lib/models/dto/item_filter_dto.dart` | 已有 `List<String>? tagCodes` |
| `lib/widgets/book/item_filter_sheet.dart` | 已用 `MultiSelectSheet` 多选 |

## 十、注意事项

1. **同步兼容**：旧日志中 `tagCode` 字段会在 `fromLog` 中转为单元素列表，不影响回放
2. **数据库升级**：v17→18 迁移脚本要把现有 `tag_code` 搬入 `item_rel_field`
3. **规则引擎**：现有以 `tagCode` 为条件的规则可能失效，需评估影响
4. **l10n**：可能需要添加"添加标签"等提示文案
5. **代码生成**：修改 `account_item_table.dart` 的 companion 后需运行 `flutter pub run build_runner build` 重新生成 `database.g.dart`

## 十一、验证方法

1. `flutter analyze` 无 lint 错误
2. 升级数据库后既有数据标签正确迁移到 `item_rel_field`
3. 新增账目可选择多个标签，保存后正确展示
4. 编辑已有账目，增删标签后保存正常
5. 按标签过滤仍能正确匹配（多标签同理）
6. 同步回放旧日志（含 `tagCode` 字段）不报错
7. 退款/加油功能传递多标签正常
