# 经期记录管理模块实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现独立的经期记录管理模块，支持日历视图、每日记录、周期预测，与礼物卡/油耗记录同级

**Architecture:** 新增 PeriodRecordTable + PeriodRecordDao 管理经期日记录，使用 LogBuilder 日志驱动模式。Provider 层通过 PeriodRecordProvider 管理状态，UI 层提供自定义日历视图+预测信息卡片。

**Tech Stack:** Flutter, Drift (SQLite), Provider, EventBus

**Spec:** `docs/superpowers/specs/2026-08-17-period-record-design.md`

## Global Constraints

- 所有颜色使用 `colorScheme.xxx`，禁止硬编码颜色
- 间距使用 `theme.spacing.xxx`，禁止硬编码 EdgeInsets
- 禁止使用 `withOpacity()`，使用 `withAlpha()` 或 `withValues(alpha:)`
- 所有文本使用 `L10nManager.l10n` 获取国际化文本
- `flutter analyze` 无错误

---

## 文件结构

### 新增文件 (18个)

| 文件 | 职责 |
|------|------|
| `lib/database/tables/period_record_table.dart` | 经期日记录表定义 |
| `lib/database/dao/period_record_dao.dart` | 经期记录 DAO |
| `lib/enums/period_status.dart` | 经期状态枚举 |
| `lib/enums/flow_level.dart` | 流量等级枚举 |
| `lib/enums/period_mood.dart` | 情绪枚举 |
| `lib/constants/period_symptoms.dart` | 症状标签常量 |
| `lib/models/vo/period_record_vo.dart` | 单日记录值对象 |
| `lib/models/vo/period_statistics_vo.dart` | 统计预测值对象 |
| `lib/drivers/special/log/builder/period_record.builder.dart` | 日志驱动构建器 |
| `lib/services/period_prediction_service.dart` | 经期预测计算服务 |
| `lib/events/special/event_period.dart` | 经期变更事件 |
| `lib/providers/period_record_provider.dart` | 经期记录状态管理 |
| `lib/pages/period/period_calendar_page.dart` | 日历主视图 |
| `lib/pages/period/period_day_form_page.dart` | 单日记录编辑页 |
| `lib/pages/period/widgets/period_calendar_widget.dart` | 自定义日历组件 |
| `lib/pages/period/widgets/period_prediction_card.dart` | 预测信息卡片 |
| `lib/pages/period/widgets/period_day_detail_card.dart` | 日期详情卡片 |
| `lib/pages/period/widgets/period_legend.dart` | 日历图例组件 |

### 修改文件 (7个)

| 文件 | 修改 |
|------|------|
| `lib/enums/business_type.dart` | 新增 `periodRecord` + 同步优先级 `low` |
| `lib/database/database.dart` | 注册 PeriodRecordTable, schemaVersion 19→20, onUpgrade |
| `lib/manager/dao_manager.dart` | 注册 PeriodRecordDao |
| `lib/drivers/data_driver.dart` | 新增经期相关接口方法 |
| `lib/drivers/special/log.data_driver.dart` | 实现经期相关方法 |
| `lib/drivers/special/log/builder/builder.dart` | 注册 PeriodRecordCULog + DeleteLog |
| `lib/providers/sync_provider.dart` | 订阅 PeriodRecordChangedEvent |
| `lib/manager/provider_manager.dart` | 注册 PeriodRecordProvider |
| `lib/pages/tabs/mine_tab.dart` | 增加经期记录入口 |
| `lib/routes/app_routes.dart` | 添加路由 |

---

### Task 1: 创建 PeriodRecordTable

**Files:**
- Create: `lib/database/tables/period_record_table.dart`

**Interfaces:**
- Produces: `PeriodRecordTable`, `PeriodRecordTableCompanion`, `PeriodRecord` (Drift generated)

- [ ] **Step 1: 创建表定义文件**

```dart
import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

/// 经期日记录表
@DataClassName('PeriodRecord')
class PeriodRecordTable extends BaseBusinessTable {
  /// 记录日期 (yyyy-MM-dd，同一用户唯一)
  TextColumn get recordDate => text().named('record_date').withLength(min: 10, max: 10)();

  /// 经期状态: none(非经期), period(经期), spotting(少量出血)
  TextColumn get periodStatus =>
      text().named('period_status').withDefault(const Constant('none'))();

  /// 流量: none, light, medium, heavy
  TextColumn get flowLevel =>
      text().named('flow_level').withDefault(const Constant('none'))();

  /// 症状标签 JSON 数组，如 ["headache","cramps","bloating"]
  TextColumn get symptoms =>
      text().named('symptoms').withDefault(const Constant('[]'))();

  /// 情绪: good, normal, bad, terrible
  TextColumn get mood => text().named('mood').withDefault(const Constant('normal'))();

  /// 备注
  TextColumn get remark => text().nullable().named('remark')();

  /// 创建Companion
  static PeriodRecordTableCompanion toCreateCompanion(
    String who, {
    required String recordDate,
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodRecordTableCompanion(
      id: Value(IdUtil.genId()),
      recordDate: Value(recordDate),
      periodStatus: Value(periodStatus ?? 'none'),
      flowLevel: Value(flowLevel ?? 'none'),
      symptoms: Value(jsonEncode(symptoms ?? [])),
      mood: Value(mood ?? 'normal'),
      remark: Value.absentIfNull(remark),
      createdBy: Value(who),
      createdAt: Value(DateUtil.now()),
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
    );
  }

  /// 更新Companion
  static PeriodRecordTableCompanion toUpdateCompanion(
    String who, {
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodRecordTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      periodStatus: Value.absentIfNull(periodStatus),
      flowLevel: Value.absentIfNull(flowLevel),
      symptoms: symptoms != null ? Value(jsonEncode(symptoms)) : const Value.absent(),
      mood: Value.absentIfNull(mood),
      remark: const Value.absent(),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
      id: const Value.absent(),
      recordDate: const Value.absent(),
    );
  }

  /// 转换为JSON字符串
  static String toJsonString(PeriodRecordTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'recordDate', companion.recordDate);
    MapUtil.setIfPresent(map, 'periodStatus', companion.periodStatus);
    MapUtil.setIfPresent(map, 'flowLevel', companion.flowLevel);
    MapUtil.setIfPresent(map, 'symptoms', companion.symptoms);
    MapUtil.setIfPresent(map, 'mood', companion.mood);
    MapUtil.setIfPresent(map, 'remark', companion.remark);
    return jsonEncode(map);
  }

  /// 从JSON对象创建Companion（用于日志恢复）
  static PeriodRecordTableCompanion fromJson(Map<String, dynamic> json) {
    return PeriodRecordTableCompanion(
      id: json['id'] != null ? Value(json['id'] as String) : const Value.absent(),
      createdAt: json['createdAt'] != null ? Value(json['createdAt'] as int) : const Value.absent(),
      updatedAt: json['updatedAt'] != null ? Value(json['updatedAt'] as int) : const Value.absent(),
      createdBy: json['createdBy'] != null ? Value(json['createdBy'] as String) : const Value.absent(),
      updatedBy: json['updatedBy'] != null ? Value(json['updatedBy'] as String) : const Value.absent(),
      recordDate: json['recordDate'] != null ? Value(json['recordDate'] as String) : const Value.absent(),
      periodStatus: json['periodStatus'] != null ? Value(json['periodStatus'] as String) : const Value.absent(),
      flowLevel: json['flowLevel'] != null ? Value(json['flowLevel'] as String) : const Value.absent(),
      symptoms: json['symptoms'] != null ? Value(json['symptoms'] as String) : const Value.absent(),
      mood: json['mood'] != null ? Value(json['mood'] as String) : const Value.absent(),
      remark: json['remark'] != null ? Value(json['remark'] as String) : const Value.absent(),
    );
  }
}
```

