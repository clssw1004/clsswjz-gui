# 账目关联模块设计文档

## 一、需求概述

账目关联模块用于将其他业务模块（记事、油耗等）与账目进行关联，支持双向查询展示，并以通用组件形式提供给各模块使用，便于后期扩展。

### 核心概念

- **账目（Item）**：核心关联锚点，所有关联都以账目为中心
- **关联记录（ItemRelation）**：一条关联记录 = 账目 + 业务模块记录
- **关联码（relationCode）**：标识业务模块类型，如 `note`、`fuel` 等
- **关联ID（relationId）**：业务模块记录的ID

## 二、关联规则

| 维度 | 规则 |
|------|------|
| 方向 | 双向 — 模块侧可关联账目，账目侧可展示关联 |
| 基数 | 多对多 — 一条记录可关联多笔账目，一笔账目可被多条记录关联 |
| 作用域 | 同一账本内 |
| 类型区分 | 通过 `relationCode` 字段区分来源模块，新增模块无需改表 |

## 三、数据库设计

### 3.1 表定义

文件：`lib/database/tables/item_relation_table.dart`

```dart
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('ItemRelation')
class ItemRelationTable extends BaseBusinessTable {
  /// 账目ID
  TextColumn get itemId => text().named('item_id')();

  /// 账本ID
  TextColumn get accountBookId => text().named('account_book_id')();

  /// 关联业务类型码（如: note, fuel）
  TextColumn get relationCode => text().named('relation_code')();

  /// 关联业务ID
  TextColumn get relationId => text().named('relation_id')();

  static ItemRelationTableCompanion toCreateCompanion(
    String who, {
    required String itemId,
    required String accountBookId,
    required String relationCode,
    required String relationId,
  }) {
    return ItemRelationTableCompanion(
      id: Value(IdUtil.genId()),
      itemId: Value(itemId),
      accountBookId: Value(accountBookId),
      relationCode: Value(relationCode),
      relationId: Value(relationId),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  static String toJsonString(ItemRelationTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'itemId', companion.itemId);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'relationCode', companion.relationCode);
    MapUtil.setIfPresent(map, 'relationId', companion.relationId);
    return jsonEncode(map);
  }
}
```

### 3.2 DAO

文件：`lib/database/dao/item_relation_dao.dart`

```dart
class ItemRelationDao extends BaseDao<ItemRelationTable, ItemRelation> {
  ItemRelationDao(super.db);

  /// 按账目ID查询所有关联
  Future<List<ItemRelation>> findByItemId(String itemId) {
    return (db.select(table)..where((t) => t.itemId.equals(itemId))).get();
  }

  /// 按关联业务查询（如查某条记事关联了哪些账目）
  Future<List<ItemRelation>> findByRelation(String code, String id) {
    return (db.select(table)
      ..where((t) =>
        t.relationCode.equals(code) &
        t.relationId.equals(id))
    ).get();
  }

  /// 批量按账目ID查询（用于列表页批量判断）
  Future<Map<String, List<ItemRelation>>> findByItemIds(List<String> itemIds) {
    final rows = await (db.select(table)
      ..where((t) => t.itemId.isIn(itemIds))
    ).get();
    return groupBy(rows, (r) => r.itemId);
  }

  /// 删除指定账目的某条关联
  Future<int> deleteByItemAndRelation(String itemId, String relationCode, String relationId) {
    return (db.delete(table)
      ..where((t) =>
        t.itemId.equals(itemId) &
        t.relationCode.equals(relationCode) &
        t.relationId.equals(relationId))
    ).go();
  }

  @override
  TableInfo<ItemRelationTable, ItemRelation> get table => db.itemRelationTable;
}
```

### 3.3 数据库注册

文件：`lib/database/database.dart`

```dart
// 添加属性
ItemRelationTable get itemRelationTable => ItemRelationTable();

// 在 _$AppDatabase 中添加
@ConstructedBy(ItemRelationDaoConstructors)
ItemRelationDao get itemRelationDao;
```

## 四、值对象

文件：`lib/models/vo/item_relation_vo.dart`

