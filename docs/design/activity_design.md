# 活动记录模块设计方案

## 一、背景

用户需要在记账应用内随手记录每天做了什么事情，并能够按周/月统计每项活动的重复次数。活动记录绑定到账本，支持地点记录和活动名称的自动补全。

## 二、模块介绍

### 2.1 功能概述

| 功能 | 说明 |
|------|------|
| 记录活动 | 记录某天做的活动：活动名称、日期、地点（可选） |
| 活动列表 | 按日期分组展示活动记录 |
| 活动统计 | 按周/月统计每项活动的次数 |
| 自动补全 | 活动名称输入时自动补全历史记录 |
| 快速记录 | 通过 +1 操作快速新增一条记录 |
| 删除活动 | 删除单条活动记录 |

### 2.2 模块特性

- **绑定账本**：活动记录与账本关联，切换账本看到不同的活动记录
- **日期维度**：以日期为核心维度记录，支持按日期范围筛选
- **日志驱动**：使用项目统一的日志驱动模式，数据变更记录到 log_sync_table
- **轻量集成**：不新增底部 Tab，集成在"记事"页面中通过 SegmentedButton 切换

### 2.3 名词约定

| 术语 | 说明 |
|------|------|
| 活动 (Activity) | 用户做的某件事，如"跑步"、"看书" |
| 活动记录 (ActivityRecord) | 一条具体的活动记录，包含活动名称、日期、地点 |

## 三、数据结构设计

### 3.1 数据库表设计

```dart
// lib/database/tables/activity_record_table.dart

/// 活动记录表
@DataClassName('ActivityRecord')
class ActivityRecordTable extends BaseAccountBookTable {
  /// 活动名称 (如：跑步、看书)
  TextColumn get activityName => text().named('activity_name')();

  /// 地点 (可选，自由文本)
  TextColumn get location => text().named('location').nullable()();

  /// 活动日期 (yyyy-MM-dd 格式)
  TextColumn get recordDate => text().named('record_date')();

  /// 每日最大打卡次数 (null=不限制)
  IntColumn get maxDailyCount => integer().named('max_daily_count').nullable()();
}
```

**表字段说明：**

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | TEXT | 是 | 唯一标识 (UUID) |
| account_book_id | TEXT | 是 | 所属账本ID |
| activity_name | TEXT | 是 | 活动名称 |
| location | TEXT | 否 | 地点 |
| record_date | TEXT | 是 | 活动日期 (yyyy-MM-dd) |
| max_daily_count | INTEGER | 否 | 每日最大打卡次数 (null=不限制) |
| created_at | INTEGER | 是 | 创建时间 (毫秒时间戳) |
| updated_at | INTEGER | 是 | 更新时间 (毫秒时间戳) |
| created_by | TEXT | 是 | 创建人ID |
| updated_by | TEXT | 是 | 更新人ID |

### 3.2 值对象 (VO)

```dart
// lib/models/vo/activity_record_vo.dart

class ActivityRecordVO {
  final String id;
  final String accountBookId;
  final String activityName;
  final String? location;
  final String recordDate; // yyyy-MM-dd
  final int? maxDailyCount; // null=不限制
  final int createdAt;
  final int updatedAt;
  final String createdBy;
  final String updatedBy;

  const ActivityRecordVO({...});

  factory ActivityRecordVO.fromEntity(ActivityRecord entity) {
    return ActivityRecordVO(
      id: entity.id,
      accountBookId: entity.accountBookId,
      activityName: entity.activityName,
      location: entity.location,
      recordDate: entity.recordDate,
      maxDailyCount: entity.maxDailyCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }
}
```

```dart
// lib/models/vo/activity_statistic_vo.dart

/// 活动统计VO — 用于周/月统计视图
class ActivityStatisticVO {
  final String activityName;
  final int count;

  const ActivityStatisticVO({
    required this.activityName,
    required this.count,
  });
}
```

### 3.3 BusinessType 枚举

```dart
// lib/enums/business_type.dart 新增
activity('activity'),
```

## 四、文件清单

