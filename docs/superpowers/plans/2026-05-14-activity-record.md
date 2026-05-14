# 活动记录模块实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在"记事"页面集成活动记录模块，支持按日期记录活动（名称+地点），并按周/月统计活动次数。

**Architecture:** 遵循项目日志驱动模式，按表→DAO→LogBuilder→DataDriver→Provider→UI 分层实现。活动记录绑定到账本，集成在记事页通过 SegmentedButton 切换。

**Tech Stack:** Flutter, Drift (SQLite), Provider, 日志驱动 (LogBuilder)

---

### Task 1: BusinessType 枚举 + 表定义 + DAO + 数据库注册

**Files:**
- Modify: `lib/enums/business_type.dart`
- Create: `lib/database/tables/activity_record_table.dart`
- Create: `lib/database/dao/activity_record_dao.dart`
- Modify: `lib/database/database.dart`
- Modify: `lib/manager/dao_manager.dart`

- [ ] **Step 1.1: 添加 activity 到 BusinessType 枚举**

在 `lib/enums/business_type.dart` 中 `giftCard('giftCard')` 之后添加：

```dart
/// 活动
activity('activity'),
```

- [ ] **Step 1.2: 创建活动记录表定义**

创建 `lib/database/tables/activity_record_table.dart`：

```dart
import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 活动记录表
@DataClassName('ActivityRecord')
class ActivityRecordTable extends BaseAccountBookTable {
  /// 活动名称 (如：跑步、看书)
  TextColumn get activityName => text().named('activity_name')();

  /// 地点 (可选)
  TextColumn get location => text().named('location').nullable()();

  /// 活动日期 (yyyy-MM-dd)
  TextColumn get recordDate => text().named('record_date')();

  /// 创建Companion
  static ActivityRecordTableCompanion toCreateCompanion(
    String who, {
    required String accountBookId,
    required String activityName,
    required String recordDate,
    String? location,
  }) {
    return ActivityRecordTableCompanion(
      id: Value(IdUtil.genId()),
      accountBookId: Value(accountBookId),
      activityName: Value(activityName),
      recordDate: Value(recordDate),
      location: Value.absentIfNull(location),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(ActivityRecordTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'activityName', companion.activityName);
    MapUtil.setIfPresent(map, 'recordDate', companion.recordDate);
    MapUtil.setIfPresent(map, 'location', companion.location);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    return jsonEncode(map);
  }

  /// 从JSON对象创建Companion（用于日志恢复）
  static ActivityRecordTableCompanion fromJson(Map<String, dynamic> json) {
    return ActivityRecordTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      accountBookId: json['accountBookId'] != null ? Value(json['accountBookId'] as String) : const Value.absent(),
      activityName: json['activityName'] != null ? Value(json['activityName'] as String) : const Value.absent(),
      recordDate: json['recordDate'] != null ? Value(json['recordDate'] as String) : const Value.absent(),
      location: json['location'] != null ? Value(json['location'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
    );
  }
}
```

注意：活动记录不需要 update，所以不提供 toUpdateCompanion。

- [ ] **Step 1.3: 创建 DAO**

创建 `lib/database/dao/activity_record_dao.dart`：

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/activity_record_table.dart';
import 'base_dao.dart';

class ActivityRecordDao extends BaseBookDao<ActivityRecordTable, ActivityRecord> {
  ActivityRecordDao(super.db);

  @override
  TableInfo<ActivityRecordTable, ActivityRecord> get table => db.activityRecordTable;

  @override
  List<OrderClauseGenerator<ActivityRecordTable>> defaultOrderBy() {
    return [
      (t) => OrderingTerm.desc(t.recordDate),
      (t) => OrderingTerm.desc(t.createdAt),
    ];
  }

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