- [ ] **Step 2: 验证代码无语法错误**

Run: `flutter analyze lib/database/tables/period_record_table.dart`
Expected: 无 error

- [ ] **Step 3: Commit**

```bash
git add lib/database/tables/period_record_table.dart
git commit -m "feat: add PeriodRecordTable definition"
```

---

### Task 2: 创建枚举和 BusinessType 注册

**Files:**
- Create: `lib/enums/period_status.dart`
- Create: `lib/enums/flow_level.dart`
- Create: `lib/enums/period_mood.dart`
- Modify: `lib/enums/business_type.dart`

**Interfaces:**
- Produces: `PeriodStatus`, `FlowLevel`, `PeriodMood` 枚举, `BusinessType.periodRecord`

- [ ] **Step 1: 创建 PeriodStatus 枚举**

```dart
/// 经期状态
enum PeriodStatus {
  none('none'),
  period('period'),
  spotting('spotting');

  final String code;
  const PeriodStatus(this.code);

  static PeriodStatus fromCode(String code) =>
    values.firstWhere((e) => e.code == code, orElse: () => none);

  String get text => switch(this) {
    none => '非经期',
    period => '经期',
    spotting => '少量出血',
  };
}
```

- [ ] **Step 2: 创建 FlowLevel 枚举**

```dart
/// 流量等级
enum FlowLevel {
  none('none'),
  light('light'),
  medium('medium'),
  heavy('heavy');

  final String code;
  const FlowLevel(this.code);

  static FlowLevel fromCode(String code) =>
    values.firstWhere((e) => e.code == code, orElse: () => none);

  String get text => switch(this) {
    none => '无',
    light => '少量',
    medium => '中等',
    heavy => '大量',
  };
}
```

- [ ] **Step 3: 创建 PeriodMood 枚举**

```dart
/// 经期情绪
enum PeriodMood {
  good('good'),
  normal('normal'),
  bad('bad'),
  terrible('terrible');

  final String code;
  const PeriodMood(this.code);

  static PeriodMood fromCode(String code) =>
    values.firstWhere((e) => e.code == code, orElse: () => normal);

  String get text => switch(this) {
    good => '好',
    normal => '一般',
    bad => '差',
    terrible => '很差',
  };
}
```

- [ ] **Step 4: 注册 BusinessType.periodRecord**

在 `lib/enums/business_type.dart` 的 `BusinessType` 枚举中添加：

```dart
/// 经期记录
periodRecord('periodRecord'),
```

同时在 `BusinessTypeSyncPriority` 扩展中添加：

```dart
case BusinessType.periodRecord:
  return SyncPriority.low;
```

- [ ] **Step 5: 验证代码无语法错误**

Run: `flutter analyze lib/enums/`
Expected: 无 error

- [ ] **Step 6: Commit**

```bash
git add lib/enums/period_status.dart lib/enums/flow_level.dart lib/enums/period_mood.dart lib/enums/business_type.dart
git commit -m "feat: add period record enums and BusinessType registration"
```

---

### Task 3: 创建 PeriodRecordDao

**Files:**
- Create: `lib/database/dao/period_record_dao.dart`

**Interfaces:**
- Consumes: `PeriodRecordTable`, `PeriodRecord` (from Task 1)
- Produces: `PeriodRecordDao` with `findByMonth`, `findAllPeriodDays`, `findByDate`, `findByUser`

- [ ] **Step 1: 创建 DAO 文件**

```dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/period_record_table.dart';
import 'base_dao.dart';

class PeriodRecordDao extends BaseDao<PeriodRecordTable, PeriodRecord> {
  PeriodRecordDao(super.db);

  @override
  TableInfo<PeriodRecordTable, PeriodRecord> get table => db.periodRecordTable;

  /// 查询指定月份的记录
  Future<List<PeriodRecord>> findByMonth(String userId, int year, int month) {
    final startDate = '$year-${month.toString().padLeft(2, '0')}-01';
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    final endDate = '$nextYear-${nextMonth.toString().padLeft(2, '0')}-01';

    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) &
              t.recordDate.isBiggerOrEqualValue(startDate) &
              t.recordDate.isSmallerThanValue(endDate))
          ..orderBy([(t) => OrderingTerm.asc(t.recordDate)]))
        .get();
  }

  /// 查询所有 period/spotting 状态的记录（用于周期计算）
  Future<List<PeriodRecord>> findAllPeriodDays(String userId) {
    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) &
              (t.periodStatus.equals('period') | t.periodStatus.equals('spotting')))
          ..orderBy([(t) => OrderingTerm.asc(t.recordDate)]))
        .get();
  }

  /// 查询指定日期的记录
  Future<PeriodRecord?> findByDate(String userId, String recordDate) {
    return (db.select(table)
          ..where((t) =>
              t.createdBy.equals(userId) & t.recordDate.equals(recordDate)))
        .getSingleOrNull();
  }

  /// 按用户查询（用于共享查看）
  Future<List<PeriodRecord>> findByUser(String userId) {
    return (db.select(table)
          ..where((t) => t.createdBy.equals(userId))
          ..orderBy([(t) => OrderingTerm.asc(t.recordDate)]))
        .get();
  }
}
```

- [ ] **Step 2: 验证代码无语法错误**

Run: `flutter analyze lib/database/dao/period_record_dao.dart`
Expected: 无 error

- [ ] **Step 3: Commit**

```bash
git add lib/database/dao/period_record_dao.dart
git commit -m "feat: add PeriodRecordDao"
```

---

### Task 4: 注册到 Database 和 DaoManager

**Files:**
- Modify: `lib/database/database.dart`
- Modify: `lib/manager/dao_manager.dart`

**Interfaces:**
- Consumes: `PeriodRecordTable` (from Task 1), `PeriodRecordDao` (from Task 3)
- Produces: `db.periodRecordTable`, `DaoManager.periodRecordDao`

- [ ] **Step 1: 注册表到 Database**

在 `lib/database/database.dart` 中：

1. 添加 import：
```dart
import 'tables/period_record_table.dart';
```

2. 在 `@DriftDatabase` 的 `tables` 列表末尾添加 `PeriodRecordTable`

3. 修改 `schemaVersion` 为 `20`

4. 在 `onUpgrade` 中添加迁移：
```dart
if (from < 20) {
  // 版本19到版本20的迁移：新增经期记录表
  await m.create(periodRecordTable);
}
```

- [ ] **Step 2: 注册到 DaoManager**

在 `lib/manager/dao_manager.dart` 中：

1. 添加 import：
```dart
import '../database/dao/period_record_dao.dart';
```

2. 添加静态字段：
```dart
static late PeriodRecordDao periodRecordDao;
```

3. 在 `refreshDaos()` 方法中添加：
```dart
periodRecordDao = PeriodRecordDao(DatabaseManager.db);
```

- [ ] **Step 3: 运行代码生成**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: 成功生成 `database.g.dart`

- [ ] **Step 4: 验证代码无语法错误**

Run: `flutter analyze`
Expected: 无 error

- [ ] **Step 5: Commit**

```bash
git add lib/database/database.dart lib/database/database.g.dart lib/manager/dao_manager.dart
git commit -m "feat: register PeriodRecordTable in database and DaoManager"
```

---

### Task 5: 创建常量和 VO

**Files:**
- Create: `lib/constants/period_symptoms.dart`
- Create: `lib/models/vo/period_record_vo.dart`
- Create: `lib/models/vo/period_statistics_vo.dart`

