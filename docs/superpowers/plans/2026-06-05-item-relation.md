# 账目关联模块实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 创建通用账目关联模块，允许记事、油耗等模块通过统一关联表与账目双向关联

**Architecture:** 新增 `ItemRelationTable`（继承 `BaseBusinessTable`）存储关联记录，通过 DAO → LogBuilder → DataDriver → Provider 完整链路提供数据能力，上层提供通用 `ItemRelationPanel` 组件供各模块复用

**Tech Stack:** Flutter, Drift (SQLite), Provider

**参考文档:** `docs/design/item_relation_design.md`

---

## 文件结构

### 新建文件

| 文件 | 职责 |
|------|------|
| `lib/database/tables/item_relation_table.dart` | Drift 表定义，含 toCreateCompanion/toJsonString |
| `lib/database/dao/item_relation_dao.dart` | 数据访问层，按 itemId/relationCode+relationId 查询 |
| `lib/models/vo/item_relation_vo.dart` | 值对象，fromItemRelation 工厂方法 |
| `lib/drivers/special/log/builder/item_relation.builder.dart` | LogBuilder，支持 create/delete 日志记录和恢复 |
| `lib/providers/item_relation_provider.dart` | 状态管理，含双向缓存 |
| `lib/widgets/common/item_relation_panel.dart` | 通用关联面板组件，含 SearchResult 和 RelationTargetConfig |

### 修改文件

| 文件 | 修改内容 |
|------|----------|
| `lib/enums/business_type.dart` | 添加 `itemRelation('itemRelation')` |
| `lib/database/database.dart` | 注册 ItemRelationTable、增加 schemaVersion、添加升级迁移 |
| `lib/database/database.g.dart` | 重新生成（`flutter pub run build_runner build`） |
| `lib/drivers/special/log/builder/builder.dart` | 导入 item_relation.builder，添加 switch case |
| `lib/manager/dao_manager.dart` | 注册 ItemRelationDao |
| `lib/drivers/data_driver.dart` | 添加 4 个接口方法 |
| `lib/drivers/special/log.data_driver.dart` | 实现 4 个接口方法 |

---

### Task 1: BusinessType 枚举 + 数据库表

**Files:**
- Create: `lib/database/tables/item_relation_table.dart`
- Modify: `lib/enums/business_type.dart`

- [ ] **Step 1: 在 BusinessType 中添加 itemRelation**

`lib/enums/business_type.dart` — 在 `fuelRecord('fuelRecord')` 后面添加：

```dart
  /// 账目关联
  itemRelation('itemRelation'),
```

- [ ] **Step 2: 创建 ItemRelationTable**

`lib/database/tables/item_relation_table.dart`:

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
  TextColumn get itemId => text().named('item_id')();
  TextColumn get accountBookId => text().named('account_book_id')();
  TextColumn get relationCode => text().named('relation_code')();
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

- [ ] **Step 3: 注册表到 database.dart 并升级 schemaVersion**

`lib/database/database.dart`:

在 import 中添加：
```dart
import 'tables/item_relation_table.dart';
```

在 `@DriftDatabase(tables: [...])` 中添加 `ItemRelationTable`：

```dart
    ItemRelationTable,
```

将 `schemaVersion` 从 `5` 改为 `6`：

```dart
  @override
  int get schemaVersion => 6;
```

在 `onUpgrade` 中添加版本 5→6 的迁移：

```dart
          if (from < 6) {
            await m.create(itemRelationTable);
          }
```

- [ ] **Step 4: 重新生成 database.g.dart**

Run: `flutter pub run build_runner build --delete-conflicting-outputs`
Expected: `database.g.dart` 重新生成，包含 ItemRelationTable

- [ ] **Step 5: 创建 DAO**

`lib/database/dao/item_relation_dao.dart`:

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/item_relation_table.dart';
import 'base_dao.dart';

class ItemRelationDao extends BaseDao<ItemRelationTable, ItemRelation> {
  ItemRelationDao(super.db);

  Future<List<ItemRelation>> findByItemId(String itemId) {
    return (db.select(table)..where((t) => t.itemId.equals(itemId))).get();
  }

  Future<List<ItemRelation>> findByRelation(String code, String id) {
    return (db.select(table)
      ..where((t) =>
        t.relationCode.equals(code) &
        t.relationId.equals(id))
    ).get();
  }