  /// 获取去重的活动名称列表（用于自动补全）
  Future<List<String>> listDistinctActivityNames(String bookId) {
    final query = db.selectOnly(table)
      ..addColumns([table.activityName])
      ..where(table.accountBookId.equals(bookId))
      ..groupBy([table.activityName])
      ..orderBy([OrderingTerm.asc(table.activityName)]);
    return query.get().then((rows) => rows.map((r) => r.read(table.activityName)!).toList());
  }

  /// 按活动名聚合统计指定日期范围内的次数
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

- [ ] **Step 1.4: 注册到 Database**

修改 `lib/database/database.dart`：

a) 导入 ActivityRecordTable：
```dart
import 'tables/activity_record_table.dart';
```

b) 在 `@DriftDatabase` 的 tables 列表中添加 `ActivityRecordTable`：
```dart
@DriftDatabase(
  tables: [
    // ... 现有表
    GiftCardTable,
    ActivityRecordTable,
  ],
)
```

c) 添加 DAO 声明：
```dart
// 在 _$AppDatabase 抽象类中添加
ActivityRecordDao get activityRecordDao;
```

d) 升级 schema 版本 3→4：
```dart
@override
int get schemaVersion => 4;
```

e) 在 onUpgrade 中添加 v3→v4 迁移：
```dart
if (from < 4) {
  // 版本3到版本4的迁移：添加 activity_record_table
  await m.create(activityRecordTable);
}
```

- [ ] **Step 1.5: 注册到 DaoManager**

修改 `lib/manager/dao_manager.dart`：

```dart
import '../database/dao/activity_record_dao.dart';

// 添加属性
static late ActivityRecordDao activityRecordDao;

// 在 refreshDaos() 中添加
activityRecordDao = ActivityRecordDao(DatabaseManager.db);
```

- [ ] **Step 1.6: 确认编译通过**

Run: `flutter analyze lib/database/tables/activity_record_table.dart lib/database/dao/activity_record_dao.dart`
Expected: 无错误（忽略生成代码相关错误）

---

### Task 2: VO 模型 + 事件定义

**Files:**
- Create: `lib/models/vo/activity_record_vo.dart`
- Create: `lib/models/vo/activity_statistic_vo.dart`
- Modify: `lib/events/special/event_book.dart`

- [ ] **Step 2.1: 创建 ActivityRecordVO**

创建 `lib/models/vo/activity_record_vo.dart`：

```dart
import '../../database/database.dart';

class ActivityRecordVO {
  final String id;
  final String accountBookId;
  final String activityName;
  final String? location;
  final String recordDate;
  final int createdAt;
  final int updatedAt;
  final String createdBy;
  final String updatedBy;

  const ActivityRecordVO({
    required this.id,
    required this.accountBookId,
    required this.activityName,
    this.location,
    required this.recordDate,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  factory ActivityRecordVO.fromEntity(ActivityRecord entity) {
    return ActivityRecordVO(
      id: entity.id,
      accountBookId: entity.accountBookId,
      activityName: entity.activityName,
      location: entity.location,
      recordDate: entity.recordDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }
}
```

- [ ] **Step 2.2: 创建 ActivityStatisticVO**

创建 `lib/models/vo/activity_statistic_vo.dart`：

```dart
class ActivityStatisticVO {
  final String activityName;
  final int count;

  const ActivityStatisticVO({
    required this.activityName,
    required this.count,
  });
}
```

- [ ] **Step 2.3: 添加 ActivityChangedEvent**

修改 `lib/events/special/event_book.dart`：

```dart
import '../../models/vo/activity_record_vo.dart';

/// 活动记录变动事件
class ActivityChangedEvent {
  final ActivityRecordVO record;
  final OperateType operateType;
  const ActivityChangedEvent(this.operateType, this.record);
}
```

---

### Task 3: 日志构建器

**Files:**
- Create: `lib/drivers/special/log/builder/activity_record.builder.dart`
- Modify: `lib/drivers/special/log/builder/builder.dart`

- [ ] **Step 3.1: 创建 ActivityRecordCULog**

创建 `lib/drivers/special/log/builder/activity_record.builder.dart`：