**Interfaces:**
- Consumes: `PeriodRecord` (from Task 1), `PeriodStatus`, `FlowLevel` (from Task 2)
- Produces: `PeriodRecordVO`, `PeriodStatisticsVO`, `PeriodSymptoms`

- [ ] **Step 1: 创建症状标签常量**

```dart
import 'package:flutter/material.dart';

class PeriodSymptoms {
  static const List<({String code, String label, IconData icon})> all = [
    (code: 'cramps', label: '腹痛', icon: Icons.healing),
    (code: 'headache', label: '头痛', icon: Icons.psychology),
    (code: 'backache', label: '腰痛', icon: Icons.accessibility_new),
    (code: 'bloating', label: '腹胀', icon: Icons.circle),
    (code: 'breast_tenderness', label: '乳房胀痛', icon: Icons.favorite),
    (code: 'fatigue', label: '疲劳', icon: Icons.battery_1_bar),
    (code: 'insomnia', label: '失眠', icon: Icons.bedtime),
    (code: 'acne', label: '痘痘', icon: Icons.face),
    (code: 'nausea', label: '恶心', icon: Icons.sick),
    (code: 'appetite_change', label: '食欲变化', icon: Icons.restaurant),
    (code: 'dizziness', label: '头晕', icon: Icons.center_focus_strong),
    (code: 'mood_swings', label: '情绪波动', icon: Icons.mood),
  ];

  static String labelOf(String code) {
    final match = all.where((s) => s.code == code);
    return match.isNotEmpty ? match.first.label : code;
  }
}
```

- [ ] **Step 2: 创建 PeriodRecordVO**

```dart
import 'dart:convert';
import '../../database/tables/period_record_table.dart';
import '../../enums/flow_level.dart';
import '../../enums/period_status.dart';

class PeriodRecordVO {
  final String id;
  final String recordDate;
  final PeriodStatus periodStatus;
  final FlowLevel flowLevel;
  final List<String> symptoms;
  final String? mood;
  final String? remark;
  final int createdAt;
  final int updatedAt;

  const PeriodRecordVO({
    required this.id,
    required this.recordDate,
    required this.periodStatus,
    required this.flowLevel,
    required this.symptoms,
    this.mood,
    this.remark,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PeriodRecordVO.fromPeriodRecord(PeriodRecord record) {
    return PeriodRecordVO(
      id: record.id,
      recordDate: record.recordDate,
      periodStatus: PeriodStatus.fromCode(record.periodStatus),
      flowLevel: FlowLevel.fromCode(record.flowLevel),
      symptoms: List<String>.from(jsonDecode(record.symptoms)),
      mood: record.mood,
      remark: record.remark,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
    );
  }
}
```

- [ ] **Step 3: 创建 PeriodStatisticsVO**

```dart
class PeriodStatisticsVO {
  final int averageCycleLength;
  final int averagePeriodLength;
  final int totalRecords;
  final List<int> recentCycleLengths;
  final String? lastPeriodStart;
  final String? nextPeriodDate;
  final String? ovulationDate;
  final String? fertileWindowStart;
  final String? fertileWindowEnd;

  const PeriodStatisticsVO({
    required this.averageCycleLength,
    required this.averagePeriodLength,
    required this.totalRecords,
    required this.recentCycleLengths,
    this.lastPeriodStart,
    this.nextPeriodDate,
    this.ovulationDate,
    this.fertileWindowStart,
    this.fertileWindowEnd,
  });

  bool get canPredict => recentCycleLengths.length >= 2;

  static const empty = PeriodStatisticsVO(
    averageCycleLength: 0,
    averagePeriodLength: 0,
    totalRecords: 0,
    recentCycleLengths: [],
  );
}
```

- [ ] **Step 4: 验证代码无语法错误**

Run: `flutter analyze lib/constants/ lib/models/vo/period_record_vo.dart lib/models/vo/period_statistics_vo.dart`
Expected: 无 error

- [ ] **Step 5: Commit**

```bash
git add lib/constants/period_symptoms.dart lib/models/vo/period_record_vo.dart lib/models/vo/period_statistics_vo.dart
git commit -m "feat: add period record VO, statistics VO, and symptoms constants"
```

---

### Task 6: 创建 PeriodRecordCULog 并注册

**Files:**
- Create: `lib/drivers/special/log/builder/period_record.builder.dart`
- Modify: `lib/drivers/special/log/builder/builder.dart`

**Interfaces:**
- Consumes: `PeriodRecordTable` (from Task 1), `DaoManager.periodRecordDao` (from Task 4)
- Produces: `PeriodRecordCULog` (create/update/delete/fromLog), registered in builder.dart

- [ ] **Step 1: 创建 LogBuilder**

```dart
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../database/database.dart';
import '../../../../database/tables/period_record_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

/// 经期记录日志构建器
class PeriodRecordCULog extends LogBuilder<PeriodRecordTableCompanion, String> {
  PeriodRecordCULog() : super() {
    doWith(BusinessType.periodRecord);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.periodRecordDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.periodRecordDao.update(businessId!, data!);
    } else if (operateType == OperateType.delete) {
      await DaoManager.periodRecordDao.delete(businessId!);
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    return PeriodRecordTable.toJsonString(data as PeriodRecordTableCompanion);
  }

  /// 从创建日志恢复
  static PeriodRecordCULog fromCreateLog(LogSync log) {
    return PeriodRecordCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doCreate()
        .withData(_parseCompanion(jsonDecode(log.operateData))) as PeriodRecordCULog;
  }

  /// 从更新日志恢复
  static PeriodRecordCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return PeriodRecordCULog()
        .who(log.operatorId)
        .target(log.businessId)
        .doUpdate()
        .withData(PeriodRecordTable.toUpdateCompanion(
          log.operatorId,
          periodStatus: data['periodStatus'] as String?,
          flowLevel: data['flowLevel'] as String?,
          symptoms: data['symptoms'] != null
              ? List<String>.from(jsonDecode(data['symptoms'] as String))
              : null,
          mood: data['mood'] as String?,
          remark: data['remark'] as String?,
        )) as PeriodRecordCULog;
  }

  /// 从日志恢复
  static PeriodRecordCULog fromLog(LogSync log) {
    return switch (OperateType.fromCode(log.operateType)) {
      OperateType.create => PeriodRecordCULog.fromCreateLog(log),
      OperateType.update => PeriodRecordCULog.fromUpdateLog(log),
      _ => PeriodRecordCULog.fromUpdateLog(log),
    };
  }

  /// 创建经期记录
  static PeriodRecordCULog create({
    required String who,
    required String recordDate,
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodRecordCULog()
        .who(who)
        .doCreate()
        .noParent()
        .withData(PeriodRecordTable.toCreateCompanion(
          who,
          recordDate: recordDate,
          periodStatus: periodStatus,
          flowLevel: flowLevel,
          symptoms: symptoms,
          mood: mood,
          remark: remark,
        )) as PeriodRecordCULog;
  }

  /// 更新经期记录
  static PeriodRecordCULog update({
    required String who,
    required String id,
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) {
    return PeriodRecordCULog()
        .who(who)
        .doUpdate()
        .noParent()
        .target(id)
        .withData(PeriodRecordTable.toUpdateCompanion(
          who,
          periodStatus: periodStatus,
          flowLevel: flowLevel,
          symptoms: symptoms,
          mood: mood,
          remark: remark,
        )) as PeriodRecordCULog;
  }

  /// 删除经期记录
  static PeriodRecordCULog delete({
    required String who,
    required String id,
  }) {
    return PeriodRecordCULog()
        .who(who)
        .doDelete()
        .noParent()
        .target(id) as PeriodRecordCULog;
  }

  /// 解析JSON为Companion
  static PeriodRecordTableCompanion _parseCompanion(Map<String, dynamic> json) {
    return PeriodRecordTable.fromJson(json);
  }
}
```

