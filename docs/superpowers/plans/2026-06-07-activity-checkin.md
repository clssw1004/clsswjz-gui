# 活动打卡模块实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将现有活动模块从"记录式"改为"习惯打卡式"，支持预制活动定义、网格点击+1打卡

**Architecture:** 新增 ActivityDefinitionTable + ActivityDefinitionDao 管理预制活动，ActivityRecordTable 增加 activityDefId 列关联定义。采用项目标准的 LogBuilder 日志驱动模式。

**Tech Stack:** Flutter, Drift (SQLite), Provider

---

## 文件结构

### 新增文件 (10个)
| 文件 | 职责 |
|------|------|
| `lib/database/tables/activity_definition_table.dart` | 活动定义表 |
| `lib/database/dao/activity_definition_dao.dart` | 活动定义 DAO |
| `lib/models/vo/activity_definition_vo.dart` | 活动定义 VO |
| `lib/drivers/special/log/builder/activity_definition.builder.dart` | 活动定义 CRUD 日志构建器 |
| `lib/providers/activity_checkin_provider.dart` | 打卡状态管理 Provider |
| `lib/pages/activity/activity_checkin_page.dart` | 打卡主页 |
| `lib/pages/activity/activity_def_edit_page.dart` | 活动定义编辑页 |
| `lib/widgets/activity/activity_checkin_grid.dart` | 打卡网格组件 |
| `lib/widgets/activity/activity_recent_records.dart` | 最近打卡记录组件 |
| `lib/events/special/event_activity_checkin.dart` | 活动定义变更事件 |

### 修改文件 (13个)
| 文件 | 修改 |
|------|------|
| `lib/database/tables/activity_record_table.dart` | 新增 `activityDefId` 列 |
| `lib/database/database.dart` | 注册表，schemaVersion 6→7，onUpgrade |
| `lib/enums/business_type.dart` | 新增 `activityDefinition` |
| `lib/drivers/data_driver.dart` | 新增活动定义接口方法 |
| `lib/drivers/special/log.data_driver.dart` | 实现活动定义接口 |
| `lib/drivers/special/log/builder/builder.dart` | 注册 ActivityDefinitionCULog |
| `lib/manager/dao_manager.dart` | 注册 ActivityDefinitionDao |
| `lib/manager/provider_manager.dart` | 注册 ActivityCheckinProvider |
| `lib/pages/tabs/mine_tab.dart` | 增加入口图标 |
| `lib/pages/tabs/items_tab.dart` | 增加最近打卡区块 |
| `lib/models/dto/ui_config_dto.dart` | 新增配置字段 |
| `lib/pages/settings/ui_config_page.dart` | 新增开关 |
| `lib/routes/app_routes.dart` | 添加路由 |

---

### Task 1: 创建 ActivityDefinitionTable

**Files:**
- Create: `lib/database/tables/activity_definition_table.dart`

- [ ] **Step 1: 创建表定义文件**

