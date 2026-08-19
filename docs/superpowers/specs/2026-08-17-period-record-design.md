# 经期记录管理模块设计方案

## 一、背景

用户需要开发一个独立的经期记录管理模块，用于追踪和预测月经周期。模块独立于现有账本系统，与礼物卡、油耗记录同级，每个用户独立管理自己的经期数据，支持通过 UserShare 机制与其他用户共享（只读）。

## 二、模块介绍

### 2.1 功能概述

| 功能 | 说明 |
|------|------|
| 日历视图 | 以月历为主视图，标注经期日、排卵期、安全区 |
| 每日记录 | 在日历上选择日期，记录当天经期状态、流量、症状、情绪 |
| 自动预测 | 基于历史数据预测下次经期、排卵日、危险期 |
| 预测信息卡片 | 展示平均周期、预测日期、危险期范围 |
| 数据共享 | 通过 UserShare 机制，其他用户可只读查看我的经期数据 |

### 2.2 模块特性

- **独立模块**：不与现有账本系统关联，独立管理
- **按日记录**：每天一条记录，与日历天然对齐
- **日历/节律法预测**：取最近3-6个周期平均值，排卵日=下次经期前14天
- **日志驱动**：使用项目统一的日志驱动模式，数据变更记录到 log_sync_table
- **共享只读**：通过 UserShare 机制实现，对方只能查看不能修改

## 三、数据结构设计

### 3.1 数据库表设计

```dart
/// 经期日记录表
@DataClassName('PeriodRecord')
class PeriodRecordTable extends BaseBusinessTable {
  /// 记录日期 (yyyy-MM-dd，同一用户唯一)
  TextColumn get recordDate => text().named('record_date').withLength(min: 10, max: 10)();

  /// 经期状态: none(非经期), period(经期), spotting(经期前后少量出血)
  TextColumn get periodStatus =>
      text().named('period_status').withDefault(const Constant('none'))();

  /// 流量: none, light, medium, heavy（仅 period 时有意义）
  TextColumn get flowLevel =>
      text().named('flow_level').withDefault(const Constant('none'))();

  /// 症状标签 JSON 数组，如 ["headache","cramps","bloating"]
  TextColumn get symptoms =>
      text().named('symptoms').withDefault(const Constant('[]'))();

  /// 情绪: good, normal, bad, terrible
  TextColumn get mood => text().named('mood').withDefault(const Constant('normal'))();

  /// 备注
  TextColumn get remark => text().nullable().named('remark')();
}
```

**表字段说明：**

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | TEXT | 是 | 记录唯一标识 (UUID) |
| created_at | INTEGER | 是 | 创建时间 (毫秒时间戳) |
| updated_at | INTEGER | 是 | 更新时间 (毫秒时间戳) |
| created_by | TEXT | 是 | 创建人ID（即所属用户） |
| updated_by | TEXT | 是 | 更新人ID |
| record_date | TEXT | 是 | 记录日期 (yyyy-MM-dd)，同用户唯一 |
| period_status | TEXT | 是 | 经期状态（默认 none） |
| flow_level | TEXT | 是 | 流量等级（默认 none） |
| symptoms | TEXT | 是 | 症状标签 JSON 数组（默认 []） |
| mood | TEXT | 是 | 情绪（默认 normal） |
| remark | TEXT | 否 | 备注 |

### 3.2 枚举类型