- [ ] **Step 2: 注册到 builder.dart**

在 `lib/drivers/special/log/builder/builder.dart` 中：

1. 添加 import：
```dart
import 'period_record.builder.dart';
```

2. 在 `_fromLog` 的 switch 语句中添加：
```dart
case BusinessType.periodRecord:
  return PeriodRecordCULog.fromLog(log) as LogBuilder<T, RunResult>;
```

3. 在 `DeleteLog.executeLog()` 的 switch 中添加：
```dart
case BusinessType.periodRecord:
  return DaoManager.periodRecordDao.delete(businessId!);
```

- [ ] **Step 3: 验证代码无语法错误**

Run: `flutter analyze lib/drivers/special/log/builder/`
Expected: 无 error

- [ ] **Step 4: Commit**

```bash
git add lib/drivers/special/log/builder/period_record.builder.dart lib/drivers/special/log/builder/builder.dart
git commit -m "feat: add PeriodRecordCULog and register in builder"
```

---

### Task 7: 添加 DataDriver 接口方法

**Files:**
- Modify: `lib/drivers/data_driver.dart`

**Interfaces:**
- Consumes: `PeriodRecordVO`, `PeriodStatisticsVO` (from Task 5)
- Produces: 4 个接口方法签名

- [ ] **Step 1: 在 BookDataDriver 中添加接口**

在 `lib/drivers/data_driver.dart` 的末尾（`// ============ 记账规则相关 ============` 之后）添加：

```dart
// ============ 经期记录相关 ============

/// 记录/更新某日经期状态（原子操作：不存在则创建，存在则更新）
Future<OperateResult<void>> updatePeriodDay(
  String userId,
  String recordDate, {
  String? periodStatus,
  String? flowLevel,
  List<String>? symptoms,
  String? mood,
  String? remark,
});

/// 获取指定月份的经期记录
Future<OperateResult<List<PeriodRecordVO>>> listPeriodRecords(
  String userId, {
  required int year,
  required int month,
});

/// 获取经期预测信息（周期统计+预测）
Future<OperateResult<PeriodStatisticsVO>> getPeriodStatistics(String userId);

/// 删除某日记录
Future<OperateResult<void>> deletePeriodDay(String userId, String recordDate);
```

同时在文件顶部添加 import：
```dart
import '../models/vo/period_record_vo.dart';
import '../models/vo/period_statistics_vo.dart';
```

- [ ] **Step 2: 验证代码无语法错误**

Run: `flutter analyze lib/drivers/data_driver.dart`
Expected: 无 error（接口方法未实现会有 warning，但不会 error）

- [ ] **Step 3: Commit**

```bash
git add lib/drivers/data_driver.dart
git commit -m "feat: add period record interface methods to BookDataDriver"
```

---

### Task 8: 实现 DataDriver 方法

**Files:**
- Modify: `lib/drivers/special/log.data_driver.dart`

**Interfaces:**
- Consumes: `PeriodRecordCULog` (from Task 6), `PeriodRecordDao` (from Task 4), `PeriodPredictionService` (from Task 9)
- Produces: `updatePeriodDay`, `listPeriodRecords`, `getPeriodStatistics`, `deletePeriodDay` 实现

- [ ] **Step 1: 在 LogDataDriver 中添加实现**

在 `lib/drivers/special/log.data_driver.dart` 的末尾添加：

```dart
@override
Future<OperateResult<void>> updatePeriodDay(
  String userId,
  String recordDate, {
  String? periodStatus,
  String? flowLevel,
  List<String>? symptoms,
  String? mood,
  String? remark,
}) async {
  try {
    // 查询是否已有当日记录（upsert 语义）
    final existing = await DaoManager.periodRecordDao.findByDate(userId, recordDate);

    if (existing != null) {
      // 更新已有记录
      await PeriodRecordCULog.update(
        who: userId,
        id: existing.id,
        periodStatus: periodStatus,
        flowLevel: flowLevel,
        symptoms: symptoms,
        mood: mood,
        remark: remark,
      ).execute();
    } else {
      // 创建新记录
      await PeriodRecordCULog.create(
        who: userId,
        recordDate: recordDate,
        periodStatus: periodStatus,
        flowLevel: flowLevel,
        symptoms: symptoms,
        mood: mood,
        remark: remark,
      ).execute();
    }
    return OperateResult.success(null);
  } catch (e) {
    return OperateResult.failWithMessage(
        message: '更新经期记录失败：$e', exception: e as Exception);
  }
}

@override
Future<OperateResult<List<PeriodRecordVO>>> listPeriodRecords(
  String userId, {
  required int year,
  required int month,
}) async {
  try {
    final records = await DaoManager.periodRecordDao.findByMonth(userId, year, month);
    return OperateResult.success(
        records.map((r) => PeriodRecordVO.fromPeriodRecord(r)).toList());
  } catch (e) {
    return OperateResult.failWithMessage(
        message: '查询经期记录失败：$e', exception: e as Exception);
  }
}

@override
Future<OperateResult<PeriodStatisticsVO>> getPeriodStatistics(String userId) async {
  try {
    final allPeriodDays = await DaoManager.periodRecordDao.findAllPeriodDays(userId);
    final vos = allPeriodDays
        .map((r) => PeriodRecordVO.fromPeriodRecord(r))
        .toList();
    final statistics = PeriodPredictionService.calculate(vos);
    return OperateResult.success(statistics);
  } catch (e) {
    return OperateResult.failWithMessage(
        message: '获取经期统计失败：$e', exception: e as Exception);
  }
}

@override
Future<OperateResult<void>> deletePeriodDay(String userId, String recordDate) async {
  try {
    final existing = await DaoManager.periodRecordDao.findByDate(userId, recordDate);
    if (existing == null) {
      return OperateResult.failWithMessage(message: '记录不存在');
    }
    await PeriodRecordCULog.delete(
      who: userId,
      id: existing.id,
    ).execute();
    return OperateResult.success(null);
  } catch (e) {
    return OperateResult.failWithMessage(
        message: '删除经期记录失败：$e', exception: e as Exception);
  }
}
```

同时在文件顶部添加 import：
```dart
import '../../models/vo/period_record_vo.dart';
import '../../models/vo/period_statistics_vo.dart';
import '../../services/period_prediction_service.dart';
import 'log/builder/period_record.builder.dart';
```

- [ ] **Step 2: 验证代码无语法错误**

Run: `flutter analyze lib/drivers/special/log.data_driver.dart`
Expected: 无 error

- [ ] **Step 3: Commit**

```bash
git add lib/drivers/special/log.data_driver.dart
git commit -m "feat: implement period record methods in LogDataDriver"
```

---

### Task 9: 创建预测服务

**Files:**
- Create: `lib/services/period_prediction_service.dart`

**Interfaces:**
- Consumes: `PeriodRecordVO` (from Task 5)
- Produces: `PeriodPredictionService.calculate()`, `PeriodPredictionService.getMonthDateTypes()`

- [ ] **Step 1: 创建预测服务**