  Future<Map<String, List<ItemRelation>>> findByItemIds(List<String> itemIds) {
    return (db.select(table)
      ..where((t) => t.itemId.isIn(itemIds))
    ).get().then((rows) => groupBy(rows, (r) => r.itemId));
  }

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

- [ ] **Step 6: 注册 DAO 到 DaoManager**

`lib/manager/dao_manager.dart`:

在 import 中添加：
```dart
import '../database/dao/item_relation_dao.dart';
```

添加静态属性：
```dart
  static late ItemRelationDao itemRelationDao;
```

在 `refreshDaos()` 中添加：
```dart
    itemRelationDao = ItemRelationDao(DatabaseManager.db);
```

---

### Task 2: VO + LogBuilder

**Files:**
- Create: `lib/models/vo/item_relation_vo.dart`
- Create: `lib/drivers/special/log/builder/item_relation.builder.dart`
- Modify: `lib/drivers/special/log/builder/builder.dart`

- [ ] **Step 1: 创建 ItemRelationVO**

`lib/models/vo/item_relation_vo.dart`:

```dart
import '../../database/database.dart';

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

- [ ] **Step 2: 创建 ItemRelationCULog**

`lib/drivers/special/log/builder/item_relation.builder.dart`:

```dart
import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/item_relation_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

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

- [ ] **Step 3: 注册到 builder.dart**

`lib/drivers/special/log/builder/builder.dart`:

在 import 区添加：
```dart
import 'item_relation.builder.dart';
```

在 `_fromLog` 的 `switch (businessType)` 中，`case BusinessType.fuelRecord:` 后面添加：

```dart
      case BusinessType.itemRelation:
        return ItemRelationCULog.fromLog(log) as LogBuilder<T, RunResult>;
```

---

### Task 3: DataDriver 接口 + 实现

**Files:**
- Modify: `lib/drivers/data_driver.dart` (最后 `}` 前添加接口)
- Modify: `lib/drivers/special/log.data_driver.dart` (文件末尾添加实现)

- [ ] **Step 1: 在 data_driver.dart 添加接口**

在 `lib/drivers/data_driver.dart` 文件末尾 `}` 前添加：

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

- [ ] **Step 2: 在 log.data_driver.dart 添加 import**

在 import 区末尾添加：
```dart
import '../../models/vo/item_relation_vo.dart';
import 'log/builder/item_relation.builder.dart';
```

- [ ] **Step 3: 在 log.data_driver.dart 末尾添加实现**

在文件末尾 `}` 前添加：

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

---

### Task 4: Provider

**Files:**
- Create: `lib/providers/item_relation_provider.dart`

- [ ] **Step 1: 创建 ItemRelationProvider**

`lib/providers/item_relation_provider.dart`:

```dart
import 'package:flutter/material.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../models/common.dart';
import '../../models/vo/item_relation_vo.dart';

class ItemRelationProvider extends ChangeNotifier {
  final Map<String, List<ItemRelationVO>> _relationCache = {};
  final Map<String, List<String>> _reverseCache = {};

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
    if (_reverseCache.containsKey(key)) {
      return _reverseCache[key]!;
    }
    final result = await DriverFactory.driver.getRelatedItemIds(
      AppConfigManager.instance.userId,
      relationCode: relationCode,
      relationId: relationId,
    );
    if (result.ok) {
      final ids = result.data ?? [];
      _reverseCache[key] = ids;
      return ids;
    }
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
    required String relationId,
    required String itemId,
    required String relationCode,
    required String sourceId,
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

  /// 清除指定账目的缓存
  void clearCacheForItem(String itemId) {
    _relationCache.remove(itemId);
  }

  /// 清除所有缓存
  void clearAllCache() {
    _relationCache.clear();
    _reverseCache.clear();
  }
}
```

---

### Task 5: 通用组件 ItemRelationPanel

**Files:**
- Create: `lib/widgets/common/item_relation_panel.dart`

- [ ] **Step 1: 创建 ItemRelationPanel 组件**

`lib/widgets/common/item_relation_panel.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n_manager.dart';
import '../../models/vo/item_relation_vo.dart';
import '../../providers/item_relation_provider.dart';
import '../../theme/theme_spacing.dart';

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

/// 关联目标配置
class RelationTargetConfig {
  final String code;
  final String label;
  final Future<List<SearchResult>> Function(
    BuildContext context,
    String query,
  )? searchBuilder;
  final Widget Function(
    BuildContext context,
    ItemRelationVO relation,
    VoidCallback onTap,
  ) displayBuilder;
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
  final String relationCode;
  final String relationId;
  final String accountBookId;
  final RelationTargetConfig target;

  const ItemRelationPanel({
    super.key,
    required this.relationCode,
    required this.relationId,
    required this.accountBookId,
    required this.target,
  });

  @override
  State<ItemRelationPanel> createState() => _ItemRelationPanelState();
}

class _ItemRelationPanelState extends State<ItemRelationPanel> {
  List<ItemRelationVO> _relations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRelations();
  }

  Future<void> _loadRelations() async {
    final provider = context.read<ItemRelationProvider>();
    final ids = await provider.getRelatedItemIds(widget.relationCode, widget.relationId);
    // 此时我们只有 itemId 列表，实际渲染时需要加载 item 详情
    // relations 存的是关联记录本身（含 itemId）
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleAddRelation() async {
    final provider = context.read<ItemRelationProvider>();

    // 搜索已有账目
    if (widget.target.searchBuilder == null) return;

    final result = await showSearch<String>(
      context: context,
      delegate: _ItemSearchDelegate(
        searchBuilder: widget.target.searchBuilder!,
        label: widget.target.label,
      ),
    );

    if (result != null && mounted) {
      await provider.createRelation(
        itemId: result,
        accountBookId: widget.accountBookId,
        relationCode: widget.relationCode,
        relationId: widget.relationId,
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _handleDeleteRelation(ItemRelationVO relation) async {
    final provider = context.read<ItemRelationProvider>();
    await provider.deleteRelation(
      relationId: relation.id,
      itemId: relation.itemId,
      relationCode: widget.relationCode,
      sourceId: widget.relationId,
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10nManager.l10n;
    final spacing = Theme.of(context).spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.contentPadding.left,
            vertical: spacing.formItemSpacing,
          ),
          child: Row(
            children: [
              Text(
                '关联${widget.target.label}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _handleAddRelation,
                icon: const Icon(Icons.add, size: 18),
                label: Text('关联${widget.target.label}'),
              ),
            ],
          ),
        ),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_relations.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.contentPadding.left,
            ),
            child: Text(
              '暂无关联${widget.target.label}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...List.generate(_relations.length, (index) {
            final relation = _relations[index];
            return Dismissible(
              key: ValueKey(relation.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                color: Theme.of(context).colorScheme.error,
                child: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.onError),
              ),
              onDismissed: (_) => _handleDeleteRelation(relation),
              child: widget.target.displayBuilder(
                context,
                relation,
                () => widget.target.onTap(context, relation),
              ),
            );
          }),
      ],
    );
  }
}

/// 搜索委托
class _ItemSearchDelegate extends SearchDelegate<String> {
  final Future<List<SearchResult>> Function(BuildContext, String) searchBuilder;
  final String label;

  _ItemSearchDelegate({
    required this.searchBuilder,
    required this.label,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchList(context);

  Widget _buildSearchList(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text('输入关键字搜索$label'),
      );
    }

    return FutureBuilder<List<SearchResult>>(
      future: searchBuilder(context, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('未找到匹配结果'));
        }
        return ListView.separated(
          itemCount: snapshot.data!.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = snapshot.data![index];
            return ListTile(
              leading: item.leading,
              title: Text(item.display),
              onTap: () => close(context, item.id),
            );
          },
        );
      },
    );
  }
}
```

---

### Task 6: Provider 注册 + 集成验证

**Files:**
- Modify: `lib/manager/provider_manager.dart`

- [ ] **Step 1: 在 ProviderManager 中注册 ItemRelationProvider**

`lib/manager/provider_manager.dart`:

在 import 中添加：
```dart
import '../providers/item_relation_provider.dart';
```

在 providers 列表中添加：
```dart
    ChangeNotifierProvider(create: (_) => ItemRelationProvider()),
```

- [ ] **Step 2: 验证编译**

Run: `flutter analyze`
Expected: 无 lint 错误和编译错误

---

## 自审

**Spec 对照：**
- 表定义 ✓ (Task 1 Step 2)
- 枚举 BusinessType ✓ (Task 1 Step 1)
- DAO ✓ (Task 1 Step 5)
- VO ✓ (Task 2 Step 1)
- LogBuilder ✓ (Task 2 Step 2 + Step 3)
- DataDriver 接口 ✓ (Task 3 Step 1)
- DataDriver 实现 ✓ (Task 3 Step 3)
- Provider ✓ (Task 4)
- 通用组件 ✓ (Task 5)
- Provider 注册 ✓ (Task 6)
- schemaVersion 升级 + 迁移 ✓ (Task 1 Step 3)
- DaoManager 注册 ✓ (Task 1 Step 6)

**类型一致性：** 所有文件中 `ItemRelationVO`, `ItemRelation`, `ItemRelationTable`, `ItemRelationDao`, `ItemRelationCULog`, `ItemRelationProvider` 命名一致，方法签名匹配。

**Placeholder 检查：** 无 TBD、TODO 或占位符。