```dart
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../database/database.dart';
import '../../../../database/tables/activity_record_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

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

  /// 从日志恢复
  static ActivityRecordCULog fromLog(LogSync log) {
    final operateType = OperateType.fromCode(log.operateType);
    if (operateType == OperateType.create) {
      return ActivityRecordCULog()
          .who(log.operatorId)
          .target(log.businessId)
          .doCreate()
          .withData(_parseCompanion(jsonDecode(log.operateData))) as ActivityRecordCULog;
    }
    return ActivityRecordCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doDelete() as ActivityRecordCULog;
  }

  /// 创建
  static ActivityRecordCULog create({
    required String who,
    required String bookId,
    required String activityName,
    required String recordDate,
    String? location,
  }) {
    return ActivityRecordCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(ActivityRecordTable.toCreateCompanion(
          who,
          accountBookId: bookId,
          activityName: activityName,
          recordDate: recordDate,
          location: location,
        )) as ActivityRecordCULog;
  }

  /// 删除
  static ActivityRecordCULog delete({
    required String who,
    required String bookId,
    required String id,
  }) {
    return ActivityRecordCULog()
        .who(who)
        .inBook(bookId)
        .target(id)
        .doDelete() as ActivityRecordCULog;
  }

  /// 解析JSON为Companion
  static ActivityRecordTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return ActivityRecordTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      accountBookId: json['accountBookId'] != null ? Value(json['accountBookId'] as String) : const Value.absent(),
      activityName: json['activityName'] != null ? Value(json['activityName'] as String) : const Value.absent(),
      recordDate: json['recordDate'] != null ? Value(json['recordDate'] as String) : const Value.absent(),
      location: json['location'] != null ? Value(json['location'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
    );
  }
}
```

注意：活动记录不支持 update，所以只有 create 和 delete。

- [ ] **Step 3.2: 注册到 builder.dart**

修改 `lib/drivers/special/log/builder/builder.dart`：

```dart
import 'activity_record.builder.dart';

// 在 _fromLog 的 switch 中添加 case
case BusinessType.activity:
  return ActivityRecordCULog.fromLog(log) as LogBuilder<T, RunResult>;
```

---

### Task 4: DataDriver 接口 + 实现

**Files:**
- Modify: `lib/drivers/data_driver.dart`
- Modify: `lib/drivers/special/log.data_driver.dart`

- [ ] **Step 4.1: 添加 Driver 接口方法**

在 `lib/drivers/data_driver.dart` 中，礼物卡相关之后添加：

```dart
import 'models/vo/activity_record_vo.dart';
import 'models/vo/activity_statistic_vo.dart';

// ============ 活动记录相关 ============

/// 创建活动记录
Future<OperateResult<String>> createActivityRecord(
  String userId,
  String bookId, {
  required String activityName,
  required String recordDate,
  String? location,
});

/// 删除活动记录
Future<OperateResult<void>> deleteActivityRecord(
  String userId, String bookId, String recordId);

/// 获取活动记录列表（按日期范围筛选）
Future<OperateResult<List<ActivityRecordVO>>> listActivityRecordsByBook(
  String userId, String bookId, {
  int limit = 200,
  int offset = 0,
  String? startDate,
  String? endDate,
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

- [ ] **Step 4.2: 实现 LogDataDriver 方法**

在 `lib/drivers/special/log.data_driver.dart` 中，礼物卡相关实现之后添加：

```dart
import '../../models/vo/activity_record_vo.dart';
import '../../models/vo/activity_statistic_vo.dart';
import 'log/builder/activity_record.builder.dart';

// ============ 活动记录相关 ============

@override
Future<OperateResult<String>> createActivityRecord(
  String userId,
  String bookId, {
  required String activityName,
  required String recordDate,
  String? location,
}) async {
  try {
    final logBuilder = ActivityRecordCULog.create(
      who: userId,
      bookId: bookId,
      activityName: activityName,
      recordDate: recordDate,
      location: location,
    );
    final id = await logBuilder.execute();
    return OperateResult.success(id);
  } catch (e) {
    return OperateResult.failWithMessage(
        message: '创建活动记录失败：$e', exception: e as Exception);
  }
}