```dart
import '../constants/period_constants.dart';
import '../models/vo/period_record_vo.dart';
import '../models/vo/period_statistics_vo.dart';

/// 日期类型标记
enum DateType {
  period,      // 经期
  ovulation,   // 排卵日
  fertile,     // 危险期（易孕期）
  safe,        // 安全区
  predictedPeriod, // 预测经期
}

/// 经期预测服务
class PeriodPredictionService {
  /// 从记录列表计算周期统计和预测
  static PeriodStatisticsVO calculate(List<PeriodRecordVO> allRecords) {
    if (allRecords.isEmpty) return PeriodStatisticsVO.empty;

    // 筛选 period 状态的记录，按日期排序
    final periodRecords = allRecords
        .where((r) => r.periodStatus == PeriodStatus.period)
        .toList()
      ..sort((a, b) => a.recordDate.compareTo(b.recordDate));

    if (periodRecords.isEmpty) return PeriodStatisticsVO.empty;

    // 识别连续经期日（间隔<=1天视为同一经期）
    final cycles = _identifyCycles(periodRecords);

    if (cycles.isEmpty) return PeriodStatisticsVO.empty;

    // 计算周期长度
    final cycleLengths = <int>[];
    for (var i = 1; i < cycles.length; i++) {
      final diff = _daysBetween(cycles[i - 1].first.recordDate, cycles[i].first.recordDate);
      if (diff > 15 && diff < 60) {
        cycleLengths.add(diff);
      }
    }

    // 计算经期天数
    final periodLengths = cycles.map((c) => c.length).toList();

    final avgCycle = cycleLengths.isNotEmpty
        ? (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round()
        : 28;
    final avgPeriod = periodLengths.isNotEmpty
        ? (periodLengths.reduce((a, b) => a + b) / periodLengths.length).round()
        : 5;

    // 最近一次经期开始日
    final lastStart = cycles.last.first.recordDate;

    // 预测
    String? nextPeriodDate;
    String? ovulationDate;
    String? fertileStart;
    String? fertileEnd;

    if (cycleLengths.length >= 2) {
      nextPeriodDate = _addDays(lastStart, avgCycle);
      ovulationDate = _addDays(nextPeriodDate, -14);
      fertileStart = _addDays(ovulationDate, -5);
      fertileEnd = _addDays(ovulationDate, 1);
    }

    return PeriodStatisticsVO(
      averageCycleLength: avgCycle,
      averagePeriodLength: avgPeriod,
      totalRecords: allRecords.length,
      recentCycleLengths: cycleLengths,
      lastPeriodStart: lastStart,
      nextPeriodDate: nextPeriodDate,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
    );
  }

  /// 识别连续经期周期
  static List<List<PeriodRecordVO>> _identifyCycles(List<PeriodRecordVO> sorted) {
    if (sorted.isEmpty) return [];

    final cycles = <List<PeriodRecordVO>>[];
    var current = [sorted.first];

    for (var i = 1; i < sorted.length; i++) {
      final gap = _daysBetween(sorted[i - 1].recordDate, sorted[i].recordDate);
      if (gap <= 1) {
        current.add(sorted[i]);
      } else {
        cycles.add(current);
        current = [sorted[i]];
      }
    }
    cycles.add(current);
    return cycles;
  }

  /// 获取某月各日期的类型标记
  static Map<String, DateType> getMonthDateTypes(
    List<PeriodRecordVO> monthRecords,
    PeriodStatisticsVO? statistics,
  ) {
    final result = <String, DateType>{};

    // 标记已记录的经期日
    for (final r in monthRecords) {
      if (r.periodStatus == PeriodStatus.period) {
        result[r.recordDate] = DateType.period;
      }
    }

    // 标记预测日期
    if (statistics != null && statistics.canPredict) {
      // 预测经期
      if (statistics.nextPeriodDate != null) {
        for (var i = 0; i < statistics.averagePeriodLength; i++) {
          final date = _addDays(statistics.nextPeriodDate!, i);
          result[date] ??= DateType.predictedPeriod;
        }
      }

      // 排卵日
      if (statistics.ovulationDate != null) {
        result[statistics.ovulationDate!] = DateType.ovulation;
      }

      // 危险期
      if (statistics.fertileWindowStart != null && statistics.fertileWindowEnd != null) {
        var date = statistics.fertileWindowStart!;
        while (date.compareTo(statistics.fertileWindowEnd!) <= 0) {
          if (result[date] == null || result[date] == DateType.safe) {
            result[date] = DateType.fertile;
          }
          date = _addDays(date, 1);
        }
      }
    }

    return result;
  }

  static int _daysBetween(String date1, String date2) {
    final d1 = DateTime.parse(date1);
    final d2 = DateTime.parse(date2);
    return d2.difference(d1).inDays;
  }

  static String _addDays(String date, int days) {
    final d = DateTime.parse(date).add(Duration(days: days));
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
```

注意：文件顶部需要创建一个 `lib/constants/period_constants.dart` 来导出 PeriodStatus（或者直接 import 枚举文件）。修正 import：

```dart
import '../enums/period_status.dart';
```

- [ ] **Step 2: 验证代码无语法错误**

Run: `flutter analyze lib/services/period_prediction_service.dart`
Expected: 无 error

- [ ] **Step 3: Commit**

```bash
git add lib/services/period_prediction_service.dart
git commit -m "feat: add PeriodPredictionService with calendar rhythm algorithm"
```

---

### Task 10: 事件和同步注册

**Files:**
- Create: `lib/events/special/event_period.dart`
- Modify: `lib/providers/sync_provider.dart`

**Interfaces:**
- Consumes: `PeriodRecordChangedEvent`
- Produces: 事件类 + sync_provider 订阅

- [ ] **Step 1: 创建事件类**

```dart
import '../../enums/operate_type.dart';

/// 经期记录变动事件
class PeriodRecordChangedEvent {
  final OperateType operateType;
  const PeriodRecordChangedEvent(this.operateType);
}
```

- [ ] **Step 2: 注册到 sync_provider.dart**

在 `lib/providers/sync_provider.dart` 中：

1. 添加 import：
```dart
import '../events/special/event_period.dart';
```

2. 在 `_subscribeToEvents` 方法中添加订阅：
```dart
EventBus.instance.on<PeriodRecordChangedEvent>(_handlePeriodRecordChanged),
```

3. 添加处理方法：
```dart
void _handlePeriodRecordChanged(PeriodRecordChangedEvent event) {
  syncData();
}
```

- [ ] **Step 3: 验证代码无语法错误**

Run: `flutter analyze lib/events/special/event_period.dart lib/providers/sync_provider.dart`
Expected: 无 error

- [ ] **Step 4: Commit**

```bash
git add lib/events/special/event_period.dart lib/providers/sync_provider.dart
git commit -m "feat: add PeriodRecordChangedEvent and sync registration"
```

---

### Task 11: 创建 Provider 并注册

**Files:**
- Create: `lib/providers/period_record_provider.dart`
- Modify: `lib/manager/provider_manager.dart`

**Interfaces:**
- Consumes: `DriverFactory.driver` (from Task 8), `PeriodRecordVO`, `PeriodStatisticsVO`, `PeriodRecordChangedEvent`
- Produces: `PeriodRecordProvider`

- [ ] **Step 1: 创建 Provider**

