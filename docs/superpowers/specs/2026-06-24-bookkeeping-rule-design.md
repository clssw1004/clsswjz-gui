# 记账规则 (Bookkeeping Rule) 设计文档

## 一、概述

记账规则功能允许用户预设条件和操作的组合。用户在记账表单中填写字段时，系统自动匹配激活的规则，命中条件则自动执行预设操作（如设置分类、账户等字段值），帮助用户减少重复操作。

## 二、数据架构

### 2.1 表结构

```
bookkeeping_rule_table
继承 BaseAccountBookTable (id, accountBookId, createdAt, updatedAt, createdBy, updatedBy)
├── name             TEXT    NOT NULL  -- 规则名称
├── is_active        BOOL    DEFAULT true  -- 启用开关
├── priority         INT     DEFAULT 0  -- 优先级（数值越大约优先）
├── conditions_json  TEXT    NOT NULL  -- 树形递归条件 JSON
└── actions_json     TEXT    NOT NULL  -- 扁平操作 JSON
```

`conditions_json` 和 `actions_json` 使用 TEXT 类型存储 JSON 字符串，确保跨 SQLite/MySQL/PostgreSQL 兼容。

### 2.2 条件结构（树形递归）

根节点总是带 `logicOperator` + `conditions` 数组：

```json
{
  "logicOperator": "AND",
  "conditions": [
    {"type": "field_equals", "field": "type", "value": "EXPENSE"},
    {
      "logicOperator": "OR",
      "conditions": [
        {"type": "field_in", "field": "categoryCode", "value": ["餐饮", "购物"]},
        {"type": "amount_range", "field": "amount", "minAmount": 100}
      ]
    }
  ]
}
```

- **非叶子节点**：有 `logicOperator`（AND/OR）+ `conditions` 子节点数组
- **叶子节点**：有 `type`/`field`/`value`，无 `logicOperator`

### 2.3 操作结构（扁平数组）

```json
[
  {"type": "set_value", "field": "categoryCode", "value": "餐饮"},
  {"type": "set_value", "field": "fundId", "value": "xxx"}
]
```

操作按数组顺序执行，后执行覆盖前执行。

## 三、抽象设计

### 3.1 Condition 抽象

```dart
abstract class ConditionEvaluator {
  String get type; // 注册标识
  bool matches(UserItemVO item, Map<String, dynamic> data);
  Map<String, dynamic> toJson();
}

// 注册器
class ConditionRegistry {
  static final Map<String, ConditionEvaluator Function(Map<String, dynamic>)> _registry = {};
  static void register(String type, ConditionEvaluator Function(Map<String, dynamic>) factory);
  static ConditionEvaluator? create(String type, Map<String, dynamic> data);
}
```

### 3.2 Action 抽象

```dart
abstract class ActionExecutor {
  String get type;
  void apply(UserItemVO item, Map<String, dynamic> data);
  Map<String, dynamic> toJson();
}

class ActionRegistry {
  // 同上注册模式
}
```

### 3.3 一期条件类型

| type | 说明 | data |
|------|------|------|
| `field_equals` | 字段等值匹配 | `{field: string, value: string}` |
| `field_in` | 字段多值匹配 | `{field: string, values: string[]}` |
| `amount_range` | 金额范围匹配 | `{field: "amount", minAmount?: number, maxAmount?: number}` |

### 3.4 一期操作类型

| type | 说明 | data |
|------|------|------|
| `set_value` | 设置字段值 | `{field: string, value: string}` |

## 四、规则引擎

### 4.1 核心流程

```
用户修改字段 X
  → ItemFormProvider 更新字段 X
  → 调用 RuleEngine.evaluate(changedField=X, item, activeRules)
    → 过滤：规则 conditions 涉及 X 字段
    → 排序：按 priority 降序
    → 遍历：递归匹配条件树
    → 执行：匹配成功则顺序执行 actions
    → 返回 modifiedFields 列表
  → ItemFormProvider 应用 modifiedFields（但不触发规则检查）
  → UI 自动更新
```

### 4.2 循环防护

规则通过 `set_value` 修改的字段不会再次触发 `RuleEngine.evaluate`，防止循环触发。

### 4.3 重复触发

用户可以再次修改该字段，此时规则会重新匹配并触发（循环防护仅阻断同一链条的递归）。

## 五、UI 设计

### 5.1 页面结构

