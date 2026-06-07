# 活动打卡模块设计方案

## 一、背景

将现有"记录式"活动模块改造为"习惯打卡式"：用户可预先创建管理一组活动（如跑步、看书、冥想），在打卡主页通过点击网格卡片快速 +1 打卡，无需每次填写表单。

## 二、模块介绍

### 2.1 功能概述

| 功能 | 说明 |
|------|------|
| 预制活动管理 | 创建/编辑/删除活动定义（名称、Emoji、颜色），支持排序 |
| 今日打卡 | 网格展示所有预制活动，点击卡片 +1 打卡 |
| 快速新建 | 网格最后一个"＋新建"入口，快速新增活动定义 |
| 最近打卡 | 在记账页显示最近几条打卡记录 |
| 显示控制 | UI 配置页开关控制「我的」页入口是否显示 |

### 2.2 模块特性

- **绑定账本**：活动定义与账本关联
- **日志驱动**：使用项目统一的日志驱动模式
- **轻量入口**：不新增底部 Tab，入口在「我的」页面的功能网格中
- **统一存储**：打卡记录仍使用原有的 `ActivityRecord` 表，新增 `activity_def_id` 关联预制活动

### 2.3 名词约定

| 术语 | 说明 |
|------|------|
| 活动定义 (ActivityDefinition) | 用户预先创建的活动模板，包含名称、Emoji、颜色 |
| 打卡记录 (ActivityRecord) | 一次具体的打卡记录，关联活动定义 + 日期 + 可选地点 |

## 三、数据结构设计

### 3.1 新增表：活动定义表

```dart
// lib/database/tables/activity_definition_table.dart

/// 活动定义表
@DataClassName('ActivityDefinition')
class ActivityDefinitionTable extends BaseAccountBookTable {
  /// 活动名称 (如：跑步、看书)
  TextColumn get name => text().named('name')();

  /// Emoji 图标 (如：🏃)
  TextColumn get emoji => text().named('emoji')();

  /// 颜色值 (ARGB int)
  IntColumn get color => integer().named('color')();

  /// 排序序号
  IntColumn get sortOrder => integer().named('sort_order').withDefault(const Constant(0))();
}
```

**表字段说明：**

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | TEXT | 是 | 唯一标识 (UUID) |
| account_book_id | TEXT | 是 | 所属账本ID |
| name | TEXT | 是 | 活动名称 |
| emoji | TEXT | 是 | Emoji 图标 |
| color | INTEGER | 是 | ARGB 颜色值 |
| sort_order | INTEGER | 否 | 排序序号，默认 0 |
| created_at | INTEGER | 是 | 创建时间 |
| updated_at | INTEGER | 是 | 更新时间 |
| created_by | TEXT | 是 | 创建人ID |
| updated_by | TEXT | 是 | 更新人ID |

### 3.2 修改现有表：ActivityRecordTable

在现有 `ActivityRecordTable` 中新增字段：

```dart
/// 关联的活动定义 ID（nullable）
TextColumn get activityDefId => text().named('activity_def_id').nullable()();
```

原有字段 `activity_name`、`location`、`record_date` 保持不变。`activity_name` 作为冗余字段，即使活动定义被删除，记录仍可显示名称。

### 3.3 值对象

```dart
// lib/models/vo/activity_definition_vo.dart

class ActivityDefinitionVO {
  final String id;
  final String accountBookId;
  final String name;
  final String emoji;
  final int color;       // ARGB
  final int sortOrder;
  final int createdAt;
  final int updatedAt;

  const ActivityDefinitionVO({...});
  factory ActivityDefinitionVO.fromEntity(ActivityDefinition entity);
}
```

复用已有的 `ActivityRecordVO`（增加 `activityDefId` 字段）。

### 3.4 BusinessType 枚举

新增 `activityDefinition('activity_definition')`，原有 `activity('activity')` 保留。

## 四、文件变更清单

### 新增文件