```dart
import 'package:flutter/material.dart';
import 'package:clsswjz_gui/drivers/driver_factory.dart';
import 'package:clsswjz_gui/enums/operate_type.dart';
import 'package:clsswjz_gui/events/event_bus.dart';
import 'package:clsswjz_gui/events/special/event_period.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/models/vo/period_record_vo.dart';
import 'package:clsswjz_gui/models/vo/period_statistics_vo.dart';

/// 经期记录数据提供者
class PeriodRecordProvider extends ChangeNotifier {
  List<PeriodRecordVO> _records = [];
  PeriodStatisticsVO _statistics = PeriodStatisticsVO.empty;
  bool _loading = false;
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;

  List<PeriodRecordVO> get records => _records;
  PeriodStatisticsVO get statistics => _statistics;
  bool get loading => _loading;
  int get currentYear => _currentYear;
  int get currentMonth => _currentMonth;

  /// 加载指定月份的记录
  Future<void> loadRecords({int? year, int? month}) async {
    _loading = true;
    notifyListeners();

    if (year != null) _currentYear = year;
    if (month != null) _currentMonth = month;

    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.listPeriodRecords(
      userId,
      year: _currentYear,
      month: _currentMonth,
    );
    if (result.ok) {
      _records = result.data ?? [];
    }

    // 加载统计数据
    final statsResult = await DriverFactory.driver.getPeriodStatistics(userId);
    if (statsResult.ok) {
      _statistics = statsResult.data ?? PeriodStatisticsVO.empty;
    }

    _loading = false;
    notifyListeners();
  }

  /// 切换月份
  Future<void> changeMonth(int year, int month) async {
    await loadRecords(year: year, month: month);
  }

  /// 记录/更新某日经期状态
  Future<OperateResult<void>> updatePeriodDay(
    String recordDate, {
    String? periodStatus,
    String? flowLevel,
    List<String>? symptoms,
    String? mood,
    String? remark,
  }) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.updatePeriodDay(
      userId,
      recordDate,
      periodStatus: periodStatus,
      flowLevel: flowLevel,
      symptoms: symptoms,
      mood: mood,
      remark: remark,
    );
    if (result.ok) {
      await loadRecords();
      EventBus.instance.emit(PeriodRecordChangedEvent(
        periodStatus == null ? OperateType.update : OperateType.create,
      ));
    }
    return result;
  }

  /// 删除某日记录
  Future<OperateResult<void>> deletePeriodDay(String recordDate) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.deletePeriodDay(userId, recordDate);
    if (result.ok) {
      await loadRecords();
      EventBus.instance.emit(PeriodRecordChangedEvent(OperateType.delete));
    }
    return result;
  }

  /// 获取指定日期的记录
  PeriodRecordVO? getRecordByDate(String recordDate) {
    try {
      return _records.firstWhere((r) => r.recordDate == recordDate);
    } catch (_) {
      return null;
    }
  }
}
```

- [ ] **Step 2: 注册到 ProviderManager**

在 `lib/manager/provider_manager.dart` 中：

1. 添加 import：
```dart
import '../providers/period_record_provider.dart';
```

2. 在 `MultiProvider` 的 `providers` 列表中添加：
```dart
ChangeNotifierProvider(create: (_) => PeriodRecordProvider()),
```

- [ ] **Step 3: 验证代码无语法错误**

Run: `flutter analyze lib/providers/period_record_provider.dart lib/manager/provider_manager.dart`
Expected: 无 error

- [ ] **Step 4: Commit**

```bash
git add lib/providers/period_record_provider.dart lib/manager/provider_manager.dart
git commit -m "feat: add PeriodRecordProvider and register in ProviderManager"
```

---

### Task 12: 创建 UI 组件

**Files:**
- Create: `lib/pages/period/widgets/period_calendar_widget.dart`
- Create: `lib/pages/period/widgets/period_prediction_card.dart`
- Create: `lib/pages/period/widgets/period_day_detail_card.dart`
- Create: `lib/pages/period/widgets/period_legend.dart`

**Interfaces:**
- Consumes: `PeriodRecordVO`, `PeriodStatisticsVO`, `DateType` (from Task 9)
- Produces: 4 个可复用 Widget

- [ ] **Step 1: 创建日历图例组件**

```dart
import 'package:flutter/material.dart';
import '../../../services/period_prediction_service.dart';

class PeriodLegend extends StatelessWidget {
  const PeriodLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildItem(cs, theme, cs.error, '经期'),
        const SizedBox(width: 12),
        _buildItem(cs, theme, cs.tertiary, '排卵期'),
        const SizedBox(width: 12),
        _buildItem(cs, theme, Colors.green, '安全区'),
      ],
    );
  }

  Widget _buildItem(ColorScheme cs, ThemeData theme, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withAlpha(46),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
```

- [ ] **Step 2: 创建预测信息卡片**

```dart
import 'package:flutter/material.dart';
import '../../../models/vo/period_statistics_vo.dart';
import '../../../widgets/common/common_card_container.dart';
import '../../../theme/theme_spacing.dart';

class PeriodPredictionCard extends StatelessWidget {
  final PeriodStatisticsVO statistics;
  const PeriodPredictionCard({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final cs = theme.colorScheme;

    if (!statistics.canPredict) {
      return CommonCardContainer(
        padding: spacing.contentPadding,
        child: Row(
          children: [
            Icon(Icons.info_outline, color: cs.onSurfaceVariant, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '至少需要2个完整周期才能预测',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return CommonCardContainer(
      padding: spacing.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text('周期预测', style: theme.textTheme.titleSmall?.copyWith(
                color: cs.primary, fontWeight: FontWeight.w600,
              )),
            ],
          ),
          SizedBox(height: spacing.formItemSpacing),
          _buildRow(theme, '平均周期', '${statistics.averageCycleLength}天'),
          _buildRow(theme, '平均经期', '${statistics.averagePeriodLength}天'),
          if (statistics.nextPeriodDate != null)
            _buildRow(theme, '下次经期', '${statistics.nextPeriodDate}（预计）'),
          if (statistics.ovulationDate != null)
            _buildRow(theme, '排卵日', '${statistics.ovulationDate}（预计）'),
          if (statistics.fertileWindowStart != null && statistics.fertileWindowEnd != null)
            _buildRow(theme, '危险期', '${statistics.fertileWindowStart} ~ ${statistics.fertileWindowEnd}'),
        ],
      ),
    );
  }

  Widget _buildRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: 创建日期详情卡片**

```dart
import 'package:flutter/material.dart';
import '../../../constants/period_symptoms.dart';
import '../../../enums/flow_level.dart';
import '../../../enums/period_mood.dart';
import '../../../enums/period_status.dart';
import '../../../models/vo/period_record_vo.dart';
import '../../../theme/theme_spacing.dart';

class PeriodDayDetailCard extends StatelessWidget {
  final PeriodRecordVO record;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PeriodDayDetailCard({
    super.key,
    required this.record,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final cs = theme.colorScheme;

    return Container(
      padding: spacing.contentPadding,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${record.recordDate} ${_weekDay(record.recordDate)}',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              if (onEdit != null)
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 18, color: cs.primary),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: cs.error),
                  onPressed: onDelete,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
            ],
          ),
          SizedBox(height: spacing.formItemSpacing),
          _buildInfoRow(theme, '状态', record.periodStatus.text),
          if (record.periodStatus == PeriodStatus.period)
            _buildInfoRow(theme, '流量', record.flowLevel.text),
          if (record.symptoms.isNotEmpty)
            _buildInfoRow(theme, '症状',
                record.symptoms.map((s) => PeriodSymptoms.labelOf(s)).join('、')),
          if (record.mood != null)
            _buildInfoRow(theme, '情绪', PeriodMood.fromCode(record.mood!).text),
          if (record.remark != null && record.remark!.isNotEmpty)
            _buildInfoRow(theme, '备注', record.remark!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 48,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  String _weekDay(String date) {
    const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return days[DateTime.parse(date).weekday - 1];
  }
}
```

- [ ] **Step 4: 创建自定义日历组件**

这是一个较大的组件，核心功能：
- 显示月份网格
- 用不同颜色标记经期日、排卵期、安全区
- 支持月份切换
- 点击日期触发回调

```dart
import 'package:flutter/material.dart';
import '../../../models/vo/period_record_vo.dart';
import '../../../models/vo/period_statistics_vo.dart';
import '../../../services/period_prediction_service.dart';