```dart
/// 经期状态
enum PeriodStatus {
  none('none'),         // 非经期
  period('period'),     // 经期
  spotting('spotting'); // 经期前后少量出血

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

/// 流量等级
enum FlowLevel {
  none('none'),       // 无
  light('light'),     // 少量
  medium('medium'),   // 中等
  heavy('heavy');     // 大量

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

### 3.3 预定义症状标签

```dart
// lib/constants/period_symptoms.dart
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
}
```

### 3.4 值对象 (VO)

**PeriodRecordVO** - 单日记录值对象：

```dart
class PeriodRecordVO {
  final String id;
  final String recordDate;     // yyyy-MM-dd
  final PeriodStatus periodStatus;
  final FlowLevel flowLevel;
  final List<String> symptoms;
  final String? mood;
  final String? remark;
  final int createdAt;
  final int updatedAt;

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

**PeriodStatisticsVO** - 周期统计与预测值对象：

```dart
class PeriodStatisticsVO {
  /// 平均周期天数
  final int averageCycleLength;

  /// 平均经期天数
  final int averagePeriodLength;

  /// 总记录天数
  final int totalRecords;

  /// 近几个周期长度
  final List<int> recentCycleLengths;

  /// 最近一次经期开始日
  final String? lastPeriodStart;

  /// 预测下次经期开始日
  final String? nextPeriodDate;

  /// 预测排卵日
  final String? ovulationDate;

  /// 危险期（易孕期）开始
  final String? fertileWindowStart;

  /// 危险期（易孕期）结束
  final String? fertileWindowEnd;

  /// 是否有足够数据进行预测（至少2个完整周期）
  bool get canPredict => recentCycleLengths.length >= 2;
}
```

### 3.5 预测算法

使用**日历/节律法（Calendar/Rhythm Method）**，与 Flo、Clue 等主流经期App一致：

```
1. 从数据库中提取所有 periodStatus == 'period' 的日期
2. 按日期排序，识别连续经期日（间隔<=1天视为同一经期）
3. 计算每个经期的开始日期
4. 相邻两个经期间隔 = 周期长度
5. 取最近3-6个周期的平均值 = averageCycleLength
6. 取所有经期天数的平均值 = averagePeriodLength

预测公式：
- 下次经期开始日 = lastPeriodStart + averageCycleLength
- 排卵日 = 下次经期开始日 - 14天（黄体期固定约14天）
- 危险期开始 = 排卵日 - 5天
- 危险期结束 = 排卵日 + 1天
- 安全区 = 经期结束后 ~ 排卵日前5天之前
```

### 3.6 文件清单

| 层级 | 文件路径 | 说明 |
|------|----------|------|
| 数据库 | `lib/database/tables/period_record_table.dart` | 表定义 |
| 数据库 | `lib/database/dao/period_record_dao.dart` | DAO层 |
| 数据库 | `lib/database/database.dart` | 添加 PeriodRecordTable 到 Drift 数据库 |
| 枚举 | `lib/enums/period_status.dart` | 经期状态枚举 |
| 枚举 | `lib/enums/flow_level.dart` | 流量等级枚举 |
| 枚举 | `lib/enums/period_mood.dart` | 情绪枚举 |
| 枚举 | `lib/enums/business_type.dart` | 添加 periodRecord 业务类型 |
| 常量 | `lib/constants/period_symptoms.dart` | 症状标签定义 |
| 模型 | `lib/models/vo/period_record_vo.dart` | 单日记录值对象 |
| 模型 | `lib/models/vo/period_statistics_vo.dart` | 统计预测值对象 |
| 驱动接口 | `lib/drivers/data_driver.dart` | 定义经期相关接口 |
| 驱动实现 | `lib/drivers/special/log.data_driver.dart` | 实现经期相关方法 |
| 日志构建器 | `lib/drivers/special/log/builder/period_record.builder.dart` | 日志驱动构建器 |
| 预测 | `lib/services/period_prediction_service.dart` | 经期预测计算服务 |
| Provider | `lib/providers/period_record_provider.dart` | 状态管理 |
| 事件 | `lib/events/special/event_period.dart` | 事件定义 |
| 同步 | `lib/providers/sync_provider.dart` | 订阅经期变更事件 |
| 状态注册 | `lib/manager/provider_manager.dart` | 注册 PeriodRecordProvider |
| DAO注册 | `lib/manager/dao_manager.dart` | 注册 PeriodRecordDao |
| 页面 | `lib/pages/period/period_calendar_page.dart` | 日历主视图 |
| 页面 | `lib/pages/period/period_day_form_page.dart` | 单日记录编辑页 |
| 页面 | `lib/pages/period/widgets/period_calendar_widget.dart` | 自定义日历组件 |
| 页面 | `lib/pages/period/widgets/period_prediction_card.dart` | 预测信息卡片 |
| 页面 | `lib/pages/period/widgets/period_day_detail_card.dart` | 日期点击详情卡片 |
| 页面 | `lib/pages/period/widgets/period_legend.dart` | 日历图例组件 |
| 入口 | `lib/pages/tabs/mine_tab.dart` | 在"数据工具"区域添加入口 |
| 路由 | `lib/routes/app_routes.dart` | 路由配置 |

## 四、UX/UI 页面设计

### 4.1 入口设计

在"我的"页面 → "数据工具"区域，新增经期记录入口（与礼物卡、油耗记录同级）：

```
数据工具区域：
┌──────────────────────────────────────────┐
│ 📒  📎  🎁  ⛽  🏆  🩸                  │
│ 账本 附件 礼物卡 油耗 活动 经期           │
└──────────────────────────────────────────┘
```

### 4.2 日历主视图

```
┌─────────────────────────────┐
│  ← 经期记录                  │
├─────────────────────────────┤
│     < 2026年8月 >           │ ← 月份切换
│  日 一 二 三 四 五 六       │
│  .. .. .. .. .. .. 01       │
│  02 03 04 05 06 07 08       │
│  09 10 ●●●● 13 14 15       │ ← ●经期日（红色标记）
│  16 17 18 19 20 21 22       │
│  23 ◐◐ 25 26 27 28 29      │ ← ◐排卵期（橙色标记）
│  30 31                      │
├─────────────────────────────┤
│  ■ 经期  ■ 排卵期  ■ 安全区  │ ← 图例
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ 📊 周期预测              │ │
│ │ 平均周期：28天            │ │
│ │ 平均经期：5天             │ │
│ │ 下次经期：9月7日（预计）  │ │
│ │ 排卵日：8月24日（预计）   │ │
│ │ 危险期：8月19日-8月25日   │ │
│ └─────────────────────────┘ │
├─────────────────────────────┤
│  点击日期后展开当日记录：     │
│  ┌─────────────────────────┐│
│  │ 8月12日 周三             ││
│  │ 状态：经期  流量：中      ││
│  │ 症状：腹痛、腰酸         ││
│  │ 情绪：一般               ││
│  │ [编辑] [删除]            ││
│  └─────────────────────────┘│
└─────────────────────────────┘
```

**日历颜色方案：**

| 标记 | 颜色 | 说明 |
|------|------|------|
| 经期日 | `colorScheme.error` 红色圆点 | 用户记录的 period 状态日 |
| 排卵日 | `colorScheme.tertiary` 橙色圆点 | 预测的排卵日 |
| 危险期背景 | `colorScheme.tertiary` 浅色背景 | 排卵日前5天~后1天 |
| 安全区背景 | `Colors.green` 浅色背景 | 经期后~排卵日前5天 |
| 预测经期 | 虚线边框 `error` 色 | 预测的下次经期日期 |
| 今日 | `colorScheme.primary` 边框 | 当前日期高亮 |

### 4.3 单日记录编辑页

点击日历中的某天后，弹出底部弹窗或跳转编辑页：

```
┌─────────────────────────────┐
│  ← 8月12日 周三      [保存]  │
├─────────────────────────────┤
│                             │
│  经期状态                    │
│  ○ 非经期  ● 经期  ○ 少量   │ ← 三选一
│                             │
│  流量（经期时显示）           │
│  ○ 无  ○ 少量  ○ 中等  ○ 大 │
│                             │
│  症状（可多选）               │
│  [腹痛] [头痛] [腰酸]        │
│  [腹胀] [乳房胀] [疲劳]      │
│  [失眠] [痘痘] [恶心]        │
│  [食欲变化] [头晕] [情绪波动] │
│                             │
│  情绪                        │
│  [😊好] [😐一般] [😟差] [😫很差] │
│                             │
│  备注                        │
│  ┌─────────────────────────┐│
│  │                     ││
│  └─────────────────────────┘│
│                             │
└─────────────────────────────┘
```

### 4.4 日期详情卡片

点击日历中已记录的日期，在日历下方展开详情卡片：

```
┌─────────────────────────┐
│ 8月12日 周三             │
│ 状态：●经期  流量：中量   │
│ 症状：腹痛、腰酸         │
│ 情绪：😐一般             │
│ 备注：无                 │
│ [✏️编辑] [🗑️删除]       │
└─────────────────────────┘
```

## 五、技术实现要点

### 5.1 DataDriver 接口定义

> **遵循原则**：使用原子 update 方式，不定义业务专用方法。

```dart
// lib/drivers/data_driver.dart 新增

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

**updatePeriodDay 调用方式**（不在接口中定义专用方法）：

```dart
// 记录经期开始
await driver.updatePeriodDay(userId, '2026-08-10',
  periodStatus: PeriodStatus.period.code,
  flowLevel: FlowLevel.medium.code,
);

// 更新症状
await driver.updatePeriodDay(userId, '2026-08-10',
  symptoms: ['cramps', 'headache'],
  mood: PeriodMood.bad.code,
);

// 标记非经期
await driver.updatePeriodDay(userId, '2026-08-15',
  periodStatus: PeriodStatus.none.code,
);
```

### 5.2 LogBuilder 实现

```dart
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