| 层级 | 文件路径 | 说明 |
|------|----------|------|
| 数据库 | `lib/database/tables/activity_record_table.dart` | 表定义 |
| 数据库 | `lib/database/dao/activity_record_dao.dart` | DAO层 |
| 数据库 | `lib/database/database.dart` | 注册到 Drift 数据库，schemaVersion 3→4 |
| 枚举 | `lib/enums/business_type.dart` | 添加 activity 业务类型 |
| 模型 | `lib/models/vo/activity_record_vo.dart` | 活动记录VO |
| 模型 | `lib/models/vo/activity_statistic_vo.dart` | 统计VO |
| 驱动接口 | `lib/drivers/data_driver.dart` | 定义活动记录相关接口 |
| 驱动实现 | `lib/drivers/special/log.data_driver.dart` | 实现活动记录相关方法 |
| 日志构建器 | `lib/drivers/special/log/builder/activity_record.builder.dart` | 日志驱动构建器 |
| Builder注册 | `lib/drivers/special/log/builder/builder.dart` | 注册 ActivityRecordCULog |
| Provider | `lib/providers/activity_provider.dart` | 状态管理 |
| 事件 | `lib/events/special/event_book.dart` | 添加 ActivityChangedEvent |
| 同步 | `lib/providers/sync_provider.dart` | 订阅活动变更事件 |
| DAO注册 | `lib/manager/dao_manager.dart` | 注册 ActivityRecordDao |
| Provider注册 | `lib/manager/provider_manager.dart` | 注册 ActivityProvider |
| 视图 | `lib/widgets/activity/activity_list_view.dart` | 活动记录列表组件 |
| 视图 | `lib/widgets/activity/activity_statistic_view.dart` | 活动统计组件 |
| 视图 | `lib/widgets/activity/activity_add_sheet.dart` | 添加活动底部弹窗 |
| 入口 | `lib/pages/tabs/notes_tab.dart` | 添加"笔记/活动"切换 |

## 五、UX/UI 页面设计

### 5.1 入口设计

在"记事"（Notes）页面顶部添加 SegmentedButton 切换：

```
┌──────────────────────────────────┐
│  记事                     [搜索] │
├──────────────────────────────────┤
│  [ 笔记  |  活动  ]              │ ← SegmentedButton 切换
├──────────────────────────────────┤
│  (笔记/活动内容区域)              │
└──────────────────────────────────┘
```

### 5.2 活动列表视图

```
┌──────────────────────────────────┐
│  ← 活动              [+添加]     │ ← 右上角添加按钮
├──────────────────────────────────┤
│  [周] [月] [全部]                │ ← 时间范围切换
├──────────────────────────────────┤
│  2026-05-14 (今天)               │
│  ├─ 跑步  🏃  公园              │
│  │  (9:30)                       │ ← 时间显示 + 滑动删除
│  ├─ 跑步  🏃  健身房            │
│  │  (15:00)                      │
│  └─ 看书  📖  家                │
│     (21:00)                      │
│                                  │
│  2026-05-13 (昨天)               │
│  ├─ 看书  📖  家                │
│  │  (20:00)                      │
│  └─ 冥想  🧘                    │
│     (07:30)                      │
└──────────────────────────────────┘
```

**页面特点：**
- 按日期分组展示，最新日期在上
- 每天的活动列表，展示：活动名称 + 地点
- 右侧显示记录时间（createdAt 格式化）
- 支持滑动删除
- 时间范围切换：周/月/全部

### 5.3 添加活动弹窗