```dart
import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('ActivityDefinition')
class ActivityDefinitionTable extends BaseAccountBookTable {
  TextColumn get name => text().named('name')();
  TextColumn get emoji => text().named('emoji')();
  IntColumn get color => integer().named('color')();
  IntColumn get sortOrder => integer().named('sort_order').withDefault(const Constant(0))();

  static ActivityDefinitionTableCompanion toCreateCompanion(
    String who, {
    required String accountBookId,
    required String name,
    required String emoji,
    required int color,
    int sortOrder = 0,
  }) {
    final now = DateUtil.now();
    return ActivityDefinitionTableCompanion(
      id: Value(IdUtil.genId()),
      accountBookId: Value(accountBookId),
      name: Value(name),
      emoji: Value(emoji),
      color: Value(color),
      sortOrder: Value(sortOrder),
      createdBy: Value(who),
      createdAt: Value(now),
      updatedBy: Value(who),
      updatedAt: Value(now),
    );
  }

  static ActivityDefinitionTableCompanion toUpdateCompanion(
    String who, {
    String? name,
    String? emoji,
    int? color,
    int? sortOrder,
  }) {
    return ActivityDefinitionTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      name: Value.absentIfNull(name),
      emoji: Value.absentIfNull(emoji),
      color: Value.absentIfNull(color),
      sortOrder: Value.absentIfNull(sortOrder),
    );
  }

  static String toJsonString(ActivityDefinitionTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'name', companion.name);
    MapUtil.setIfPresent(map, 'emoji', companion.emoji);
    MapUtil.setIfPresent(map, 'color', companion.color);
    MapUtil.setIfPresent(map, 'sortOrder', companion.sortOrder);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    return jsonEncode(map);
  }

  static ActivityDefinitionTableCompanion fromJson(Map<String, dynamic> json) {
    return ActivityDefinitionTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      accountBookId: json['accountBookId'] != null ? Value(json['accountBookId'] as String) : const Value.absent(),
      name: json['name'] != null ? Value(json['name'] as String) : const Value.absent(),
      emoji: json['emoji'] != null ? Value(json['emoji'] as String) : const Value.absent(),
      color: json['color'] != null ? Value(json['color'] as int) : const Value.absent(),
      sortOrder: json['sortOrder'] != null ? Value(json['sortOrder'] as int) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
    );
  }
}
```

- [ ] **Step 2: 生成 database.g.dart**

Run: `flutter pub run drift_dev build`

---

### Task 2: 创建 ActivityDefinitionDao

**Files:**
- Create: `lib/database/dao/activity_definition_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/activity_definition_table.dart';
import 'base_dao.dart';

class ActivityDefinitionDao extends BaseBookDao<ActivityDefinitionTable, ActivityDefinition> {
  ActivityDefinitionDao(super.db);

  @override
  TableInfo<ActivityDefinitionTable, ActivityDefinition> get table => db.activityDefinitionTable;

  @override
  List<OrderClauseGenerator<ActivityDefinitionTable>> defaultOrderBy() {
    return [
      (t) => OrderingTerm.asc(t.sortOrder),
      (t) => OrderingTerm.asc(t.createdAt),
    ];
  }
}
```

---

### Task 3: 修改 ActivityRecordTable 增加 activityDefId 列

**Files:**
- Modify: `lib/database/tables/activity_record_table.dart`

- [ ] **Step 1: 在 `recordDate` 列后添加新列声明**

```dart
  TextColumn get activityDefId => text().named('activity_def_id').nullable()();
```

- [ ] **Step 2: 更新 `toCreateCompanion` 参数列表增加 `String? activityDefId`，在 return 中增加 `activityDefId: Value.absentIfNull(activityDefId),`**

- [ ] **Step 3: `toJsonString` 增加 `MapUtil.setIfPresent(map, 'activityDefId', companion.activityDefId);`**

- [ ] **Step 4: `fromJson` 增加 `activityDefId: json['activityDefId'] != null ? Value(json['activityDefId'] as String) : const Value.absent(),`**

- [ ] **Step 5: 更新 ActivityRecordVO**

在 `lib/models/vo/activity_record_vo.dart` 中增加：
```dart
  final String? activityDefId;
```
构造参数增加 `this.activityDefId`，`fromActivityRecord` 增加 `activityDefId: record.activityDefId`，`copyWith` 增加 `String? activityDefId`。

- [ ] **Step 6: 更新 ActivityRecordCULog.create 参数**

在 `lib/drivers/special/log/builder/activity_record.builder.dart` 的 `create` 方法参数中增加 `String? activityDefId`，在 `withData` 中传递给 `toCreateCompanion`。

- [ ] **Step 7: 更新 createActivityRecord Driver 接口**

在 `lib/drivers/data_driver.dart` 的 `createActivityRecord` 参数中增加 `String? activityDefId`。