  // 静态工厂方法：create, update, delete
  // 日志恢复方法：fromCreateLog, fromUpdateLog, fromLog
}
```

### 5.3 预测服务

```dart
// lib/services/period_prediction_service.dart
class PeriodPredictionService {
  /// 从记录列表计算周期统计和预测
  static PeriodStatisticsVO calculate(List<PeriodRecordVO> allRecords) {
    // 1. 筛选 period 状态的记录
    // 2. 按日期排序，识别连续经期日（间隔<=1天）
    // 3. 提取每个经期的开始日期
    // 4. 计算周期长度和经期天数
    // 5. 取最近3-6个周期的平均值
    // 6. 预测下次经期、排卵日、危险期
  }

  /// 获取某月各日期的类型标记（用于日历着色）
  static Map<String, DateType> getMonthDateTypes(
    List<PeriodRecordVO> monthRecords,
    PeriodStatisticsVO? statistics,
  ) {
    // 返回每天的标记类型：period / ovulation / fertile / safe / predicted_period
  }
}
```

### 5.4 数据流向

```
UI层 (PeriodCalendarPage, PeriodDayFormPage)
    ↓ ↑
Provider层 (PeriodRecordProvider)
    ↓ ↑
Driver层 (LogDataDriver)
    ↓ ↑