```dart
class ItemRelationVO {
  final String id;
  final String itemId;
  final String accountBookId;
  final String relationCode;
  final String relationId;
  final int createdAt;
  final String createdBy;

  const ItemRelationVO({
    required this.id,
    required this.itemId,
    required this.accountBookId,
    required this.relationCode,
    required this.relationId,
    required this.createdAt,
    required this.createdBy,
  });

  factory ItemRelationVO.fromItemRelation(ItemRelation rel) {
    return ItemRelationVO(
      id: rel.id,
      itemId: rel.itemId,
      accountBookId: rel.accountBookId,
      relationCode: rel.relationCode,
      relationId: rel.relationId,
      createdAt: rel.createdAt,
      createdBy: rel.createdBy,
    );
  }
}
```

## 五、枚举

### 5.1 BusinessType 新增

文件：`lib/enums/business_type.dart`

```dart
/// 账目关联
itemRelation('itemRelation'),
```

## 六、LogBuilder

文件：`lib/drivers/special/log/builder/item_relation.builder.dart`

```dart
class ItemRelationCULog extends LogBuilder<ItemRelationTableCompanion, String> {
  ItemRelationCULog() : super() {
    doWith(BusinessType.itemRelation);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.itemRelationDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.delete) {
      await DaoManager.itemRelationDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return ItemRelationTable.toJsonString(data as ItemRelationTableCompanion);
  }

  static ItemRelationCULog create(String who, {
    required String itemId,
    required String accountBookId,
    required String relationCode,
    required String relationId,
  }) {
    return ItemRelationCULog()
        .who(who)
        .inBook(accountBookId)
        .doCreate()
        .withData(ItemRelationTable.toCreateCompanion(
          who,
          itemId: itemId,
          accountBookId: accountBookId,
          relationCode: relationCode,
          relationId: relationId,
        )) as ItemRelationCULog;
  }

  static ItemRelationCULog delete(String who, String relationId) {
    return ItemRelationCULog()
        .who(who)
        .target(relationId)
        .doDelete() as ItemRelationCULog;
  }

  /// 从创建日志恢复
  static ItemRelationCULog fromCreateLog(LogSync log) {
    final data = jsonDecode(log.operateData);
    return ItemRelationCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(data)) as ItemRelationCULog;
  }

  static ItemRelationCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => ItemRelationCULog.fromCreateLog(log),
      _ => ItemRelationCULog()
          .who(log.operatorId)
          .target(log.businessId)
          .doDelete() as ItemRelationCULog,
    };
  }

  static ItemRelationTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return ItemRelationTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      itemId: json['itemId'] != null ? Value(json['itemId'] as String) : const Value.absent(),
      accountBookId: json['accountBookId'] != null ? Value(json['accountBookId'] as String) : const Value.absent(),
      relationCode: json['relationCode'] != null ? Value(json['relationCode'] as String) : const Value.absent(),
      relationId: json['relationId'] != null ? Value(json['relationId'] as String) : const Value.absent(),
    );
  }
}
```

注册到 `builder.dart`：

```dart
import 'item_relation.builder.dart';

// 在 _fromLog 中添加 case
case BusinessType.itemRelation:
  return ItemRelationCULog.fromLog(log) as LogBuilder<T, RunResult>;
```

## 七、DataDriver 接口

文件：`lib/drivers/data_driver.dart`

```dart
/// ==================== 账目关联 ====================

/// 创建关联
Future<OperateResult<void>> createItemRelation(String userId, {
  required String itemId,
  required String accountBookId,
  required String relationCode,
  required String relationId,
});

/// 删除关联
Future<OperateResult<void>> deleteItemRelation(String userId, String relationId);

/// 按关联业务查询关联的账目ID列表
Future<OperateResult<List<String>>> getRelatedItemIds(String userId, {
  required String relationCode,
  required String relationId,
});

/// 按账目ID查询关联记录
Future<OperateResult<List<ItemRelationVO>>> getItemRelations(String userId, {
  required String itemId,
});
```

## 八、DataDriver 实现

文件：`lib/drivers/special/log.data_driver.dart`