@override
Future<OperateResult<void>> deleteActivityRecord(
    String userId, String bookId, String recordId) async {
  try {
    await ActivityRecordCULog.delete(who: userId, id: recordId).execute();
    return OperateResult.success(null);
  } catch (e) {
    return OperateResult.failWithMessage(
        message: '删除活动记录失败：$e', exception: e as Exception);
  }
}

@override
Future<OperateResult<List<ActivityRecordVO>>> listActivityRecordsByBook(
  String userId, String bookId, {
  int limit = 200,
  int offset = 0,
  String? startDate,
  String? endDate,
}) async {
  try {
    List<ActivityRecord> records;
    if (startDate != null && endDate != null) {
      records = await DaoManager.activityRecordDao
          .listByDateRange(bookId, startDate, endDate, limit: limit, offset: offset);
    } else {
      records = await DaoManager.activityRecordDao
          .listByBook(bookId, limit: limit, offset: offset);
    }
    final vos = records.map((e) => ActivityRecordVO.fromActivityRecord(e)).toList();
    return OperateResult.success(vos);
  } catch (e) {
    return OperateResult.failWithMessage(
        message: '获取活动记录列表失败：$e', exception: e as Exception);
  }
}

@override
Future<OperateResult<List<String>>> listDistinctActivityNames(
    String userId, String bookId) async {
  try {
    final names = await DaoManager.activityRecordDao.listDistinctActivityNames(bookId);
    return OperateResult.success(names);
  } catch (e) {
    return OperateResult.failWithMessage(
        message: '获取活动名称列表失败：$e', exception: e as Exception);
  }
}