```
┌──────────────────────────────────┐
│  记录活动             [取消]     │
├──────────────────────────────────┤
│                                  │
│  日期                            │
│  ┌────────────────────────────┐  │
│  │  2026-05-14     [📅]       │  │ ← 日期选择
│  └────────────────────────────┘  │
│                                  │
│  活动名称 *                      │
│  ┌────────────────────────────┐  │
│  │  跑步                      │  │ ← 输入时自动补全
│  │  ──────────                │  │
│  │  🏃 跑步                  │  │ ← 历史活动名称下拉
│  │  📖 看书                  │  │
│  │  🧘 冥想                  │  │
│  │  🏊 游泳                  │  │
│  └────────────────────────────┘  │
│                                  │
│  地点 (可选)                     │
│  ┌────────────────────────────┐  │
│  │  公园                      │  │ ← 自由文本，可选
│  └────────────────────────────┘  │
│                                  │
│  每日打卡上限 (可选)             │
│  ┌────────────────────────────┐  │
│  │  不限制          [▼]       │  │ ← 下拉: 不限制/1次/2次/...
│  └────────────────────────────┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │      + 记录活动            │  │ ← 按钮
│  └────────────────────────────┘  │
│                                  │
└──────────────────────────────────┘
```

**弹窗字段：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| 日期 | DatePicker | 是 | 默认今天 |
| 活动名称 | 文本 + 自动补全 | 是 | 输入时自动匹配历史记录 |
| 地点 | 文本 | 否 | 自由输入 |
| 每日打卡上限 | 下拉选择 | 否 | 不限制/1次/2次/...，默认不限制 |

### 5.4 统计视图

```
┌──────────────────────────────────┐
│  ← 活动                          │
├──────────────────────────────────┤
│  [列表] [统计]                   │ ← 子页切换
├──────────────────────────────────┤
│  2026年 第20周                    │
│  ◀         2026-05-11 ~ 05-17  ▶│ ← 上/下周切换
├──────────────────────────────────┤
│  活动              次数          │
│  ─────────────────────           │
│  🏃 跑步            5           │
│  📖 看书            3           │
│  🧘 冥想            2           │
│  🏊 游泳            1           │
│                                  │
│             共 11 次             │
└──────────────────────────────────┘
```

**统计视图特点：**
- 时间范围可切换 周/月
- 使用 ◀ ▶ 按钮切换前一周/月
- 每项活动显示名称 + 次数，按次数降序排列
- 底部显示总次数

## 六、技术实现要点

### 6.1 DataDriver 接口定义

```dart
// lib/drivers/data_driver.dart

/// 活动记录相关

/// 创建活动记录
Future<OperateResult<String>> createActivityRecord(
  String userId,
  String bookId, {
  required String activityName,
  required String recordDate, // yyyy-MM-dd
  String? location,
  int? maxDailyCount, // null=不限制
});

/// 删除活动记录
Future<OperateResult<void>> deleteActivityRecord(
  String userId, String bookId, String recordId);

/// 获取活动记录列表（按日期范围筛选）
Future<OperateResult<List<ActivityRecordVO>>> listActivityRecordsByBook(
  String userId, String bookId, {
  int limit = 200,
  int offset = 0,
  String? startDate, // yyyy-MM-dd
  String? endDate,   // yyyy-MM-dd
});

/// 获取去重的活动名称列表（用于自动补全）
Future<OperateResult<List<String>>> listDistinctActivityNames(
  String userId, String bookId);

/// 获取活动统计（按活动名聚合）
Future<OperateResult<List<ActivityStatisticVO>>> getActivityStatistics(
  String userId, String bookId, {
  required String startDate,
  required String endDate,
});
```

### 6.2 DAO 查询方法