LogBuilder (PeriodRecordCULog)  +  PeriodPredictionService
    ↓ ↑
DAO层 (PeriodRecordDao)
    ↓ ↑
Database层 (PeriodRecordTable)
```

## 六、技术实现规范

### 6.1 DataDriver 接口设计原则

**应定义的接口：**
- `updatePeriodDay` - 记录/更新某日经期状态（原子 upsert）
- `listPeriodRecords` - 获取指定月份的记录
- `getPeriodStatistics` - 获取周期统计和预测
- `deletePeriodDay` - 删除某日记录

**不应定义的接口（应通过 updatePeriodDay 实现）：**
- ~~`startPeriod`~~ - 使用 `updatePeriodDay(periodStatus: 'period', flowLevel: ...)`
- ~~`endPeriod`~~ - 使用 `updatePeriodDay(periodStatus: 'none')`
- ~~`updateFlow`~~ - 使用 `updatePeriodDay(flowLevel: ...)`
- ~~`addSymptom`~~ - 使用 `updatePeriodDay(symptoms: [...])`

### 6.2 操作权限规范

| 操作 | 权限要求 | 说明 |
|------|----------|------|
| 创建/更新 | 记录所属用户 | 仅可操作自己的记录 |
| 查看 | 所属用户 或 被共享用户 | 通过 UserShare 控制 |
| 删除 | 记录所属用户 | 仅可删除自己的记录 |

### 6.3 数据同步机制

**事件定义（lib/events/special/event_period.dart）：**
```dart
class PeriodRecordChangedEvent {
  final OperateType operateType;
  const PeriodRecordChangedEvent(this.operateType);
}
```

**Provider 中触发同步：**
```dart
EventBus.instance.emit(PeriodRecordChangedEvent(OperateType.update));
```

**SyncProvider 订阅：**
```dart
EventBus.instance.on<PeriodRecordChangedEvent>(_handlePeriodRecordChanged),
// ...
void _handlePeriodRecordChanged(PeriodRecordChangedEvent event) {
  syncData();
}
```

### 6.4 数据共享

复用现有 `UserShare` 机制：
- `userShare` 表中 `businessType = 'periodRecord'`
- 共享设置页面中新增"经期记录"共享选项
- 被共享用户可在自己的日历中查看对方的经期数据（只读）

### 6.5 DAO 查询方法

```dart
class PeriodRecordDao extends BaseDao<PeriodRecordTable, PeriodRecord> {
  /// 查询指定月份的记录
  Future<List<PeriodRecord>> findByMonth(String userId, int year, int month);

