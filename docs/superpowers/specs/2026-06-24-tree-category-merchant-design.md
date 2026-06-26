# 分类/商户树形结构设计文档

## 一、概述

### 1.1 目标

为现有分类（Category）和商户（Shop）模块引入树形层级结构，满足多层分类（如餐饮→饮品→咖啡）和商户层级（如美团→肯德基）的实际记账场景。

### 1.2 范围

- 分类（`AccountCategory`）—— 支持树形，最大深度 5 层
- 商户（`AccountShop`）—— 支持树形，最大深度 5 层
- 已有数据自动变为根节点（parentId = null）
- 所有层级节点都可选作为记账条目引用

### 1.3 非目标

- 不创建统一树表，各模块独立加树形字段
- 不涉及标签/项目等其他模块的树形化
- 不修改底层同步机制

## 二、数据库层

### 2.1 字段变更

#### AccountCategoryTable

| 字段 | 类型 | 说明 |
|------|------|------|
| `parentId` | `TEXT?` | 父节点 ID，null=根节点 |
| `sortOrder` | `INTEGER` | 同级排序，默认 0 |

#### AccountShopTable

| 字段 | 类型 | 说明 |
|------|------|------|
| `parentId` | `TEXT?` | 父节点 ID，null=根节点 |
| `sortOrder` | `INTEGER` | 同级排序，默认 0 |

#### 约束调整

- 分类原唯一约束 `(name, accountBookId, categoryType)` —— 保留（名称全局唯一）
- 商户新增唯一约束 `(name, accountBookId)` —— 树形结构下名称仍需唯一

### 2.2 表定义示例

```dart
// AccountCategoryTable 新增字段
TextColumn? parentId;
IntColumn get sortOrder => integer().withDefault(const Constant(0))();

static AccountCategoryTableCompanion toCreateCompanion(String who, {
  required String name,
  required String categoryType,
  String? parentId,
  int sortOrder = 0,
}) {
  return AccountCategoryTableCompanion(
    id: Value(IdUtil.genId()),
    name: Value(name),
    code: Value(IdUtil.genNanoId8()),
    categoryType: Value(categoryType),
    parentId: Value.absentIfNull(parentId),
    sortOrder: Value(sortOrder),
    createdBy: Value(who),
    createdAt: Value(DateUtil.now()),
    updatedBy: Value(who),
    updatedAt: Value(DateUtil.now()),
  );
}

static AccountCategoryTableCompanion toUpdateCompanion(String who, {
  String? name,
  String? categoryType,
  String? parentId,
  int? sortOrder,
  String? lastAccountItemAt,
}) {
  return AccountCategoryTableCompanion(
    updatedBy: Value(who),
    updatedAt: Value(DateUtil.now()),
    name: Value.absentIfNull(name),
    categoryType: Value.absentIfNull(categoryType),
    parentId: Value.absentIfNull(parentId),
    sortOrder: Value.absentIfNull(sortOrder),
    lastAccountItemAt: Value.absentIfNull(lastAccountItemAt),
  );
}
```

## 三、DAO 层

### 3.1 新增树形查询方法

```dart
// === category_dao.dart ===

/// 一次性加载账本下全量分类（含排序），用于构建树
Future<List<AccountCategory>> listAllByBook(String bookId, {String? categoryType}) {
  return (db.select(table)
    ..where((t) => t.accountBookId.equals(bookId))
    ..whereIf(categoryType != null, (t) => t.categoryType.equals(categoryType!))
    ..orderBy([
      (t) => OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc),
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ])
  ).get();
}

/// 查直接子节点
Future<List<AccountCategory>> findChildren(String parentId) {
  return (db.select(table)
    ..where((t) => t.parentId.equals(parentId))
    ..orderBy([
      (t) => OrderingTerm(expression: t.sortOrder, mode: OrderingMode.asc),
    ])
  ).get();
}

/// 查某父节点下最大 sortOrder
Future<int> getMaxSortOrder(String? parentId, String bookId) {
  return (db.select(table)
    ..where((t) => t.accountBookId.equals(bookId))
    ..whereIf(parentId != null, (t) => t.parentId.equals(parentId!))
    ..whereIf(parentId == null, (t) => t.parentId.isNull())
  ).map((row) => row.sortOrder)
   .get()
   .then((orders) => orders.isEmpty ? 0 : orders.reduce(max));
}

// === shop_dao.dart === 同理
```