在 `lib/drivers/special/log.data_driver.dart` 的 `createActivityRecord` 实现中增加 `String? activityDefId` 参数并传递给 LogBuilder。

- [ ] **Step 8: 生成 database.g.dart**

Run: `flutter pub run drift_dev build`

---

### Task 4: 修改 Database 注册和迁移

**Files:**
- Modify: `lib/database/database.dart`

- [ ] **Step 1: 导入 ActivityDefinitionTable，在 tables 列表中增加，schemaVersion 改为 7**

```dart
import 'tables/activity_definition_table.dart';
```

在 `@DriftDatabase(tables: [...` 列表中增加 `ActivityDefinitionTable,`。

`int get schemaVersion => 7;`

- [ ] **Step 2: 在 onUpgrade 中添加 v6→v7 迁移**

```dart
          if (from < 7) {
            await m.create(activityDefinitionTable);
            await m.addColumn(activityRecordTable, activityRecordTable.activityDefId);
          }
```

- [ ] **Step 3: 生成 database.g.dart**

Run: `flutter pub run drift_dev build`

---

### Task 5: 添加 BusinessType

**Files:**
- Modify: `lib/enums/business_type.dart`

在 `activity('activity'),` 后添加：
```dart
  activityDefinition('activityDefinition'),
```

---

### Task 6: 创建 ActivityDefinitionVO

**Files:**
- Create: `lib/models/vo/activity_definition_vo.dart`

```dart
import '../../database/database.dart';

class ActivityDefinitionVO {
  final String id;
  final String accountBookId;
  final String name;
  final String emoji;
  final int color;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;

  const ActivityDefinitionVO({
    required this.id,
    required this.accountBookId,
    required this.name,
    required this.emoji,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  static ActivityDefinitionVO fromEntity(ActivityDefinition entity) {
    return ActivityDefinitionVO(
      id: entity.id,
      accountBookId: entity.accountBookId,
      name: entity.name,
      emoji: entity.emoji,
      color: entity.color,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
```

---

### Task 7: 创建事件定义

**Files:**
- Create: `lib/events/special/event_activity_checkin.dart`

```dart
import '../../enums/operate_type.dart';
import '../../models/vo/activity_definition_vo.dart';

class ActivityDefinitionChangedEvent {
  final ActivityDefinitionVO definition;
  final OperateType operateType;
  const ActivityDefinitionChangedEvent(this.operateType, this.definition);
}
```

---

### Task 8: 创建 ActivityDefinitionCULog

**Files:**
- Create: `lib/drivers/special/log/builder/activity_definition.builder.dart`

参考 `activity_record.builder.dart` 的模式创建完整 LogBuilder，支持 create/update/delete/fromLog，使用 `BusinessType.activityDefinition`。

与 `activity_record.builder.dart` 同目录，模式完全一致：
- `executeLog` 中 create→insert, update→DaoManager.update, delete→DaoManager.delete
- `data2Json` → `ActivityDefinitionTable.toJsonString`
- 静态工厂：`create()`, `update()`, `delete()`
- `fromLog` 支持 create/update/delete 恢复
- `_parseCompanion` 解析 JSON

---

### Task 9: 注册 LogBuilder 到 builder.dart

**Files:**
- Modify: `lib/drivers/special/log/builder/builder.dart`

- [ ] **Step 1: 导入**
```dart
import 'activity_definition.builder.dart';
```

- [ ] **Step 2: _fromLog switch 中添加**
```dart
      case BusinessType.activityDefinition:
        return ActivityDefinitionCULog.fromLog(log) as LogBuilder<T, RunResult>;
```

- [ ] **Step 3: DeleteLog.executeLog switch 中添加**
```dart
      case BusinessType.activityDefinition:
        return DaoManager.activityDefinitionDao.delete(businessId!);
```

---

### Task 10: 注册 DAO

**Files:**
- Modify: `lib/manager/dao_manager.dart`