```dart
// lib/database/dao/activity_record_dao.dart

class ActivityRecordDao extends BaseBookDao<ActivityRecordTable, ActivityRecord> {
  ActivityRecordDao(super.db);

  @override
  TableInfo<ActivityRecordTable, ActivityRecord> get table => db.activityRecordTable;

  /// 按日期范围查询
  Future<List<ActivityRecord>> listByDateRange(
    String bookId,
    String startDate,
    String endDate, {
    int? limit,
    int? offset,
  }) {
    final query = (db.select(table)
      ..where((t) =>
          t.accountBookId.equals(bookId) &
          t.recordDate.isBetween(startDate, endDate))
      ..orderBy([(t) => OrderingTerm.desc(t.recordDate), (t) => OrderingTerm.desc(t.createdAt)]));
    if (limit != null) query.limit(limit, offset: offset);
    return query.get();
  }

  /// 获取去重的活动名称
  Future<List<String>> listDistinctActivityNames(String bookId) {
    final query = db.selectOnly(table)
      ..addColumns([table.activityName])
      ..where(table.accountBookId.equals(bookId))
      ..groupBy([table.activityName])
      ..orderBy([OrderingTerm.asc(table.activityName)]);
    return query.get().then((rows) => rows.map((r) => r.read(table.activityName)!).toList());
  }

  /// 按活动名聚合统计
  Future<List<({String activityName, int count})>> countByDateRange(
    String bookId,
    String startDate,
    String endDate,
  ) {
    final query = db.selectOnly(table)
      ..addColumns([table.activityName, table.id.count()])
      ..where(table.accountBookId.equals(bookId) & table.recordDate.isBetween(startDate, endDate))
      ..groupBy([table.activityName])
      ..orderBy([OrderingTerm.desc(table.id.count())]);
    return query.get().then((rows) => rows.map((r) => (
      activityName: r.read(table.activityName)!,
      count: r.read(table.id.count())!,
    )).toList());
  }
}
```

### 6.3 活动名称自动补全

从 DAO 获取当前账本的去重活动名称列表，使用 `Autocomplete` widget 或自定义下拉实现：

```dart
// Provider 中缓存活动名称列表
List<String> _activityNames = [];
List<String> get activityNames => _activityNames;

Future<void> loadActivityNames() async {
  final result = await DriverFactory.driver
      .listDistinctActivityNames(AppConfigManager.instance.userId, _currentBookId!);
  if (result.ok) {
    _activityNames = result.data ?? [];
    notifyListeners();
  }
}
```

### 6.4 日志构建器

```dart
class ActivityRecordCULog extends LogBuilder<ActivityRecordTableCompanion, String> {
  ActivityRecordCULog() : super() {
    doWith(BusinessType.activity);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.activityRecordDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.activityRecordDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.activityRecordDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return ActivityRecordTable.toJsonString(data as ActivityRecordTableCompanion);
  }

  /// 创建
  static ActivityRecordCULog create({
    required String who,
    required String bookId,
    required String activityName,
    required String recordDate,
    String? location,
    int? maxDailyCount,
  }) {
    return ActivityRecordCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(ActivityRecordTable.toCreateCompanion(
          who,
          activityName: activityName,
          recordDate: recordDate,
          location: location,
          maxDailyCount: maxDailyCount,
        )) as ActivityRecordCULog;
  }

  /// 删除
  static ActivityRecordCULog delete({
    required String who,
    required String id,
  }) {
    return ActivityRecordCULog()
        .who(who)
        .target(id)
        .doDelete() as ActivityRecordCULog;
  }

  // ... fromLog 恢复逻辑（按标准模式）
}
```

注意：活动记录不需要 update 操作，只支持 create 和 delete。

### 6.5 数据流向

```
UI层 (NotesTab)
    ↓ ↑
Provider层 (ActivityProvider)
    ↓ ↑
Driver层 (LogDataDriver)
    ↓ ↑
日志构建器 (ActivityRecordCULog)
    ↓ ↑
DAO层 (ActivityRecordDao)
    ↓ ↑
Database层 (ActivityRecordTable)
```

### 6.6 与记事页面的集成

```dart
// lib/pages/tabs/notes_tab.dart

class _NotesTabState extends State<NotesTab> {
  bool _showActivities = false; // false=笔记, true=活动

  @override
  Widget build(BuildContext context) {
    // ...
    return Scaffold(
      appBar: CommonAppBar(
        title: SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text('笔记')),
            ButtonSegment(value: true, label: Text('活动')),
          ],
          selected: {_showActivities},
          onSelectionChanged: (selected) {
            setState(() => _showActivities = selected.first);
          },
        ),
      ),
      body: _showActivities ? _buildActivityView() : _buildNotesView(),
    );
  }
}
```

### 6.7 事件定义

```dart
// lib/events/special/event_book.dart

/// 活动记录变动事件
class ActivityChangedEvent {
  final ActivityRecordVO record;
  final OperateType operateType;
  const ActivityChangedEvent(this.operateType, this.record);
}
```