@override
Future<OperateResult<List<ActivityStatisticVO>>> getActivityStatistics(
  String userId, String bookId, {
  required String startDate,
  required String endDate,
}) async {
  try {
    final results = await DaoManager.activityRecordDao
        .countByDateRange(bookId, startDate, endDate);
    final vos = results.map((r) => ActivityStatisticVO(
      activityName: r.activityName,
      count: r.count,
    )).toList();
    return OperateResult.success(vos);
  } catch (e) {
    return OperateResult.failWithMessage(
        message: '获取活动统计失败：$e', exception: e as Exception);
  }
}
```

---

### Task 5: Provider

**Files:**
- Create: `lib/providers/activity_provider.dart`

- [ ] **Step 5.1: 创建 ActivityProvider**

创建 `lib/providers/activity_provider.dart`：

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../events/event_bus.dart';
import '../events/special/event_book.dart';
import '../events/special/event_sync.dart';
import '../manager/app_config_manager.dart';
import '../models/common.dart';
import '../models/vo/activity_record_vo.dart';
import '../models/vo/activity_statistic_vo.dart';

class ActivityProvider extends ChangeNotifier {
  late final StreamSubscription _bookSubscription;
  late final StreamSubscription _syncSubscription;
  late final StreamSubscription _activityChangedSubscription;

  /// 活动记录列表
  final List<ActivityRecordVO> _records = [];
  List<ActivityRecordVO> get records => _records;

  /// 是否加载中
  bool _loading = false;
  bool get loading => _loading;

  /// 统计结果
  List<ActivityStatisticVO> _statistics = [];
  List<ActivityStatisticVO> get statistics => _statistics;

  bool _statisticsLoading = false;
  bool get statisticsLoading => _statisticsLoading;

  /// 统计模式: week / month
  String _statMode = 'week';
  String get statMode => _statMode;

  /// 当前统计的偏移（0=本周/月，-1=上周/上月）
  int _statOffset = 0;
  int get statOffset => _statOffset;

  /// 自动补全的活动名称列表
  List<String> _activityNames = [];
  List<String> get activityNames => _activityNames;

  String? _currentBookId;

  ActivityProvider() {
    _currentBookId = AppConfigManager.instance.defaultBookId;

    _bookSubscription = EventBus.instance.on<BookChangedEvent>((event) {
      _currentBookId = event.book.id;
      loadRecords();
      loadActivityNames();
    });

    _syncSubscription = EventBus.instance.on<SyncCompletedEvent>((event) {
      loadRecords();
      loadActivityNames();
    });

    _activityChangedSubscription = EventBus.instance.on<ActivityChangedEvent>((event) {
      loadRecords();
    });
  }

  @override
  void dispose() {
    _bookSubscription.cancel();
    _syncSubscription.cancel();
    _activityChangedSubscription.cancel();
    super.dispose();
  }

  /// 计算周一起始/周日结束日期
  static ({String start, String end}) _getWeekRange(int offset) {
    final now = DateTime.now();
    // 计算当前周周一
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final targetMonday = monday.add(Duration(days: 7 * offset));
    final targetSunday = targetMonday.add(const Duration(days: 6));
    return (
      start: '${targetMonday.year}-${targetMonday.month.toString().padLeft(2, '0')}-${targetMonday.day.toString().padLeft(2, '0')}',
      end: '${targetSunday.year}-${targetSunday.month.toString().padLeft(2, '0')}-${targetSunday.day.toString().padLeft(2, '0')}',
    );
  }

  /// 计算月起始/月末日期
  static ({String start, String end}) _getMonthRange(int offset) {
    final now = DateTime.now();
    final targetMonth = DateTime(now.year, now.month + offset, 1);
    final lastDay = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
    return (
      start: '${targetMonth.year}-${targetMonth.month.toString().padLeft(2, '0')}-01',
      end: '${targetMonth.year}-${targetMonth.month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}',
    );
  }

  /// 获取当前统计的日期范围标签
  String getStatDateLabel() {
    final range = _statMode == 'week' ? _getWeekRange(_statOffset) : _getMonthRange(_statOffset);
    return '${range.start} ~ ${range.end}';
  }

  /// 设置统计模式
  void setStatMode(String mode) {
    if (_statMode != mode) {
      _statMode = mode;
      _statOffset = 0;
      loadStatistics();
    }
  }

  /// 切换统计偏移（上一周/月或下一周/月）
  void setStatOffset(int offset) {
    _statOffset = offset;
    loadStatistics();
  }

  /// 加载活动记录
  Future<void> loadRecords() async {
    if (_loading || _currentBookId == null) return;
    _loading = true;
    try {
      final result = await DriverFactory.driver.listActivityRecordsByBook(
        AppConfigManager.instance.userId,
        _currentBookId!,
        limit: 200,
        offset: 0,
      );
      if (result.ok) {
        _records.clear();
        _records.addAll(result.data ?? []);
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 加载统计
  Future<void> loadStatistics() async {
    if (_currentBookId == null) return;
    _statisticsLoading = true;
    notifyListeners();
    try {
      final range = _statMode == 'week' ? _getWeekRange(_statOffset) : _getMonthRange(_statOffset);
      final result = await DriverFactory.driver.getActivityStatistics(
        AppConfigManager.instance.userId,
        _currentBookId!,
        startDate: range.start,
        endDate: range.end,
      );
      if (result.ok) {
        _statistics = result.data ?? [];
      }
    } finally {
      _statisticsLoading = false;
      notifyListeners();
    }
  }

  /// 加载活动名称列表（用于自动补全）
  Future<void> loadActivityNames() async {
    if (_currentBookId == null) return;
    final result = await DriverFactory.driver.listDistinctActivityNames(
      AppConfigManager.instance.userId,
      _currentBookId!,
    );
    if (result.ok) {
      _activityNames = result.data ?? [];
      notifyListeners();
    }
  }

  /// 创建活动记录
  Future<OperateResult<String>> createRecord({
    required String activityName,
    required String recordDate,
    String? location,
  }) async {
    if (_currentBookId == null) {
      return OperateResult.failWithMessage(message: '请先选择账本');
    }
    final result = await DriverFactory.driver.createActivityRecord(
      AppConfigManager.instance.userId,
      _currentBookId!,
      activityName: activityName,
      recordDate: recordDate,
      location: location,
    );
    if (result.ok) {
      await loadRecords();
      await loadActivityNames();
      final vo = ActivityRecordVO(
        id: result.data!,
        accountBookId: _currentBookId!,
        activityName: activityName,
        location: location,
        recordDate: recordDate,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        createdBy: AppConfigManager.instance.userId,
        updatedBy: AppConfigManager.instance.userId,
      );
      EventBus.instance.emit(ActivityChangedEvent(OperateType.create, vo));
    }
    return result;
  }

  /// 删除活动记录
  Future<bool> deleteRecord(ActivityRecordVO record) async {
    if (_currentBookId == null) return false;
    final result = await DriverFactory.driver.deleteActivityRecord(
      AppConfigManager.instance.userId,
      _currentBookId!,
      record.id,
    );
    if (result.ok) {
      _records.remove(record);
      notifyListeners();
      EventBus.instance.emit(ActivityChangedEvent(OperateType.delete, record));
    }
    return result.ok;
  }
}
```