DAO 的 `update` 方法继承自 `BaseDao`，已经支持全字段更新，无需额外方法。

## 四、业务类型枚举

### 4.1 OperateType 新增批量类型

```dart
enum OperateType {
  create('CREATE'),
  update('UPDATE'),
  delete('DELETE'),
  updateBatch('UPDATE_BATCH'),    // 新增
  deleteBatch('DELETE_BATCH');    // 新增
}
```

## 五、LogBuilder 层

### 5.1 LogBuilder 基类改动（builder.dart）

```dart
// 新增批量字段
List<String>? _batchIds;
List<dynamic>? _batchData;  // List<TableCompanion> 或 List<Map>

LogBuilder<T, RunResult> doUpdateBatch() {
  operateType = OperateType.updateBatch;
  return this;
}

LogBuilder<T, RunResult> doDeleteBatch() {
  operateType = OperateType.deleteBatch;
  return this;
}

LogBuilder<T, RunResult> withBatchIds(List<String> ids) {
  _batchIds = ids;
  return this;
}

LogBuilder<T, RunResult> withBatchData(List<dynamic> data) {
  _batchData = data;
  return this;
}
```

### 5.2 executeLog 批量逻辑

```dart
} else if (operateType == OperateType.updateBatch) {
  for (int i = 0; i < _batchData!.length; i++) {
    if (dao != null) {
      await dao!.update(_batchIds![i], _batchData![i] as TableCompanion);
    }
  }
} else if (operateType == OperateType.deleteBatch) {
  for (final id in _batchIds!) {
    if (dao != null) {
      await dao!.delete(id);
    }
  }
}
```

### 5.3 CategoryCULog / ShopCULog 批量构造

```dart
/// 批量更新（拖拽排序/改父级）
static CategoryCULog updateBatch({
  required String who,
  required String bookId,
  required List<String> ids,
  required List<AccountCategoryTableCompanion> updates,
}) {
  return CategoryCULog()
      .who(who)
      .inBook(bookId)
      .doUpdateBatch()
      .withBatchIds(ids)
      .withBatchData(updates)
      as CategoryCULog;
}

/// 批量删除（级联删除子树）
static CategoryCULog deleteBatch({
  required String who,
  required String bookId,
  required List<String> ids,
}) {
  return CategoryCULog()
      .who(who)
      .inBook(bookId)
      .doDeleteBatch()
      .withBatchIds(ids)
      as CategoryCULog;
}

/// 从日志恢复（新增批量 case）
static CategoryCULog fromLog(LogSync log) {
  return switch (OperateType.fromCode(log.operateType)) {
    OperateType.create => CategoryCULog.fromCreateLog(log),
    OperateType.updateBatch || OperateType.update => CategoryCULog.fromUpdateLog(log),
    OperateType.deleteBatch || OperateType.delete => CategoryCULog.fromDeleteLog(log),
  };
}
```

### 5.4 日志注册

```dart
// builder.dart _fromLog 中
case BusinessType.category:
  return CategoryCULog.fromLog(log) as LogBuilder<T, RunResult>;
case BusinessType.shop:
  return ShopCULog.fromLog(log) as LogBuilder<T, RunResult>;
```

## 六、DataDriver 接口

### 6.1 BookDataDriver 新增/修改