```
规则列表页 (bookkeeping_rule_list_page)
├── AppBar: "记账规则" + 帮助说明
├── 空状态：无规则时的引导提示 + 新增按钮
└── 列表
    └── 卡片：名称 + 启用开关 + 优先级 + 条件摘要 + 操作摘要
    └── 滑出：编辑 / 删除

规则表单页 (bookkeeping_rule_form_page)
├── AppBar: 新增/编辑
├── 名称输入 + 启用开关 + 优先级
├── 条件列表
│   ├── 添加条件组按钮
│   └── 每条条件组：
│       ├── AND/OR SegmentedButton（非叶子节点）
│       ├── 条件连接线（缩进层级树形）
│       ├── 叶子条件：字段选择 + 值选择（根据字段类型动态切换）
│       └── 增加子条件 / 删除条件
└── 操作列表
    ├── 添加操作按钮
    └── 每条操作：字段选择 + 值选择（set_value 类型）
```

### 5.2 值选择器类型适配

| 字段 | 选择器 |
|------|--------|
| type | SegmentedButton（支出/收入/转账）|
| categoryCode | 弹窗分类选择（复用 CommonSelectFormField）|
| fundId | 弹窗账户选择（复用）|
| shopCode | 弹窗商户选择（复用）|
| tagCode / projectCode | 弹窗标签/项目选择（复用）|
| amount | 数字输入（min/max）|

## 六、DataDriver 架构

完整遵循 DataDriver 规范：

- 表定义 → DAO → LogBuilder → DataDriver 接口 → LogDataDriver 实现 → Provider → UI
- CRUD 操作写操作全部通过 LogBuilder 走同步日志
- Update 使用统一原子方法，不定义单字段专用方法

### 6.1 Driver 接口方法

```dart
Future<OperateResult<String>> createBookkeepingRule(
  String userId, String bookId, {
  required String name, required bool isActive, required int priority,
  required String conditionsJson, required String actionsJson,
});

Future<OperateResult<void>> updateBookkeepingRule(
  String userId, String ruleId, {
  String? name, bool? isActive, int? priority,
  String? conditionsJson, String? actionsJson,
});

Future<OperateResult<void>> deleteBookkeepingRule(
  String userId, String ruleId);

Future<OperateResult<List<BookkeepingRuleVO>>> listBookkeepingRules(
  String userId, String bookId);

Future<OperateResult<BookkeepingRuleVO>> getBookkeepingRule(
  String userId, String ruleId);
```

## 七、事件

```dart
class BookkeepingRuleChangedEvent {
  final BookkeepingRuleVO rule;
  final OperateType operateType;
}
```

## 八、文件清单

| 层级 | 文件 |
|------|------|
| 枚举 | `lib/enums/rule_condition_type.dart` |
| 模型 | `lib/models/vo/bookkeeping_rule_vo.dart` |
| 模型 | `lib/models/rule/condition_model.dart` |
| 模型 | `lib/models/rule/action_model.dart` |
| 模型 | `lib/models/rule/package.dart` |
| 数据库 | `lib/database/tables/bookkeeping_rule_table.dart` |
| 数据库 | `lib/database/dao/bookkeeping_rule_dao.dart` |
| Builder | `lib/drivers/special/log/builder/bookkeeping_rule.builder.dart` |
| 驱动 | `lib/drivers/data_driver.dart`（修改）|
| 驱动 | `lib/drivers/special/log.data_driver.dart`（修改）|
| 服务 | `lib/services/rule_engine.dart` |
| 服务 | `lib/services/bookkeeping_rule_service.dart` |
| Provider | `lib/providers/bookkeeping_rule_provider.dart` |
| Provider | `lib/providers/item_form_provider.dart`（修改）|
| UI | `lib/pages/bookkeeping_rule/bookkeeping_rule_list_page.dart` |
| UI | `lib/pages/bookkeeping_rule/bookkeeping_rule_form_page.dart` |
| UI | `lib/pages/bookkeeping_rule/package.dart` |
| 注册 | `lib/enums/business_type.dart`（修改）|
| 注册 | `lib/database/database.dart`（修改）|
| 注册 | `lib/manager/dao_manager.dart`（修改）|
| 注册 | `lib/manager/provider_manager.dart`（修改）|
| 注册 | `lib/drivers/special/log/builder/builder.dart`（修改）|
| 路由 | `lib/routes/app_routes.dart`（修改）|
| 事件 | `lib/events/special/event_book.dart`（修改）|
| 同步 | `lib/providers/sync_provider.dart`（修改）|
