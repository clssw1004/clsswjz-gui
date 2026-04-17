# DataDriver 新模块接入规范指导文档

## 一、架构概述

### 1.1 分层架构

```
┌─────────────────────────────────────────┐
│           UI 层 (Pages/Widgets)         │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Provider 层 (ChangeNotifier)    │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│        Driver 层 (BookDataDriver)       │
│    - 接口定义 (data_driver.dart)        │
│    - 实现 (special/log.data_driver.dart)│
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      LogBuilder 层 (日志构建器)          │
│    lib/drivers/special/log/builder/     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         DAO 层 (Data Access)            │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│       Database 层 (Drift Table)         │
└─────────────────────────────────────────┘
```

### 1.2 数据流向

**写入流程：**
```
UI → Provider → Driver → LogBuilder → DAO → Database + LogSync
```

**读取流程：**
```
UI → Provider → Driver → DAO → Database → VOTransfer → Provider → UI
```

### 1.3 核心文件

| 文件 | 职责 |
|------|------|
| `lib/drivers/data_driver.dart` | 定义 BookDataDriver 接口 |
| `lib/drivers/special/log.data_driver.dart` | LogDataDriver 实现类 |
| `lib/drivers/driver_factory.dart` | Driver 工厂类 |
| `lib/drivers/special/log/builder/builder.dart` | LogBuilder 基类 |
| `lib/drivers/special/log/builder/*.builder.dart` | 各业务 LogBuilder |
| `lib/database/dao/*_dao.dart` | DAO 层 |
| `lib/database/tables/*.dart` | Drift 表定义 |

---

## 二、接口设计原则

### 2.1 基本原则

**应定义的接口（基础 CRUD）：**
- `createXxx` - 创建
- `deleteXxx` - 删除
- `updateXxx` - 更新（原子方式，支持所有可更新字段）
- `listXxx` - 列表查询（支持分页和过滤）
- `getXxx` - 详情查询

**不应定义的接口：**
- ~~业务专用的状态变更方法~~（如 send、receive、approve 等）
- 这些都应该通过 `updateXxx` 的原子方式实现

### 2.2 update 方法设计

update 方法应该设计为原子方式，支持所有可更新字段：

```dart
/// 错误的做法：定义多个专用方法
Future<OperateResult<void>> sendGiftCard(String userId, String giftCardId);
Future<OperateResult<void>> receiveGiftCard(String userId, String giftCardId);
Future<OperateResult<void>> extendGiftCard(String userId, String giftCardId, int expiredTime);
Future<OperateResult<void>> voidGiftCard(String userId, String giftCardId);

/// 正确的做法：使用统一的 update 方法
Future<OperateResult<void>> updateGiftCard(
  String userId,
  String giftCardId, {
  String? toUserId,
  String? description,
  int? expiredTime,
  int? sentTime,
  int? receivedTime,
  String? status,
});
```

调用方式：
```dart
// 送出礼物卡
await driver.updateGiftCard(userId, id,
  status: GiftCardStatus.sent.code,
  sentTime: DateTime.now().millisecondsSinceEpoch,
);

// 接收礼物卡
await driver.updateGiftCard(userId, id,
  status: GiftCardStatus.received.code,
  receivedTime: DateTime.now().millisecondsSinceEpoch,
);

// 延期
await driver.updateGiftCard(userId, id,
  expiredTime: newExpiredTime,
);

// 作废
await driver.updateGiftCard(userId, id,
  status: GiftCardStatus.voided.code,
);
```

### 2.3 list 方法设计

支持类型过滤和分页：

```dart
/// 获取礼物卡列表
/// [type] 查询类型：received(我收到的), sent(我送出的), all(全部)
Future<OperateResult<List<GiftCardVO>>> listGiftCards(
  String userId, {
  GiftCardQueryType type = GiftCardQueryType.all,
});
```

---

## 三、接入步骤

### 3.1 数据库层

**第一步：创建 Drift 表定义**

文件：`lib/database/tables/xxx_table.dart`

```dart
import 'package:drift/drift.dart';
import 'base_table.dart';

/// 业务表（继承 BaseBusinessTable 获取 id, createdAt, updatedAt, createdBy, updatedBy）
@DataClassName('Xxx')
class XxxTable extends BaseBusinessTable {
  // 业务字段定义
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get amount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  // ...

  /// 创建 Companion（用于插入）
  static XxxTableCompanion toCreateCompanion(String who, {
    required String name,
    // 其他字段...
  }) {
    return XxxTableCompanion(
      id: Value(IdUtil.genId()),
      name: Value(name),
      // ...
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 更新 Companion（用于更新，仅包含需要更新的字段）
  static XxxTableCompanion toUpdateCompanion(String who, {
    String? name,
    // 其他可更新字段...
  }) {
    return XxxTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      name: Value.absentIfNull(name),
      // ...
    );
  }
}
```