```dart
/// === 分类 ===

/// 创建分类（新增 parentId 参数）
Future<OperateResult<String>> createCategory(String userId, String bookId, {
  required String name,
  required String categoryType,
  String? parentId,
});

/// 更新分类（新增 tree 相关参数）
Future<OperateResult<void>> updateCategory(
  String userId, String bookId, String categoryId, {
  String? name,
  String? parentId,
  int? sortOrder,
  String? lastAccountItemAt,
});

/// 批量更新分类（拖拽操作）
Future<OperateResult<void>> updateCategories(
  String userId, String bookId, {
  required List<String> ids,
  required List<String?> parentIds,
  required List<int> sortOrders,
});

/// 批量删除分类（级联）
Future<OperateResult<void>> deleteCategories(
  String userId, String bookId,
  List<String> ids,
);

/// 获取全量分类（用于构建树）
Future<OperateResult<List<AccountCategory>>> listAllCategoriesByBook(
  String userId, String bookId, {String? categoryType});


/// === 商户 ===

/// 创建商户（新增 parentId 参数）
Future<OperateResult<String>> createShop(String userId, String bookId, {
  required String name,
  String? parentId,
});

/// 更新商户（新增 tree 相关参数）
Future<OperateResult<void>> updateShop(
  String userId, String bookId, String shopId, {
  String? name,
  String? parentId,
  int? sortOrder,
  String? lastAccountItemAt,
});

/// 批量更新商户（拖拽操作）
Future<OperateResult<void>> updateShops(
  String userId, String bookId, {
  required List<String> ids,
  required List<String?> parentIds,
  required List<int> sortOrders,
});

/// 批量删除商户（级联）
Future<OperateResult<void>> deleteShops(
  String userId, String bookId,
  List<String> ids,
);

/// 获取全量商户（用于构建树）
Future<OperateResult<List<AccountShop>>> listAllShopsByBook(
  String userId, String bookId);
```

## 七、LogDataDriver 实现

### 7.1 实现示例

```dart
/// 创建分类
@override
Future<OperateResult<String>> createCategory(String userId, String bookId, {
  required String name,
  required String categoryType,
  String? parentId,
  String? lastAccountItemAt,
}) async {
  try {
    // 检查名称唯一性
    final existing = await DaoManager.categoryDao.findByBookAndName(bookId, name);
    if (existing != null) {
      return OperateResult.success(existing.id);
    }
    final id = await CategoryCULog.create(
      who: userId,
      bookId: bookId,
      name: name,
      categoryType: categoryType,
      parentId: parentId,
    ).execute();
    return OperateResult.success(id);
  } catch (e) {
    return OperateResult.failWithMessage(message: '创建分类失败：$e', exception: e as Exception);
  }
}

/// 批量更新分类
@override
Future<OperateResult<void>> updateCategories(
  String userId, String bookId, {
  required List<String> ids,
  required List<String?> parentIds,
  required List<int> sortOrders,
}) async {
  try {
    final updates = List.generate(ids.length, (i) {
      return AccountCategoryTable.toUpdateCompanion(
        userId,
        parentId: parentIds[i],
        sortOrder: sortOrders[i],
      );
    });
    await CategoryCULog.updateBatch(
      who: userId,
      bookId: bookId,
      ids: ids,
      updates: updates,
    ).execute();
    return OperateResult.success(null);
  } catch (e) {
    return OperateResult.failWithMessage(message: '批量更新失败：$e', exception: e as Exception);
  }
}

/// 批量删除分类
@override
Future<OperateResult<void>> deleteCategories(
  String userId, String bookId,
  List<String> ids,
) async {
  try {
    await CategoryCULog.deleteBatch(
      who: userId,
      bookId: bookId,
      ids: ids,
    ).execute();
    return OperateResult.success(null);
  } catch (e) {
    return OperateResult.failWithMessage(message: '批量删除失败：$e', exception: e as Exception);
  }
}
```

## 八、VO / Model 层

### 8.1 TreeNode

```dart
// lib/models/vo/tree_node_vo.dart

class TreeNode<T> {
  final T data;
  final List<TreeNode<T>> children;
  final int level;  // 层级深度（0=根节点）

  bool get isLeaf => children.isEmpty;
  bool get isRoot => level == 0;

  const TreeNode({
    required this.data,
    this.children = const [],
    this.level = 0,
  });

  TreeNode<T> copyWith({List<TreeNode<T>>? children, int? level}) {
    return TreeNode(
      data: data,
      children: children ?? this.children,
      level: level ?? this.level,
    );
  }
}

/// 树构建工具
class TreeBuilder {
  /// 从扁平列表构建树
  static TreeNode<T>? findNode<T>(
    TreeNode<T> root,
    bool Function(T data) predicate,
  ) { ... }

  /// 递归展开树为扁平列表
  static List<TreeNode<T>> flatten<T>(TreeNode<T> node) { ... }

  /// 获取所有子孙节点的 ID
  static List<String> getDescendantIds<T>(
    List<TreeNode<T>> roots, String targetId, {String Function(T)? idGetter}
  ) { ... }
}
```