---

### Task 6: Provider 注册 + Sync 订阅

**Files:**
- Modify: `lib/manager/provider_manager.dart`
- Modify: `lib/providers/sync_provider.dart`

- [ ] **Step 6.1: 注册 ActivityProvider**

修改 `lib/manager/provider_manager.dart`：

```dart
import '../providers/activity_provider.dart';

// 在 providers 列表中添加
ChangeNotifierProvider(create: (_) => ActivityProvider()),
```

- [ ] **Step 6.2: 订阅同步事件**

修改 `lib/providers/sync_provider.dart`，在 `_subscribeToEvents` 中添加：

```dart
import '../events/special/event_book.dart'; // 已有 ActivityChangedEvent 在其中

// 在 _subscribeToEvents 中添加
EventBus.instance.on<ActivityChangedEvent>(_handleActivityChanged),

// 添加 handler
void _handleActivityChanged(ActivityChangedEvent event) {
  syncData();
}
```

---

### Task 7: UI 组件

**Files:**
- Create: `lib/widgets/activity/activity_add_sheet.dart`
- Create: `lib/widgets/activity/activity_list_view.dart`
- Create: `lib/widgets/activity/activity_statistic_view.dart`

- [ ] **Step 7.1: 创建添加活动底部弹窗**

创建 `lib/widgets/activity/activity_add_sheet.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/activity_provider.dart';
import '../../models/common.dart';
import '../../utils/date_util.dart';

class ActivityAddSheet extends StatefulWidget {
  const ActivityAddSheet({super.key});

  @override
  State<ActivityAddSheet> createState() => _ActivityAddSheetState();
}

class _ActivityAddSheetState extends State<ActivityAddSheet> {
  late DateTime _selectedDate;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    // 加载活动名称列表用于自动补全
    context.read<ActivityProvider>().loadActivityNames();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String get _formattedDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      final result = await context.read<ActivityProvider>().createRecord(
        activityName: name,
        recordDate: _formattedDate,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
      );
      if (result.ok && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? '保存失败')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10nManager.l10n;
    final theme = Theme.of(context);
    final provider = context.watch<ActivityProvider>();

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('记录活动', style: theme.textTheme.titleMedium),
          const SizedBox(height: 20),

          // 日期
          Text('日期', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(_formattedDate),
                  const Spacer(),
                  Icon(Icons.calendar_today, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 活动名称 + 自动补全
          Text('活动名称 *', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Autocomplete<String>(
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return [];
              return provider.activityNames.where((name) =>
                  name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              // 同步外部 controller 和 Autocomplete 的 controller
              _nameController.text = controller.text;
              controller.addListener(() {
                _nameController.text = controller.text;
              });
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  hintText: '输入活动名称',
                  border: OutlineInputBorder(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // 地点
          Text('地点 (可选)', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              hintText: '输入地点',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // 保存按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('记录活动'),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 7.2: 创建活动记录列表视图**

创建 `lib/widgets/activity/activity_list_view.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/activity_provider.dart';
import '../../models/vo/activity_record_vo.dart';
import 'activity_add_sheet.dart';