**第二步：注册到 Database**

文件：`lib/database/database.dart`

```dart
part 'database.g.dart';

// 在 Database 类中添加表
@DataClassName('Xxx')
XxxTable get xxxTable => XxxTable();

// 添加 DAO
@ConstructedBy(XxxDaoConstructors)
@UseRowClass(Xxx)
abstract class _$AppDatabase extends BaseDatabase {
  // ...

  XxxDao get xxxDao;
}
```

**第三步：创建 DAO**

文件：`lib/database/dao/xxx_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/xxx_table.dart';
import 'base_dao.dart';

class XxxDao extends BaseDao<XxxTable, Xxx> {
  XxxDao(super.db);

  @override
  TableInfo<XxxTable, Xxx> get table => db.xxxTable;

  // 业务查询方法
  Future<List<Xxx>> findByUserId(String userId) {
    return (db.select(table)..where((t) => t.createdBy.equals(userId))).get();
  }

  // 插入
  Future<String> insert(XxxTableCompanion companion) async {
    await db.into(table).insert(companion);
    return companion.id.value;
  }

  // 更新
  Future<bool> update(String id, XxxTableCompanion companion) {
    return (db.update(table)..where((t) => t.id.equals(id))).write(companion).then((rows) => rows > 0);
  }

  // 删除
  Future<int> delete(String id) {
    return (db.delete(table)..where((t) => t.id.equals(id))).go();
  }
}
```

**第四步：注册到 DaoManager**

文件：`lib/manager/dao_manager.dart`

```dart
// 添加静态属性
static late XxxDao xxxDao;

// 初始化
void initializeDatabase(Database db) {
  // ...
  xxxDao = XxxDao(db);
}
```

### 3.2 业务类型枚举

文件：`lib/enums/business_type.dart`

```dart
enum BusinessType {
  // ... 现有类型
  xxx('xxx', '业务');

  final String code;
  final String text;
  const BusinessType(this.code, this.text);

  static BusinessType? fromCode(String code) {
    return values.firstWhere((e) => e.code == code, orElse: () => BusinessType.xxx);
  }
}
```

### 3.3 枚举定义

如果业务需要状态枚举，创建：`lib/enums/xxx_status.dart`

```dart
enum XxxStatus {
  draft('draft'),
  active('active'),
  completed('completed'),
  voided('voided');

  final String code;
  const XxxStatus(this.code);

  static XxxStatus fromCode(String code) {
    return values.firstWhere((e) => e.code == code, orElse: () => XxxStatus.draft);
  }

  String get text => switch (this) {
    draft => '草稿',
    active => '进行中',
    completed => '已完成',
    voided => '已作废',
  };
}
```

### 3.4 值对象 (VO)

文件：`lib/models/vo/xxx_vo.dart`

```dart
class XxxVO {
  final String id;
  final String name;
  final int amount;
  final XxxStatus status;
  final int createdAt;
  final int updatedAt;
  final String createdBy;
  final String updatedBy;

  // 计算属性
  bool get isExpired => status == XxxStatus.active && DateTime.now().millisecondsSinceEpoch > expiredTime;

  // 工厂方法
  factory XxxVO.fromXxx(Xxx xxx) {
    return XxxVO(
      id: xxx.id,
      name: xxx.name,
      // ...
    );
  }
}
```

### 3.5 LogBuilder

文件：`lib/drivers/special/log/builder/xxx.builder.dart`

```dart
import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../database/database.dart';
import '../../../../database/tables/xxx_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class XxxCULog extends LogBuilder<XxxTableCompanion, String> {
  XxxCULog() : super() {
    doWith(BusinessType.xxx);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.xxxDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.xxxDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.xxxDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return XxxTable.toJsonString(data as XxxTableCompanion);
  }

  /// 创建
  static XxxCULog create({
    required String who,
    required String name,
    // 其他字段
  }) {
    return XxxCULog()
        .who(who)
        .noParent() // 如果不关联账本，使用 noParent()
        // .inBook(bookId) // 如果关联账本，使用 inBook(bookId)
        .doCreate()
        .withData(XxxTable.toCreateCompanion(
          who,
          name: name,
          // ...
        )) as XxxCULog;
  }

  /// 更新
  static XxxCULog update({
    required String who,
    required String id,
    String? name,
    // 其他可更新字段
  }) {
    return XxxCULog()
        .who(who)
        .target(id)
        .doUpdate()
        .withData(XxxTable.toUpdateCompanion(
          who,
          name: name,
          // ...
        )) as XxxCULog;
  }

  /// 删除
  static XxxCULog delete({
    required String who,
    required String id,
  }) {
    return XxxCULog()
        .who(who)
        .target(id)
        .doDelete() as XxxCULog;
  }

  /// 从创建日志恢复
  static XxxCULog fromCreateLog(LogSync log) {
    return XxxCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as XxxCULog;
  }

  /// 从更新日志恢复
  static XxxCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return XxxCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doUpdate()
        .withData(XxxTable.toUpdateCompanion(
          log.operatorId,
          name: data['name'] as String?,
          // ...
        )) as XxxCULog;
  }

  /// 从日志恢复（工厂方法）
  static XxxCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => XxxCULog.fromCreateLog(log),
      _ => XxxCULog.fromUpdateLog(log),
    };
  }

  /// 解析 JSON 为 Companion
  static XxxTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return XxxTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      // ... 其他字段
    );
  }
}
```