| 层级 | 文件路径 | 说明 |
|------|----------|------|
| 数据库 | `lib/database/tables/activity_definition_table.dart` | 活动定义表 |
| 数据库 | `lib/database/dao/activity_definition_dao.dart` | DAO |
| 模型 | `lib/models/vo/activity_definition_vo.dart` | 活动定义 VO |
| 日志构建器 | `lib/drivers/special/log/builder/activity_definition.builder.dart` | 活动定义 CRUD 日志构建器 |
| Provider | `lib/providers/activity_checkin_provider.dart` | 打卡状态管理 |
| 页面 | `lib/pages/activity/activity_checkin_page.dart` | 打卡主页（网格 + 管理） |
| 页面 | `lib/pages/activity/activity_def_edit_page.dart` | 活动定义编辑页 |
| 页面 | `lib/widgets/activity/activity_checkin_grid.dart` | 打卡网格组件 |
| 注册 | `lib/manager/manager.dart` | DAO & Provider 注册 |

### 修改文件

| 文件 | 修改内容 |
|------|----------|
| `lib/database/tables/activity_record_table.dart` | 新增 `activityDefId` 列 |
| `lib/database/database.dart` | 注册 `ActivityDefinitionTable`，schemaVersion 6→7，onUpgrade 添加 v7 迁移 |
| `lib/enums/business_type.dart` | 新增 `activityDefinition` |
| `lib/drivers/data_driver.dart` | 新增活动定义相关接口 |
| `lib/drivers/special/log.data_driver.dart` | 实现活动定义相关方法 |
| `lib/drivers/special/log/builder/builder.dart` | 注册 ActivityDefinitionCULog |
| `lib/manager/dao_manager.dart` | 注册 ActivityDefinitionDao |
| `lib/manager/provider_manager.dart` | 注册 ActivityCheckinProvider |
| `lib/pages/tabs/mine_tab.dart` | 功能网格增加"活动打卡"图标入口 |
| `lib/pages/tabs/items_tab.dart` | 增加"最近打卡"区块 |
| `lib/models/dto/ui_config_dto.dart` | 新增 `mineTabShowActivityCheckin` 字段 |
| `lib/pages/settings/ui_config_page.dart` | 新增显示开关 |

## 五、UX/UI 设计

### 5.1 入口设计

在「我的」页面的功能网格中，新增「活动打卡」图标：

```
┌──────────────────────────────┐
│  功能                          │
│  [分类] [账户] [商家] [标签]   │
│  [项目] [活动打卡 ●]          │ ← 新增
└──────────────────────────────┘
```

通过 UI 配置页控制该入口是否显示。

### 5.2 打卡主页

```
┌──────────────────────────────────────┐
│  ← 活动打卡              [+ 新建]   │
├──────────────────────────────────────┤
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │  🏃  │ │  📖  │ │  🧘  │       │ ← 网格卡片
│  │ 跑步  │ │ 看书  │ │ 冥想  │       │    点击 +1
│  │  3次  │ │  1次  │ │  0次  │       │    背景使用活动颜色
│  └──────┘ └──────┘ └──────┘       │      带半透明
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │  💧  │ │  🥗  │ │  ＋  │       │ ← ＋快速新建
│  │ 喝水  │ │ 吃菜  │ │ 新建  │       │
│  │  5次  │ │  2次  │ │      │       │
│  └──────┘ └──────┘ └──────┘       │
│                                     │
│  今日打卡 共 12 次                  │ ← 底部统计
└──────────────────────────────────────┘
```

**操作方式：**

| 操作 | 行为 |
|------|------|
| 点击活动格子 | 今日打卡次数 +1，创建一条 ActivityRecord |
| 长按活动格子 | 弹出菜单：编辑 / 删除 |
| 点击右上角 + 新建 | 打开活动定义编辑页 |
| 点击底部统计 | 可扩展查看详情（后续版本） |

### 5.3 活动定义编辑页