添加导入、声明静态变量、在 `refreshDaos()` 中初始化。

---

### Task 11: 添加 DataDriver 接口方法

**Files:**
- Modify: `lib/drivers/data_driver.dart`

在 `getActivityStatistics` 后添加 4 个活动定义接口方法：`createActivityDefinition`、`updateActivityDefinition`、`deleteActivityDefinition`、`listActivityDefinitions`。

导入 `ActivityDefinitionVO`。

---

### Task 12: 实现 DataDriver 接口

**Files:**
- Modify: `lib/drivers/special/log.data_driver.dart`

实现 Task 11 中定义的 4 个接口方法，遵循现有 `createActivityRecord` 等方法的 try-catch 模式。

---

### Task 13: 创建 ActivityCheckinProvider

**Files:**
- Create: `lib/providers/activity_checkin_provider.dart`

Provider 包含：
- `definitions` / `todayCounts` / `todayTotal` / `recentRecords`
- `loadAll()` / `loadDefinitions()` / `loadTodayCounts()` / `loadRecentRecords()`
- `checkIn(defId)` → 创建打卡记录
- `createDefinition(...)` / `updateDefinition(vo)` / `deleteDefinition(id)`
- 订阅 `BookChangedEvent`、`SyncCompletedEvent`、`ActivityDefinitionChangedEvent`

---

### Task 14: 注册 Provider

**Files:**
- Modify: `lib/manager/provider_manager.dart`

在 providers 列表中注册 `ActivityCheckinProvider`。

---

### Task 15: 创建打卡网格组件

**Files:**
- Create: `lib/widgets/activity/activity_checkin_grid.dart`

3列网格，每个格子显示 Emoji + 名称 + 今日次数，点击+1（弹簧动画+HapticFeedback），最后一个格子是"＋新建"入口。

---

### Task 16: 创建活动定义编辑页

**Files:**
- Create: `lib/pages/activity/activity_def_edit_page.dart`

全屏编辑页，支持新建和编辑，包含：Emoji 选择器（底部弹窗）、名称输入框、10色预设颜色选择、实时预览卡片。

---

### Task 17: 创建打卡主页

**Files:**
- Create: `lib/pages/activity/activity_checkin_page.dart`

集成 `ActivityCheckinGrid`，AppBar 右上角"＋新建"按钮，空状态引导，下拉刷新。

---

### Task 18: 添加路由

**Files:**
- Modify: `lib/routes/app_routes.dart`

添加 `activityCheckin` 和 `activityDefEdit` 路由常量及 _resolvePage 的 case。

---

### Task 19: 修改 mine_tab 添加入口

**Files:**
- Modify: `lib/pages/tabs/mine_tab.dart`

在 `bookFeatureItems` 列表中添加"活动打卡"入口图标，使用 `AppConfigManager.instance.uiConfig.mineTabShowActivityCheckin` 控制显示。

---

### Task 20: 创建最近打卡组件 + 集成到 items_tab

**Files:**
- Create: `lib/widgets/activity/activity_recent_records.dart`
- Modify: `lib/pages/tabs/items_tab.dart`

最近打卡组件显示最近5条记录（Emoji + 名称 + 时间），集成到 items_tab 适当位置。

---

### Task 21: 修改 UI 配置

**Files:**
- Modify: `lib/models/dto/ui_config_dto.dart`
- Modify: `lib/pages/settings/ui_config_page.dart`

新增 `mineTabShowActivityCheckin` 字段（默认 true），在 ui_config_page 添加开关行。

---

### Task 22: 运行验证

- [ ] **Step 1: 生成数据库代码**
  Run: `flutter pub run drift_dev build`

- [ ] **Step 2: 代码分析**
  Run: `flutter analyze`

- [ ] **Step 3: 运行应用**
  Run: `flutter run`
  验证关键流程：数据库迁移、入口显示、新建活动、网格打卡+1、编辑/删除、记账页最近记录、UI 配置开关。