### 8.2 筛选逻辑

```dart
/// 在 Provider 中展开树节点 codes
/// 当「包含子类」toggle 开启时，递归获取所有后代 codes
List<String> expandCodes(
  List<TreeNode<AccountCategory>> roots,
  String code, {
  bool includeChildren = false,
}) {
  if (!includeChildren) return [code];
  
  final result = <String>[code];
  // 从 roots 中找到对应节点，递归添加所有子节点 code
  TreeBuilder.getDescendantIds(roots, code, (c) => c.code);
  return result;
}
```

## 九、Provider 层

### 9.1 CategoryProvider

```dart
class CategoryProvider extends ChangeNotifier {
  final List<TreeNode<AccountCategory>> _tree = [];
  List<TreeNode<AccountCategory>> get tree => _tree;
  
  List<AccountCategory> _rawList = [];
  List<AccountCategory> get rawList => _rawList;

  bool _includeChildren = false;
  bool get includeChildren => _includeChildren;
  
  set includeChildren(bool value) {
    _includeChildren = value;
    notifyListeners();
  }

  Future<void> loadTree(String bookId, {String? categoryType}) async {
    final result = await DriverFactory.driver.listAllCategoriesByBook(
      AppConfigManager.instance.userId, bookId,
      categoryType: categoryType,
    );
    if (result.ok && result.data != null) {
      _rawList = result.data!;
      rebuildTree();
    }
  }

  /// 从扁平数据重建树
  void rebuildTree() {
    _tree.clear();
    final childrenMap = <String?, List<AccountCategory>>{};
    final idMap = <String, AccountCategory>{};
    
    for (final item in _rawList) {
      idMap[item.id] = item;
      childrenMap.putIfAbsent(item.parentId, () => []).add(item);
    }
    
    // 按 sortOrder 排序
    for (final list in childrenMap.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }
    
    _tree.addAll(_buildNodes(null, childrenMap, 0));
    notifyListeners();
  }

  List<TreeNode<AccountCategory>> _buildNodes(
    String? parentId,
    Map<String?, List<AccountCategory>> childrenMap,
    int level,
  ) {
    final children = childrenMap[parentId] ?? [];
    return children.map((item) {
      return TreeNode(
        data: item,
        level: level,
        children: _buildNodes(item.id, childrenMap, level + 1),
      );
    }).toList();
  }

  /// 展开 codes（用于筛选）
  List<String> expandCodes(String code) {
    return TreeBuilder.getDescendantIds(_tree, code, (c) => c.code);
  }

  /// CRUD 代理
  Future<OperateResult<String>> create(...) async { ... }
  Future<OperateResult<void>> update(...) async { ... }
  Future<OperateResult<void>> delete(...) async { ... }
  Future<OperateResult<void>> batchUpdate(...) async { ... }
  Future<OperateResult<void>> batchDelete(...) async { ... }

  /// 增删改后自动 rebuildTree
}
```

### 9.2 ShopProvider

同理，模式与 CategoryProvider 一致。

### 9.3 Provider 注册

`lib/manager/provider_manager.dart` 新增：

```dart
static late CategoryProvider categoryProvider;
static late ShopProvider shopProvider;

static void initialize() {
  categoryProvider = CategoryProvider();
  shopProvider = ShopProvider();
}
```

## 十、UI 层

### 10.1 树形管理页面

新增通用组件 `TreeManageWidget<T>`，替换现有的 `CommonSimpleCrudList`。

**布局：**

```
┌─────────────────────────────────┐
│ 🔍 搜索                      │
├─────────────────────────────────┤
│ ▼ 餐饮           [+] [⋮⋮]   │  ← 可折叠/展开
│  ├─ ☕ 咖啡        [+] [⋮⋮]  │
│  │  ├─ 现磨咖啡    [+] [⋮⋮] │
│  │  └─ 速溶咖啡    [+] [⋮⋮] │
│  ├─ 🧋 奶茶        [+] [⋮⋮]  │
│  └─ 🍜 快餐        [+] [⋮⋮]  │
│ ▼ 交通           [+] [⋮⋮]   │
│  └─ 🚌 公交        [+] [⋮⋮]  │
└─────────────────────────────────┘
```