class ActivityListView extends StatelessWidget {
  const ActivityListView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();
    final l10n = L10nManager.l10n;

    if (provider.loading && provider.records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.records.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('暂无活动记录', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => _showAddSheet(context),
              child: const Text('记录第一条活动'),
            ),
          ],
        ),
      );
    }

    // 按日期分组
    final grouped = <String, List<ActivityRecordVO>>{};
    for (final record in provider.records) {
      grouped.putIfAbsent(record.recordDate, () => []).add(record);
    }
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final records = grouped[date]!;
              final isToday = date == _todayStr();
              final isYesterday = date == _yesterdayStr();
              String label = date;
              if (isToday) label = '$date (今天)';
              else if (isYesterday) label = '$date (昨天)';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  ),
                  ...records.map((record) => _buildRecordTile(context, record, provider)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _todayStr() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _yesterdayStr() {
    final d = DateTime.now().subtract(const Duration(days: 1));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Widget _buildRecordTile(BuildContext context, ActivityRecordVO record, ActivityProvider provider) {
    final time = DateTime.fromMillisecondsSinceEpoch(record.createdAt);
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => provider.deleteRecord(record),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            record.activityName.isNotEmpty
                ? record.activityName[0]
                : '?',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(record.activityName),
        subtitle: record.location != null ? Text(record.location!) : null,
        trailing: Text(timeStr,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
      ),
    );
  }

  static void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ActivityAddSheet(),
    );
  }
}
```

- [ ] **Step 7.3: 创建统计视图**

创建 `lib/widgets/activity/activity_statistic_view.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/activity_provider.dart';
import '../../models/vo/activity_statistic_vo.dart';

class ActivityStatisticView extends StatefulWidget {
  const ActivityStatisticView({super.key});

  @override
  State<ActivityStatisticView> createState() => _ActivityStatisticViewState();
}

class _ActivityStatisticViewState extends State<ActivityStatisticView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ActivityProvider>();
    final theme = Theme.of(context);

    return Column(
      children: [
        // 模式切换 + 偏移切换
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 周/月切换
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'week', label: Text('周')),
                  ButtonSegment(value: 'month', label: Text('月')),
                ],
                selected: {provider.statMode},
                onSelectionChanged: (v) => provider.setStatMode(v.first),
              ),
              const Spacer(),
              // 上下切换
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => provider.setStatOffset(provider.statOffset - 1),
              ),
              Text(provider.getStatDateLabel(),
                style: theme.textTheme.bodySmall,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => provider.setStatOffset(provider.statOffset + 1),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // 统计列表
        Expanded(
          child: provider.statisticsLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.statistics.isEmpty
                  ? Center(
                      child: Text('该时段暂无活动记录',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                    )
                  : ListView.builder(
                      itemCount: provider.statistics.length + 1,
                      itemBuilder: (context, index) {
                        if (index == provider.statistics.length) {
                          final total = provider.statistics.fold<int>(
                            0, (sum, s) => sum + s.count);
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text('共 $total 次',
                                style: theme.textTheme.titleSmall),
                            ),
                          );
                        }
                        final stat = provider.statistics[index];
                        return _buildStatTile(stat, index, theme);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStatTile(ActivityStatisticVO stat, int index, ThemeData theme) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          stat.activityName.isNotEmpty ? stat.activityName[0] : '?',
          style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
        ),
      ),
      title: Text(stat.activityName),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('${stat.count} 次',
          style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
      ),
    );
  }
}
```

---

### Task 8: NotesTab 集成

**Files:**
- Modify: `lib/pages/tabs/notes_tab.dart`

- [ ] **Step 8.1: 修改 NotesTab 添加切换和活动视图**

修改 `lib/pages/tabs/notes_tab.dart`：

```dart
// 添加 import
import 'package:provider/provider.dart';
import '../../providers/activity_provider.dart';
import '../../widgets/activity/activity_list_view.dart';
import '../../widgets/activity/activity_statistic_view.dart';