**注册到 builder.dart：**

文件：`lib/drivers/special/log/builder/builder.dart`

```dart
// 导入
import 'xxx.builder.dart';

// 在静态方法 _fromLog 中添加 case
switch (businessType) {
  // ...
  case BusinessType.xxx:
    return XxxCULog.fromLog(log) as LogBuilder<T, RunResult>;
}
```

### 3.6 DataDriver 接口

文件：`lib/drivers/data_driver.dart`

```dart
/// 业务相关
/// 创建业务
Future<OperateResult<String>> createXxx(String userId, {
  required String name,
  // 其他字段
});

/// 删除业务
Future<OperateResult<void>> deleteXxx(String userId, String xxxId);

/// 更新业务
Future<OperateResult<void>> updateXxx(
  String userId,
  String xxxId, {
  String? name,
  // 其他可更新字段
});

/// 获取业务列表
Future<OperateResult<List<XxxVO>>> listXxxs(String userId, {
  int limit = 20,
  int offset = 0,
  XxxFilterDTO? filter,
});

/// 获取业务详情
Future<OperateResult<XxxVO>> getXxx(String userId, String xxxId);
```

### 3.7 DataDriver 实现

文件：`lib/drivers/special/log.data_driver.dart`

```dart
@override
Future<OperateResult<String>> createXxx(String userId, { /* 参数 */ }) async {
  try {
    final id = await XxxCULog.create(
      who: userId,
      // 参数
    ).execute();
    return OperateResult.success(id);
  } catch (e) {
    return OperateResult.failWithMessage(message: '创建失败：$e', exception: e as Exception);
  }
}

@override
Future<OperateResult<void>> deleteXxx(String userId, String xxxId) async {
  try {
    await XxxCULog.delete(who: userId, id: xxxId).execute();
    return OperateResult.success(null);
  } catch (e) {
    return OperateResult.failWithMessage(message: '删除失败：$e', exception: e as Exception);
  }
}

@override
Future<OperateResult<void>> updateXxx(String userId, String xxxId, { /* 参数 */ }) async {
  try {
    await XxxCULog.update(
      who: userId,
      id: xxxId,
      // 参数
    ).execute();
    return OperateResult.success(null);
  } catch (e) {
    return OperateResult.failWithMessage(message: '更新失败：$e', exception: e as Exception);
  }
}

@override
Future<OperateResult<List<XxxVO>>> listXxxs(String userId, { /* 参数 */ }) async {
  try {
    final list = await DaoManager.xxxDao.findByUserId(userId);
    return OperateResult.success(list.map((e) => XxxVO.fromXxx(e)).toList());
  } catch (e) {
    return OperateResult.failWithMessage(message: '查询失败：$e', exception: e as Exception);
  }
}
```

---

## 四、Provider 层

文件：`lib/providers/xxx_provider.dart`