```dart
@override
Future<OperateResult<void>> createItemRelation(String userId, {
  required String itemId,
  required String accountBookId,
  required String relationCode,
  required String relationId,
}) async {
  try {
    await ItemRelationCULog.create(
      userId,
      itemId: itemId,
      accountBookId: accountBookId,
      relationCode: relationCode,
      relationId: relationId,
    ).execute();
    return OperateResult.success(null);
  } catch (e) {
    return OperateResult.failWithMessage(
      message: '创建关联失败：$e',
      exception: e as Exception,
    );
  }
}

@override
Future<OperateResult<void>> deleteItemRelation(String userId, String relationId) async {
  try {
    await ItemRelationCULog.delete(userId, relationId).execute();
    return OperateResult.success(null);
  } catch (e) {
    return OperateResult.failWithMessage(
      message: '删除关联失败：$e',
      exception: e as Exception,
    );
  }
}

@override
Future<OperateResult<List<String>>> getRelatedItemIds(String userId, {
  required String relationCode,
  required String relationId,
}) async {
  try {
    final relations = await DaoManager.itemRelationDao.findByRelation(relationCode, relationId);
    final ids = relations.map((r) => r.itemId).toList();
    return OperateResult.success(ids);
  } catch (e) {
    return OperateResult.failWithMessage(
      message: '查询关联账目失败：$e',
      exception: e as Exception,
    );
  }
}

@override
Future<OperateResult<List<ItemRelationVO>>> getItemRelations(String userId, {
  required String itemId,
}) async {
  try {
    final relations = await DaoManager.itemRelationDao.findByItemId(itemId);
    final vos = relations.map((r) => ItemRelationVO.fromItemRelation(r)).toList();
    return OperateResult.success(vos);
  } catch (e) {
    return OperateResult.failWithMessage(
      message: '查询账目关联失败：$e',
      exception: e as Exception,
    );
  }
}
```

## 九、Provider

文件：`lib/providers/item_relation_provider.dart`

```dart
class ItemRelationProvider extends ChangeNotifier {
  /// 缓存：itemId → 关联列表
  final Map<String, List<ItemRelationVO>> _relationCache = {};
  /// 缓存：relationCode+relationId → 关联列表
  final Map<String, List<ItemRelationVO>> _reverseCache = {};

  String _cacheKey(String code, String id) => '$code:$id';

  /// 查询某笔账目的所有关联
  Future<List<ItemRelationVO>> getItemRelations(String itemId) async {
    if (_relationCache.containsKey(itemId)) {
      return _relationCache[itemId]!;
    }
    final result = await DriverFactory.driver.getItemRelations(
      AppConfigManager.instance.userId,
      itemId: itemId,
    );
    if (result.ok) {
      _relationCache[itemId] = result.data ?? [];
      return _relationCache[itemId]!;
    }
    return [];
  }

  /// 查询某业务记录关联的账目ID列表
  Future<List<String>> getRelatedItemIds(
    String relationCode,
    String relationId,
  ) async {
    final key = _cacheKey(relationCode, relationId);
    // 未缓存则查询
    final result = await DriverFactory.driver.getRelatedItemIds(
      AppConfigManager.instance.userId,
      relationCode: relationCode,
      relationId: relationId,
    );
    if (result.ok) return result.data ?? [];
    return [];
  }

  /// 创建关联
  Future<OperateResult<void>> createRelation({
    required String itemId,
    required String accountBookId,
    required String relationCode,
    required String relationId,
  }) async {
    final result = await DriverFactory.driver.createItemRelation(
      AppConfigManager.instance.userId,
      itemId: itemId,
      accountBookId: accountBookId,
      relationCode: relationCode,
      relationId: relationId,
    );
    if (result.ok) {
      _relationCache.remove(itemId);
      _reverseCache.remove(_cacheKey(relationCode, relationId));
      notifyListeners();
    }
    return result;
  }

  /// 删除关联
  Future<OperateResult<void>> deleteRelation({
    required String relationId,     // 关联记录ID
    required String itemId,         // 账目ID（清缓存用）
    required String relationCode,   // 业务类型码（清缓存用）
    required String sourceId,       // 业务记录ID（清缓存用）
  }) async {
    final result = await DriverFactory.driver.deleteItemRelation(
      AppConfigManager.instance.userId,
      relationId,
    );
    if (result.ok) {
      _relationCache.remove(itemId);
      _reverseCache.remove(_cacheKey(relationCode, sourceId));
      notifyListeners();
    }
    return result;
  }
}
```

## 十、通用组件

文件：`lib/widgets/common/item_relation_panel.dart`

### 10.1 接口设计

```dart
/// 搜索结果项
class SearchResult {
  final String id;
  final String display;
  final Widget? leading;

  const SearchResult({
    required this.id,
    required this.display,
    this.leading,
  });
}
```