class _NotesTabState extends State<NotesTab> with SingleTickerProviderStateMixin {
  // ... 现有字段

  /// false=笔记, true=活动
  bool _showActivities = false;

  /// 活动视图内部子页: 0=列表, 1=统计
  int _activitySubPage = 0;

  // 修改 build 方法：
  // 将 AppBar 的 title 从 Text(l10n.tabNotes) 改为：
  // SegmentedButton<bool>(
  //   segments: [
  //     ButtonSegment(value: false, label: Text(l10n.tabNotes)),
  //     ButtonSegment(value: true, label: Text('活动')),
  //   ],
  //   selected: {_showActivities},
  //   onSelectionChanged: (v) {
  //     setState(() => _showActivities = v.first);
  //     if (v.first) {
  //       // 切换到活动时加载数据
  //       context.read<ActivityProvider>().loadRecords();
  //       context.read<ActivityProvider>().loadActivityNames();
  //     }
  //   },
  // ),

  // body 部分根据 _showActivities 切换：
  // if (_showActivities) _buildActivityView() else ...(现有笔记内容)

  // 添加 _buildActivityView 方法：
  Widget _buildActivityView() {
    return Column(
      children: [
        // 子页切换：列表 / 统计
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 0, label: Text('列表')),
                  ButtonSegment(value: 1, label: Text('统计')),
                ],
                selected: {_activitySubPage},
                onSelectionChanged: (v) {
                  setState(() => _activitySubPage = v.first);
                  if (v.first == 1) {
                    context.read<ActivityProvider>().loadStatistics();
                  }
                },
              ),
              const Spacer(),
              // 添加按钮（仅在列表页显示）
              if (_activitySubPage == 0)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showAddActivitySheet(context),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _activitySubPage == 0
              ? const ActivityListView()
              : const ActivityStatisticView(),
        ),
      ],
    );
  }

  void _showAddActivitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ActivityAddSheet(),
    ).then((saved) {
      if (saved == true && mounted) {
        context.read<ActivityProvider>().loadRecords();
        context.read<ActivityProvider>().loadActivityNames();
      }
    });
  }
}
```

具体修改内容：

a) 添加 import:
```dart
import '../../providers/activity_provider.dart';
import '../../widgets/activity/activity_list_view.dart';
import '../../widgets/activity/activity_statistic_view.dart';
import '../../widgets/activity/activity_add_sheet.dart';
```

b) 添加 `_showActivities` 和 `_activitySubPage` 字段到 `_NotesTabState`

c) 修改 AppBar 的 title，用 SegmentedButton 替换原有 Text

d) 修改 body，根据 `_showActivities` 切换显示笔记内容或活动视图

e) 添加 `_buildActivityView()` 和 `_showAddActivitySheet()` 方法

---

### Task 9: 运行验证

- [ ] **Step 9.1: 运行分析检查**

```bash
flutter analyze
```
Expected: 无 lint 错误

- [ ] **Step 9.2: 重新生成 Drift 代码**

项目使用 Drift 需要重新生成 `.g.dart` 文件：

```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: 成功生成 database.g.dart 等文件

- [ ] **Step 9.3: 再次运行分析**

```bash
flutter analyze
```
Expected: 无错误

- [ ] **Step 9.4: 运行应用验证**

```bash
flutter run
```
验证：
1. 记事页面顶部出现"笔记/活动"切换
2. 切换到"活动"页面，看到空状态
3. 点击 + 按钮，弹窗正常
4. 输入活动名称、地点，保存成功
5. 列表显示刚刚添加的记录
6. 切换到统计 Tab，看到统计结果
7. 切换周/月，数据正确