```dart
import 'package:flutter/material.dart';
import 'package:clsswjz_gui/drivers/driver_factory.dart';
import 'package:clsswjz_gui/enums/operate_type.dart';
import 'package:clsswjz_gui/events/event_bus.dart';
import 'package:clsswjz_gui/events/special/event_book.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/models/common.dart';
import 'package:clsswjz_gui/models/vo/xxx_vo.dart';

class XxxProvider extends ChangeNotifier {
  final List<XxxVO> _items = [];
  List<XxxVO> get items => _items;

  /// 加载列表
  Future<void> loadItems() async {
    final result = await DriverFactory.driver.listXxxs(AppConfigManager.instance.userId);
    if (result.ok) {
      _items.clear();
      _items.addAll(result.data ?? []);
      notifyListeners();
    }
  }

  /// 创建
  Future<OperateResult<String>> createXxx({ /* 参数 */ }) async {
    final result = await DriverFactory.driver.createXxx(
      AppConfigManager.instance.userId,
      // 参数
    );
    if (result.ok) {
      await loadItems();
      // 触发同步（如果需要）
      final item = _items.firstWhere((e) => e.id == result.data);
      EventBus.instance.emit(XxxChangedEvent(OperateType.create, item));
    }
    return result;
  }

  /// 更新
  Future<OperateResult<void>> updateXxx(String id, { /* 参数 */ }) async {
    final result = await DriverFactory.driver.updateXxx(
      AppConfigManager.instance.userId,
      id,
      // 参数
    );
    if (result.ok) {
      await loadItems();
      // 触发同步（如果需要）
      final item = _items.firstWhere((e) => e.id == id);
      EventBus.instance.emit(XxxChangedEvent(OperateType.update, item));
    }
    return result;
  }

  /// 删除
  Future<OperateResult<void>> deleteXxx(String id) async {
    final result = await DriverFactory.driver.deleteXxx(AppConfigManager.instance.userId, id);
    if (result.ok) {
      await loadItems();
      // 触发同步（如果需要）
      final item = _items.firstWhere((e) => e.id == id);
      EventBus.instance.emit(XxxChangedEvent(OperateType.delete, item));
    }
    return result;
  }
}
```

---

## 五、同步机制（可选）

如果业务需要自动同步到云端，按以下步骤添加：

### 5.1 定义事件

文件：`lib/events/special/event_xxx.dart` 或在 `event_book.dart` 中添加：

```dart
class XxxChangedEvent {
  final XxxVO xxx;
  final OperateType operateType;
  const XxxChangedEvent(this.operateType, this.xxx);
}
```

### 5.2 订阅事件

文件：`lib/providers/sync_provider.dart`

```dart
void _subscribeToEvents() {
  _subscriptions.addAll([
    // ... 其他事件
    EventBus.instance.on<XxxChangedEvent>(_handleXxxChanged),
  ]);
}

void _handleXxxChanged(XxxChangedEvent event) {
  // 业务数据任何操作都需要同步
  syncData();
}
```

---

## 六、注意事项

### 6.1 继承选择

- **继承 `BaseBusinessTable`**：如果需要 id, createdAt, updatedAt, createdBy, updatedBy 字段
- **继承 `BaseTable`**：如果只需要 id 字段

### 6.2 账本关联

- **不关联账本**：使用 `.noParent()` 构建 LogBuilder
- **关联账本**：使用 `.inBook(bookId)` 构建 LogBuilder

### 6.3 权限控制

- 在 Provider 层进行权限判断
- 在 DataDriver 层也可以添加权限校验
- UI 层根据状态显示/隐藏操作按钮

### 6.4 时间处理

- 所有时间存储为毫秒时间戳 (INTEGER)
- 使用 `DateUtil` 进行格式化
- 0 表示"无限制"或"永久"

### 6.5 日志记录

- `execute()` 方法会自动记录日志到 `log_sync_table`
- `executeWithoutRecord()` 方法仅执行操作，不记录日志
- 数据恢复时使用 `fromLog(LogSync log)` 工厂方法

### 6.6 批量操作

如需批量操作，在 LogBuilder 中添加批量方法：

```dart
static XxxCULog createBatch(String who, List<XxxTableCompanion> companions) {
  return XxxCULog()
      .who(who)
      .doCreateBatch()
      .withData(companions) as XxxCULog;
}
```

---

## 七、文件清单

新模块接入需要创建/修改的文件：

| 层级 | 文件路径 | 说明 |
|------|----------|------|
| 枚举 | `lib/enums/business_type.dart` | 添加业务类型 |
| 枚举 | `lib/enums/xxx_status.dart` | 状态枚举（可选） |
| 表 | `lib/database/tables/xxx_table.dart` | 表定义 |
| DAO | `lib/database/dao/xxx_dao.dart` | 数据访问层 |
| 模型 | `lib/models/vo/xxx_vo.dart` | 值对象 |
| DTO | `lib/models/dto/xxx_filter_dto.dart` | 过滤参数（可选） |
| Builder | `lib/drivers/special/log/builder/xxx.builder.dart` | 日志构建器 |
| 接口 | `lib/drivers/data_driver.dart` | 接口定义 |
| 实现 | `lib/drivers/special/log.data_driver.dart` | 实现 |
| Provider | `lib/providers/xxx_provider.dart` | 状态管理 |
| 注册 | `lib/manager/dao_manager.dart` | 注册 DAO |
| 注册 | `lib/manager/provider_manager.dart` | 注册 Provider |
| 路由 | `lib/routes/app_routes.dart` | 路由配置 |
| 同步 | `lib/events/special/event_xxx.dart` | 事件定义（可选） |
| 同步 | `lib/providers/sync_provider.dart` | 订阅事件（可选） |