```dart
/// 关联目标配置
class RelationTargetConfig {
  final String code;               // 业务类型码
  final String label;              // 显示标签

  /// 搜索已有数据的构建器
  final Future<List<SearchResult>> Function(
    BuildContext context,
    String query,
  )? searchBuilder;

  /// 已关联条目的展示构建器
  final Widget Function(
    BuildContext context,
    ItemRelationVO relation,
    VoidCallback onTap,
  ) displayBuilder;

  /// 点击已关联条目时的跳转
  final void Function(BuildContext context, ItemRelationVO relation) onTap;

  const RelationTargetConfig({
    required this.code,
    required this.label,
    this.searchBuilder,
    required this.displayBuilder,
    required this.onTap,
  });
}

/// 通用关联面板
class ItemRelationPanel extends StatefulWidget {
  /// 当前模块业务类型码
  final String relationCode;

  /// 当前模块记录ID
  final String relationId;

  /// 账本ID
  final String accountBookId;

  /// 可关联的目标配置
  final RelationTargetConfig target;

  const ItemRelationPanel({
    super.key,
    required this.relationCode,
    required this.relationId,
    required this.accountBookId,
    required this.target,
  });
}
```

### 10.2 组件行为

1. **初始化**：根据 `relationCode + relationId` 查询已关联账目列表
2. **展示**：渲染已关联账目列表（使用 target.displayBuilder）
3. **新增**：提供「+ 关联账目」按钮
   - 弹搜索框 → 调 `target.searchBuilder` 搜索账目
   - 点击选中 → 调 Provider.createRelation 创建关联
4. **删除**：关联条目支持滑动删除或长按删除
5. **跳转**：点击已关联条目 → target.onTap

### 10.3 使用示例

记事模块：

```dart
ItemRelationPanel(
  relationCode: 'note',
  relationId: note.id,
  accountBookId: book.id,
  target: RelationTargetConfig(
    code: 'item',
    label: '账目',
    searchBuilder: (context, query) async {
      // 搜索当前账本内的账目
      final result = await DriverFactory.driver.listItems(/* ... */);
      return result.data?.map((item) => SearchResult(
        id: item.id,
        display: '¥${item.amount}  ${item.description ?? ''}',
      )).toList() ?? [];
    },
    displayBuilder: (context, relation, onTap) => ListTile(
      title: Text('¥${relation.amount}'),
      subtitle: Text(relation.description ?? ''),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    ),
    onTap: (context, relation) {
      Navigator.pushNamed(context, AppRoutes.itemEdit, arguments: [relation.itemId, book]);
    },
  ),
)
```

油耗模块：

```dart
ItemRelationPanel(
  relationCode: 'fuel',
  relationId: fuelRecord.id,
  accountBookId: book.id,
  target: RelationTargetConfig(
    code: 'item',
    label: '账目',
    // searchBuilder / displayBuilder / onTap 同上
  ),
)
```

## 十一、账目详情关联展示

在账目编辑页（或新建的详情页）中，使用 `ItemRelationProvider` 查询并展示：

```dart
final relations = await context.read<ItemRelationProvider>().getItemRelations(item.id);
// 按 relationCode 分组显示
// note → 可点击跳转到记事详情
// fuel → 可点击跳转到油耗详情
```

## 十二、文件清单

| 层级 | 文件路径 | 操作 |
|------|----------|------|
| 表 | `lib/database/tables/item_relation_table.dart` | 新建 |
| DAO | `lib/database/dao/item_relation_dao.dart` | 新建 |
| 数据库 | `lib/database/database.dart` | 修改 — 注册表+DAO |
| 模型 | `lib/models/vo/item_relation_vo.dart` | 新建 |
| 枚举 | `lib/enums/business_type.dart` | 修改 — 添加 `itemRelation` |
| Builder | `lib/drivers/special/log/builder/item_relation.builder.dart` | 新建 |
| Builder | `lib/drivers/special/log/builder/builder.dart` | 修改 — 注册 case |
| 接口 | `lib/drivers/data_driver.dart` | 修改 — 添加接口 |
| 实现 | `lib/drivers/special/log.data_driver.dart` | 修改 — 实现接口 |
| Provider | `lib/providers/item_relation_provider.dart` | 新建 |
| DAO管理 | `lib/manager/dao_manager.dart` | 修改 — 注册 DAO |
| 组件 | `lib/widgets/common/item_relation_panel.dart` | 新建 |

## 十三、扩展性说明

未来新增模块（如"礼物卡"）关联账目时：

1. 确定 `relationCode`（如 `giftCard`）
2. 在对应模块页使用 `ItemRelationPanel(relationCode: 'giftCard', ...)`
3. 在账目详情中按 `relationCode` 分组展示即可

无需改表、无需新增 DAO、无需新增 Service 接口。