**交互：**

| 操作 | 行为 |
|------|------|
| 点击节点 | 编辑名称 |
| 点击 [+] | 添加子节点 |
| 长按拖动 | 拖拽排序 / 改变父子关系 |
| 滑动删除 | 删除（含子节点级联确认） |
| 点击展开图标 | 折叠/展开子树 |

**拖拽实现：**

- 利用 Flutter 的 `ReorderableListView` 或 `Draggable`/`DragTarget`
- 长按拖拽到目标位置释放
- 释放后计算新的 parentId 和 sortOrder
- 调用 `batchUpdate` 一次提交所有变更

### 10.2 记账表单选择器

`CommonSelectFormField` 展示带缩进层级：

```
◉ 餐饮
  ○ 咖啡
    ○ 现磨咖啡
  ○ 奶茶
◉ 交通
```

当前 `DisplayMode.expand` 保持，仅文案显示层级前缀。

### 10.3 筛选页面

在账目列表筛选区，「包含子类」开关：

```
分类：餐饮 [✓ 包含子类]  → 显示餐饮+咖啡+奶茶...所有账目
```

未勾选则只显示直接标记为「餐饮」的账目。

## 十一、数据迁移

无需迁移脚本。现有数据：

- 所有记录的 `parentId = null`（Drift 默认值）
- 所有记录的 `sortOrder = 0`
- 自动变为根节点

新增记录通过 UI 操作建立父子关系。

## 十二、文件变更清单

| 层级 | 文件 | 操作 |
|------|------|------|
| 枚举 | `lib/enums/operate_type.dart` | 新增 updateBatch/deleteBatch |
| 表 | `lib/database/tables/account_category_table.dart` | 新增 parentId/sortOrder 字段 |
| 表 | `lib/database/tables/account_shop_table.dart` | 新增 parentId/sortOrder 字段 |
| DAO | `lib/database/dao/category_dao.dart` | 新增树形查询方法 |
| DAO | `lib/database/dao/shop_dao.dart` | 新增树形查询方法 |
| Builder | `lib/drivers/special/log/builder/builder.dart` | 新增批量操作支持 |
| Builder | `lib/drivers/special/log/builder/book_category.builder.dart` | 新增批量构造 |
| Builder | `lib/drivers/special/log/builder/book_shop.builder.dart` | 新增批量构造 |
| 接口 | `lib/drivers/data_driver.dart` | 新增批量/全量方法 |
| 实现 | `lib/drivers/special/log.data_driver.dart` | 实现批量/全量方法 |
| VO | `lib/models/vo/tree_node_vo.dart` | **新增** |
| Provider | `lib/providers/category_provider.dart` | **新增** |
| Provider | `lib/providers/shop_provider.dart` | **新增** |
| 注册 | `lib/manager/provider_manager.dart` | 注册新 Provider |
| UI | `lib/widgets/common/tree_manage_widget.dart` | **新增** |
| UI | `lib/pages/book/categories_page.dart` | 改造为树形页面 |
| UI | `lib/pages/book/merchants_page.dart` | 改造为树形页面 |
| DB | `lib/database/database.dart` | schema 版本升级 |
| DB | `lib/database/tables/base_table.dart` | （如需通用 mixin） |

## 十三、注意事项

1. **级联删除**：删除父节点时需递归获取所有子节点 IDs，然后一次 `deleteBatch` 提交
2. **名称唯一性**：账本内同一类型下的分类名称全局唯一，树形不改变此规则
3. **深度限制**：UI 侧限制最大 5 层，DAO/Driver 不做硬限制
4. **日志记录**：批量操作记录为单条日志，包含所有变更 ID 和数据，便于回放
5. **兼容性**：现有记账条目引用的 categoryCode/shopCode 保持不变
6. **排序**：新建子节点自动追加到同级末尾（取 maxSortOrder + 1）