```
┌──────────────────────────────────────┐
│  ← 新建活动                [保存]    │
├──────────────────────────────────────┤
│                                      │
│  活动名称                            │
│  ┌────────────────────────────────┐  │
│  │  跑步                          │  │
│  └────────────────────────────────┘  │
│                                      │
│  Emoji                              │
│  ┌────────────────────────────────┐  │
│  │  🏃                           │  │ ← 可输入或从选择器选
│  └────────────────────────────────┘  │
│                                      │
│  颜色                                │
│  ○  ○  ○  ●  ○  ○  ○               │ ← 预设颜色选择器
│  ○  ○  ○  ○  ○  ○  ○               │
│                                      │
└──────────────────────────────────────┘
```

### 5.4 记账页「最近打卡」

```
┌──────────────────────────────────────┐
│  最近打卡                            │ ← 卡片标题
├──────────────────────────────────────┤
│  🏃 跑步          今天 09:30         │ ← 最新在前，最多 5 条
│  📖 看书          今天 08:00         │
│  🧘 冥想          昨天 21:00         │
│  💧 喝水          昨天 15:30         │
│                       [查看全部]     │ ← 跳转打卡主页
└──────────────────────────────────────┘
```

## 六、技术实现要点

### 6.1 核心数据流

```
UI层 (打卡主页 / 网格)
    ↓ ↑
Provider层 (ActivityCheckinProvider)
    ↓ ↑
Driver层 (LogDataDriver)
    ↓ ↑
日志构建器 (ActivityDefinitionCULog / ActivityRecordCULog)
    ↓ ↑
DAO层 (ActivityDefinitionDao / ActivityRecordDao)
    ↓ ↑
Database层 (ActivityDefinitionTable / ActivityRecordTable)
```

### 6.2 打卡 +1 流程

1. 用户点击活动网格卡片
2. Provider 调用 `DriverFactory.driver.createActivityRecord()`，传入 `activityDefId`、`activityName`、`recordDate`（今日）
3. LogDataDriver 创建 `ActivityRecordCULog`，写入日志并执行
4. Provider 刷新今日打卡计数
5. UI 更新对应格子的次数显示（带 +1 动画）

### 6.3 数据迁移

schemaVersion 6 → 7：

```dart
if (from < 7) {
  // 版本6到版本7的迁移：添加活动定义表、activityRecord表新增activityDefId列
  await m.create(activityDefinitionTable);
  await m.addColumn(activityRecordTable, activityRecordTable.activityDefId);
}
```

### 6.4 Provider 核心逻辑

```dart
class ActivityCheckinProvider extends ChangeNotifier {
  List<ActivityDefinitionVO> _definitions = [];  // 所有预制活动
  Map<String, int> _todayCounts = {};            // defId -> 今日打卡次数
  List<ActivityRecordVO> _recentRecords = [];    // 最近打卡记录

  /// 加载所有活动定义
  Future<void> loadDefinitions();

  /// 加载今日打卡计数
  Future<void> loadTodayCounts();

  /// 加载最近打卡记录
  Future<void> loadRecentRecords({int limit = 5});

  /// 打卡 +1
  Future<bool> checkIn(String defId, {String? location});

  /// 创建活动定义
  Future<OperateResult<String>> createDefinition(String name, String emoji, int color);

  /// 更新活动定义
  Future<bool> updateDefinition(ActivityDefinitionVO vo);

  /// 删除活动定义
  Future<bool> deleteDefinition(String id);
}
```

## 七、验证测试点

1. 在「我的」页面看到"活动打卡"入口图标
2. 点击进入打卡主页，看到预制活动的网格
3. 点击活动格子，今日次数 +1，且有动画反馈
4. 新建活动定义（名称、Emoji、颜色），出现在网格中
5. 长按活动可编辑/删除
6. 切换账本后看到不同的活动定义和打卡记录
7. 记账页看到最近打卡记录
8. 在 UI 配置页可开关「我的」页入口显示
9. 数据迁移正常（schemaVersion 6 → 7）

## 八、与旧模块的关系

- `ActivityRecord` 表保留并扩展，旧记录不受影响（`activityDefId` 为 null）
- `activity_list_view.dart`、`activity_calendar_view.dart` 等旧组件保留不动
- `ActivityProvider` 保留不动，新增 `ActivityCheckinProvider` 独立管理打卡逻辑