### 6.8 Provider 核心逻辑

```dart
class ActivityProvider extends ChangeNotifier {
  final List<ActivityRecordVO> _records = [];
  List<ActivityRecordVO> get records => _records;

  List<ActivityStatisticVO> _statistics = [];
  List<ActivityStatisticVO> get statistics => _statistics;

  /// 统计模式: week / month
  String _statMode = 'week';
  String get statMode => _statMode;

  /// 当前统计的偏移（0=本周/月，-1=上周/上月）
  int _statOffset = 0;
  int get statOffset => _statOffset;
  
  /// 自动补全的活动名称列表
  List<String> _activityNames = [];
  List<String> get activityNames => _activityNames;

  /// 加载记录
  Future<void> loadRecords(...);
  
  /// 加载统计
  Future<void> loadStatistics(...);

  /// 创建记录
  Future<OperateResult<String>> createRecord(...);

  /// 删除记录
  Future<bool> deleteRecord(String id);

  /// 检查今日打卡是否已达上限
  Future<bool> isDailyLimitReached(String activityName, String date);

  /// 获取活动的每日上限
  int? getActivityDailyLimit(String activityName);
}
```

### 6.9 统计的周/月日期范围计算

```
当前周: DateTime.now() 所在周，周一 ~ 周日
当前月: DateTime.now() 所在月，1日 ~ 月末
前一周/月: statOffset -= 1，对应偏移
```

### 6.10 每日打卡上限校验逻辑

创建记录时 Provider 校验逻辑：

```dart
Future<OperateResult<String>> createRecord({
  required String activityName,
  required String recordDate,
  String? location,
  int? maxDailyCount,
}) async {
  // 1. 设置每日上限（首次创建时）
  if (maxDailyCount != null) {
    _dailyLimits[activityName] = maxDailyCount;
  }

  // 2. 校验今日是否已达上限
  final limit = _dailyLimits[activityName];
  if (limit != null) {
    final todayCount = _records.where((r) =>
        r.activityName == activityName && r.recordDate == recordDate).length;
    if (todayCount >= limit) {
      return OperateResult.fail('已达每日打卡上限 ($limit 次)');
    }
  }

  // 3. 创建记录
  final result = await DriverFactory.driver.createActivityRecord(
    AppConfigManager.instance.userId,
    _currentBookId!,
    activityName: activityName,
    recordDate: recordDate,
    location: location,
    maxDailyCount: maxDailyCount,
  );
  if (result.ok) {
    await loadRecords();
    _activityNames = await _loadDistinctNames();
  }
  return result;
}
```

注意：每日上限以活动名称+账本为粒度。首次为某活动设置上限后，后续该活动的上线由 Provider 中缓存的 _dailyLimits 维护。上限可在 +1 快速记录时一并校验。

## 七、数据迁移

将 `AppDatabase.schemaVersion` 从 3 提升到 4，在 `onUpgrade` 中添加：

```dart
if (from < 4) {
  // 版本3到版本4的迁移：添加活动记录表
  await m.create(activityRecordTable);
}
```

## 八、验证测试点

1. **创建活动**：选择日期、输入活动名称、可选地点，成功创建记录
2. **自动补全**：输入活动名称时显示历史活动名称列表
3. **+1 快速记录**：在列表页点击 +1 直接创建同活动名&同日的记录
4. **列表展示**：按日期分组，最新日期在上，每天按时间倒序
5. **滑动删除**：可滑动删除单条记录
6. **周统计**：选择周模式，正确统计该周每项活动的次数
7. **月统计**：选择月模式，正确统计该月每项活动的次数
8. **上下周/月切换**：◀ ▶ 切换正常，数据正确
9. **账本隔离**：切换账本后看到不同的活动记录
10. **与笔记共存**：SegmentedButton 切换正常，笔记和活动各自独立
11. **每日上限**：设置每日3次，记录3条后第4条创建失败并提示已达上限
12. **无上限默认**：不设置每日打卡上限，可无限创建记录