class PeriodCalendarWidget extends StatelessWidget {
  final int year;
  final int month;
  final List<PeriodRecordVO> records;
  final PeriodStatisticsVO? statistics;
  final ValueChanged<String> onDateTap;
  final VoidCallback? onPreviousMonth;
  final VoidCallback? onNextMonth;

  const PeriodCalendarWidget({
    super.key,
    required this.year,
    required this.month,
    required this.records,
    this.statistics,
    required this.onDateTap,
    this.onPreviousMonth,
    this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateTypes = PeriodPredictionService.getMonthDateTypes(records, statistics);
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    // 月份第一天是周几
    final firstDay = DateTime(year, month, 1);
    final startWeekday = firstDay.weekday % 7; // 0=周日
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return Column(
      children: [
        // 月份切换
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: cs.onSurface),
              onPressed: onPreviousMonth,
            ),
            Text(
              '$year年$month月',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: cs.onSurface),
              onPressed: onNextMonth,
            ),
          ],
        ),
        // 星期标题
        Row(
          children: ['日', '一', '二', '三', '四', '五', '六'].map((d) {
            return Expanded(
              child: Center(
                child: Text(d, style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                )),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        // 日期网格
        ...List.generate(((startWeekday + daysInMonth + 6) ~/ 7), (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              final cellIndex = weekIndex * 7 + dayIndex;
              final dayNum = cellIndex - startWeekday + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }
              final dateStr = '$year-${month.toString().padLeft(2, '0')}-${dayNum.toString().padLeft(2, '0')}';
              final dateType = dateTypes[dateStr];
              final isToday = dateStr == todayStr;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDateTap(dateStr),
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(cs, dateType),
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: cs.primary, width: 2)
                          : dateType == DateType.predictedPeriod
                              ? Border.all(color: cs.error.withAlpha(128), width: 1, style: BorderStyle.solid)
                              : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 13,
                          color: _getTextColor(cs, dateType),
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  Color? _getBackgroundColor(ColorScheme cs, DateType? type) {
    return switch (type) {
      DateType.period => cs.error.withAlpha(46),
      DateType.ovulation => cs.tertiary.withAlpha(60),
      DateType.fertile => cs.tertiary.withAlpha(30),
      DateType.safe => Colors.green.withAlpha(20),
      DateType.predictedPeriod => cs.error.withAlpha(15),
      null => null,
    };
  }

  Color _getTextColor(ColorScheme cs, DateType? type) {
    return switch (type) {
      DateType.period => cs.error,
      DateType.ovulation => cs.tertiary,
      _ => cs.onSurface,
    };
  }
}
```

- [ ] **Step 5: 验证所有组件无语法错误**

Run: `flutter analyze lib/pages/period/`
Expected: 无 error

- [ ] **Step 6: Commit**

```bash
git add lib/pages/period/widgets/
git commit -m "feat: add period record UI widgets (calendar, prediction, detail, legend)"
```

---

### Task 13: 创建主页面和编辑页面

**Files:**
- Create: `lib/pages/period/period_calendar_page.dart`
- Create: `lib/pages/period/period_day_form_page.dart`

**Interfaces:**
- Consumes: `PeriodRecordProvider`, `PeriodRecordVO`, `PeriodStatisticsVO`, `DateType`
- Produces: 日历主视图页面, 单日编辑页面

- [ ] **Step 1: 创建日历主页面**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
import 'package:clsswjz_gui/widgets/common/common_app_bar.dart';
import 'package:clsswjz_gui/enums/period_status.dart';
import 'package:clsswjz_gui/enums/flow_level.dart';
import '../../services/period_prediction_service.dart';
import 'widgets/period_calendar_widget.dart';
import 'widgets/period_prediction_card.dart';
import 'widgets/period_day_detail_card.dart';
import 'widgets/period_legend.dart';
import 'period_day_form_page.dart';

class PeriodCalendarPage extends StatefulWidget {
  const PeriodCalendarPage({super.key});

  @override
  State<PeriodCalendarPage> createState() => _PeriodCalendarPageState();
}

class _PeriodCalendarPageState extends State<PeriodCalendarPage> {
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PeriodRecordProvider>().loadRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(title: '经期记录'),
      body: Consumer<PeriodRecordProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.records.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // 日历
              SliverToBoxAdapter(
                child: Padding(
                  padding: spacing.contentPadding,
                  child: PeriodCalendarWidget(
                    year: provider.currentYear,
                    month: provider.currentMonth,
                    records: provider.records,
                    statistics: provider.statistics,
                    onDateTap: _onDateTap,
                    onPreviousMonth: _previousMonth,
                    onNextMonth: _nextMonth,
                  ),
                ),
              ),
              // 图例
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.contentPadding.left),
                  child: const PeriodLegend(),
                ),
              ),
              // 预测卡片
              SliverToBoxAdapter(
                child: Padding(
                  padding: spacing.contentPadding.copyWith(top: spacing.formItemSpacing),
                  child: PeriodPredictionCard(statistics: provider.statistics),
                ),
              ),
              // 选中日期的详情
              if (_selectedDate != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: spacing.contentPadding.copyWith(top: spacing.formItemSpacing),
                    child: _buildSelectedDateDetail(provider),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedDateDetail(PeriodRecordProvider provider) {
    final record = provider.getRecordByDate(_selectedDate!);
    if (record == null) {
      // 无记录，显示快速添加入口
      return _buildEmptyDateCard();
    }
    return PeriodDayDetailCard(
      record: record,
      onEdit: () => _navigateToForm(record),
      onDelete: () => _confirmDelete(provider, record.recordDate),
    );
  }

  Widget _buildEmptyDateCard() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return GestureDetector(
      onTap: () => _navigateToForm(null),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withAlpha(60), width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: cs.primary, size: 20),
            const SizedBox(width: 8),
            Text('点击记录经期', style: TextStyle(color: cs.primary)),
          ],
        ),
      ),
    );
  }

  void _onDateTap(String date) {
    setState(() => _selectedDate = date);
  }

  void _previousMonth() {
    final provider = context.read<PeriodRecordProvider>();
    var month = provider.currentMonth - 1;
    var year = provider.currentYear;
    if (month < 1) { month = 12; year--; }
    provider.changeMonth(year, month);
    setState(() => _selectedDate = null);
  }

  void _nextMonth() {
    final provider = context.read<PeriodRecordProvider>();
    var month = provider.currentMonth + 1;
    var year = provider.currentYear;
    if (month > 12) { month = 1; year++; }
    provider.changeMonth(year, month);
    setState(() => _selectedDate = null);
  }

  void _navigateToForm(dynamic record) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PeriodDayFormPage(
          recordDate: _selectedDate!,
          record: record,
        ),
      ),
    );
    setState(() => _selectedDate = null);
  }

  void _confirmDelete(PeriodRecordProvider provider, String date) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('确定删除该日的经期记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deletePeriodDay(date);
              setState(() => _selectedDate = null);
            },
            child: Text('删除', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 创建单日编辑页面**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clsswjz_gui/enums/flow_level.dart';
import 'package:clsswjz_gui/enums/period_mood.dart';
import 'package:clsswjz_gui/enums/period_status.dart';
import 'package:clsswjz_gui/providers/period_record_provider.dart';
import 'package:clsswjz_gui/constants/period_symptoms.dart';
import 'package:clsswjz_gui/models/vo/period_record_vo.dart';
import 'package:clsswjz_gui/widgets/common/common_app_bar.dart';
import '../../theme/theme_spacing.dart';

class PeriodDayFormPage extends StatefulWidget {
  final String recordDate;
  final PeriodRecordVO? record;

  const PeriodDayFormPage({
    super.key,
    required this.recordDate,
    this.record,
  });

  @override
  State<PeriodDayFormPage> createState() => _PeriodDayFormPageState();
}

class _PeriodDayFormPageState extends State<PeriodDayFormPage> {
  late PeriodStatus _periodStatus;
  late FlowLevel _flowLevel;
  late List<String> _symptoms;
  late String _mood;
  late TextEditingController _remarkController;

  @override
  void initState() {
    super.initState();
    _periodStatus = widget.record?.periodStatus ?? PeriodStatus.none;
    _flowLevel = widget.record?.flowLevel ?? FlowLevel.none;
    _symptoms = List.from(widget.record?.symptoms ?? []);
    _mood = widget.record?.mood ?? PeriodMood.normal.code;
    _remarkController = TextEditingController(text: widget.record?.remark ?? '');
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(
        title: widget.recordDate,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('保存', style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: spacing.formPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 经期状态
            Text('经期状态', style: theme.textTheme.titleSmall),
            SizedBox(height: spacing.formItemSpacing),
            _buildSegmentedChoice<PeriodStatus>(
              values: PeriodStatus.values,
              selected: _periodStatus,
              labelBuilder: (s) => s.text,
              onChanged: (v) => setState(() => _periodStatus = v),
            ),

            // 流量（仅经期时显示）
            if (_periodStatus == PeriodStatus.period) ...[
              SizedBox(height: spacing.formGroupSpacing),
              Text('流量', style: theme.textTheme.titleSmall),
              SizedBox(height: spacing.formItemSpacing),
              _buildSegmentedChoice<FlowLevel>(
                values: FlowLevel.values.where((f) => f != FlowLevel.none).toList(),
                selected: _flowLevel,
                labelBuilder: (f) => f.text,
                onChanged: (v) => setState(() => _flowLevel = v),
              ),
            ],

            // 症状
            SizedBox(height: spacing.formGroupSpacing),
            Text('症状（可多选）', style: theme.textTheme.titleSmall),
            SizedBox(height: spacing.formItemSpacing),
            Wrap(
              spacing: spacing.formItemSpacing,
              runSpacing: spacing.formItemSpacing,
              children: PeriodSymptoms.all.map((s) {
                final selected = _symptoms.contains(s.code);
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(s.icon, size: 16),
                      const SizedBox(width: 4),
                      Text(s.label),
                    ],
                  ),
                  selected: selected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _symptoms.add(s.code);
                      } else {
                        _symptoms.remove(s.code);
                      }
                    });
                  },
                  selectedColor: cs.primaryContainer,
                  checkmarkColor: cs.primary,
                );
              }).toList(),
            ),

            // 情绪
            SizedBox(height: spacing.formGroupSpacing),
            Text('情绪', style: theme.textTheme.titleSmall),
            SizedBox(height: spacing.formItemSpacing),
            _buildSegmentedChoice<PeriodMood>(
              values: PeriodMood.values,
              selected: PeriodMood.fromCode(_mood),
              labelBuilder: (m) => m.text,
              onChanged: (v) => setState(() => _mood = v.code),
            ),

            // 备注
            SizedBox(height: spacing.formGroupSpacing),
            Text('备注', style: theme.textTheme.titleSmall),
            SizedBox(height: spacing.formItemSpacing),
            TextField(
              controller: _remarkController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '可选备注...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentedChoice<T>({
    required List<T> values,
    required T selected,
    required String Function(T) labelBuilder,
    required ValueChanged<T> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      children: values.map((v) {
        final isSelected = v == selected;
        return ChoiceChip(
          label: Text(labelBuilder(v)),
          selected: isSelected,
          onSelected: (_) => onChanged(v),
          selectedColor: cs.primaryContainer,
          labelStyle: TextStyle(
            color: isSelected ? cs.onPrimaryContainer : cs.onSurface,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _save() async {
    final provider = context.read<PeriodRecordProvider>();
    final result = await provider.updatePeriodDay(
      widget.recordDate,
      periodStatus: _periodStatus.code,
      flowLevel: _periodStatus == PeriodStatus.period ? _flowLevel.code : FlowLevel.none.code,
      symptoms: _symptoms,
      mood: _mood,
      remark: _remarkController.text.isEmpty ? null : _remarkController.text,
    );
    if (mounted && result.ok) {
      Navigator.pop(context);
    }
  }
}
```

- [ ] **Step 3: 验证所有页面无语法错误**

Run: `flutter analyze lib/pages/period/`
Expected: 无 error

- [ ] **Step 4: Commit**

```bash
git add lib/pages/period/period_calendar_page.dart lib/pages/period/period_day_form_page.dart
git commit -m "feat: add period calendar page and day form page"
```

---

### Task 14: 添加入口和路由

**Files:**
- Modify: `lib/pages/tabs/mine_tab.dart`
- Modify: `lib/routes/app_routes.dart`

**Interfaces:**
- Consumes: `PeriodCalendarPage`
- Produces: 路由入口, mine_tab 入口

- [ ] **Step 1: 添加路由**

在 `lib/routes/app_routes.dart` 中：

1. 添加 import：
```dart
import '../pages/period/period_calendar_page.dart';
```

2. 在 `AppRoutes` 类中添加路由常量：
```dart
/// 经期记录日历页面
static const String periodCalendar = '/period/calendar';
```

3. 在 `onGenerateRoute` 的 switch 中添加：
```dart
case periodCalendar: {
  return const PeriodCalendarPage();
}
```

- [ ] **Step 2: 添加 MineTab 入口**

在 `lib/pages/tabs/mine_tab.dart` 中：

1. 在 `dataToolItems` 列表中添加：
```dart
_GridFeatureItemData(
  icon: Icons.calendar_month,
  label: L10nManager.l10n.periodRecord, // 需要添加国际化
  onTap: () => Navigator.pushNamed(context, AppRoutes.periodCalendar),
),
```

2. 添加 import（如果需要路由常量）：
```dart
import '../../routes/app_routes.dart';
```

- [ ] **Step 3: 验证代码无语法错误**

Run: `flutter analyze lib/pages/tabs/mine_tab.dart lib/routes/app_routes.dart`
Expected: 无 error

- [ ] **Step 4: Commit**

```bash
git add lib/pages/tabs/mine_tab.dart lib/routes/app_routes.dart
git commit -m "feat: add period record entry in MineTab and routing"
```

---

### Task 15: 端到端验证

**Files:** 无新增文件

- [ ] **Step 1: 运行全量分析**

Run: `flutter analyze`
Expected: 无 error

- [ ] **Step 2: 运行测试**

Run: `flutter test`
Expected: 所有测试通过

- [ ] **Step 3: 验证数据库迁移**

在模拟器/设备上运行 app，验证：
- 数据库 schema 从 19 升级到 20
- period_record_table 创建成功
- 应用不崩溃

Run: `flutter run`

- [ ] **Step 4: 验证完整流程**

在 app 中测试以下流程：
1. "我的" → "数据工具" → "经期记录" 入口可点击
2. 日历页面正常显示当前月份
3. 点击日期可进入编辑页
4. 保存经期记录后日历上显示红色标记
5. 连续记录多天后预测卡片正常显示
6. 切换月份正常
7. 删除记录正常
8. 暗色主题下颜色正常

- [ ] **Step 5: Final Commit**

```bash
git add -A
git commit -m "feat: complete period record management module"
```