  /// 查询所有 period 状态的记录（用于周期计算）
  Future<List<PeriodRecord>> findAllPeriodDays(String userId);

  /// 查询指定日期的记录
  Future<PeriodRecord?> findByDate(String userId, String recordDate);

  /// 按用户查询（用于共享查看）
  Future<List<PeriodRecord>> findByUser(String userId);
}
```

### 6.6 页面导航

**月份切换**：使用 PageView 或左右滑动切换月份。

**日期点击**：点击日历中的日期：
- 无记录：弹出底部弹窗，快速设置经期状态
- 有记录：展开详情卡片，可编辑/删除

**编辑保存后**：返回日历页，自动刷新数据和预测。

## 七、UI 组件规范

### 7.1 自定义日历组件

使用自定义日历 Widget（非第三方库），支持：
- 月份切换（左右箭头或滑动）
- 日期着色（经期/排卵/危险/安全）
- 点击日期触发回调
- 今日高亮
- 预测日期虚线边框

### 7.2 预测信息卡片

使用 `CommonCardContainer` 包装，显示：
- 平均周期天数
- 平均经期天数
- 下次经期预测日期
- 排卵日预测
- 危险期范围
- 数据不足时显示提示文案

### 7.3 症状选择

使用 `Wrap` 组件 + `FilterChip` 实现多选：
- 每个症状一个 chip，图标+文字
- 选中态使用 `colorScheme.primaryContainer`
- 未选中态使用 `colorScheme.surfaceContainerHighest`

## 八、验证测试点

1. **记录功能**：选择日期，设置经期状态、流量、症状、情绪，成功保存
2. **同日更新**：同一日期重复记录，验证 upsert 行为正确
3. **日历显示**：验证经期日、排卵期、安全区颜色标记正确
4. **月份切换**：验证左右切换月份，数据正确加载
5. **预测计算**：有足够数据时，验证预测日期计算正确
6. **数据不足**：记录不足2个周期时，显示"数据不足"提示
7. **删除功能**：删除某日记录后，日历和预测正确更新
8. **共享功能**：通过 UserShare 共享后，对方只读查看
9. **同步功能**：经期记录变更后，自动触发数据同步
10. **暗色主题**：日历组件在暗色主题下颜色清晰可辨
