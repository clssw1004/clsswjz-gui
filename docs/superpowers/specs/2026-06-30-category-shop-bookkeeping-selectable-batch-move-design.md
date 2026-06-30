# 分类/商户管理扩展：isBookkeepingSelectable + 批量移动

## Context

分类（AccountCategory）和商户（AccountShop）的树形结构中，部分父节点仅为概念性分组（如"餐饮"下有"中餐""西餐"），本身不应在记账时被选中。当前所有节点在 TreeSelectFormField 中都可选中。

同时，分类/商户管理页面缺少批量操作能力，需要批量移动（将多个节点移动到同一父节点下）。

---

## Feature A: `isBookkeepingSelectable` 字段

### 新增列

| DB 表 | 新增列 | 类型 | 默认 | 说明 |
|-------|--------|------|------|------|
| `account_category` | `is_bookkeeping_selectable` | `Boolean` | `true` | 分类在记账时可选 |
| `account_shop` | `is_bookkeeping_selectable` | `Boolean` | `true` | 商户在记账时可选 |

### 语义

- `isBookkeepingSelectable = false` → 该节点是概念性分组，记账时不应被选中
- `isBookkeepingSelectable = true` → 行为不变，可选

### 行为规则

| 场景 | isBookkeepingSelectable=false 的行为 | 代表组件 |
|------|-----------------------------------|---------|
| 记账选择 | 灰色样式（文字/标签 0.4alpha），点击仅展开/收起，不可选中 | `TreeSelectFormField`（`bookkeepingMode: true`） |
| 管理页面 | 行为不变，可选 | 分类/商户管理页内操作（移动弹窗等） |
| 条件编辑器/筛选 | 行为不变，可选 | `condition_editor.dart` 等（`bookkeepingMode: false`） |

### 组件改动

#### `TreeSelectSheet`
- 新增参数：`bool bookkeepingMode = true`
- 新增 `_isNodeSelectable(T data)` 方法，`bookkeepingMode && !data.isBookkeepingSelectable` 返回 false
- `_onTapNode` 中判断：不可选节点调用 `_toggleExpand` 后直接 return，不执行选中逻辑
- `_buildListView` 中为不可选节点渲染灰色样式

#### `TreeSelectItem`
- 新增参数：`bool bookkeepingMode`, `bool isBookkeepingSelectable`
- build 中判断：`bookkeepingMode && !isBookkeepingSelectable` → 文字/标签 alpha 降低到 0.4，鼠标反馈不变

#### `TreeSelectFormField`
- 新增参数：`bool bookkeepingMode = true`，传递给 `TreeSelectSheet`

### 调用方改动

- 所有记账表单（`item_add_page`、`item_edit_page`、`modern_item_form`、`action_value_widgets`）→ 维持 `bookkeepingMode: true`（默认）
- 条件编辑器（`condition_editor.dart`）→ 传 `bookkeepingMode: false`
- 移动弹窗（`categories_page`、`merchants_page` 的 `_showMoveDialog`）→ `bookkeepingMode: false`
- `CommonSelectFormField` 的 tree 路径（`_showSelectionSheet` 中的 `TreeSelectSheet`）→ `bookkeepingMode: false`

### 配置编辑

分类/商户编辑弹窗（`_showEditDialog`）增加 `isBookkeepingSelectable` 开关（Switch），默认 true

---

## Feature B: 批量移动

### 交互流程

1. **浏览态**：正常树形列表，展开/折叠，右侧操作按钮
2. **长按任一节点** → 进入批量选择模式
3. **批量选择态**：
   - AppBar 标题变为 `已选择 N 项`，右侧显示"取消"按钮
   - 每个节点左侧显示 checkbox 勾选框
   - 点击节点 = 勾选/取消
   - 父节点勾选不影响子节点（只针对当前勾选项）
   - 底部滑出操作面板
4. **底部操作面板**：
   - 显示选中数量
   - "移动到..." 按钮 → 打开 `TreeSelectSheet（noShell: true）` 选择目标父节点 → 调用 `batchUpdatePositions` 批量更新
   - "取消选择" → 清空并退出
5. **AppBar "取消"** → 退出批量选择模式，清空勾选

### Provider 状态

在 `CategoryProvider` / `ShopProvider` 中新增：

```dart
bool _isBatchMode = false;
Set<String> _batchSelectedIds = {};  // 选中的节点 ID

void enterBatchMode()            // 进入批量模式（展开所有节点）
void exitBatchMode()             // 退出
void toggleBatchSelect(String id) // 切换选中
void selectAll()                 // 全选
void batchMove(String? targetParentId, {int sortOrder = 0}) // 批量移动到目标父节点
```

### 复用规则

- Provider 管理选中状态、批量移动业务逻辑
- 树形列表渲染（`_buildTreeTile`）根据 `_isBatchMode` 显示/隐藏 checkbox 和右侧操作按钮
- `batchMove` 复用已存在的 `batchUpdatePositions(ids, parentIds, sortOrders)` 驱动层方法

---

## 文件清单

### 数据层

| 文件 | 变更 |
|------|------|
| `lib/database/tables/account_category_table.dart` | 新增 `isBookkeepingSelectable` 列（Boolean，默认 true） |
| `lib/database/tables/account_shop_table.dart` | 同上 |
| `lib/database/dao/category_dao.dart` | 新增 `listAllByBook` 返回包含新字段 |
| `lib/database/dao/shop_dao.dart` | 同上 |

### 驱动层

| 文件 | 变更 |
|------|------|
| `lib/drivers/data_driver.dart` | `createCategory`/`createShop`/`updateCategory`/`updateShop` 接口新增 `isBookkeepingSelectable` 参数 |
| `lib/drivers/special/log.data_driver.dart` | 实现传递新字段 |
| `lib/drivers/special/log/builder/book_category.builder.dart` | `create`/`update` 方法新增 `isBookkeepingSelectable` 参数 |
| `lib/drivers/special/log/builder/book_shop.builder.dart` | 同上 |

### 业务层

| 文件 | 变更 |
|------|------|
| `lib/providers/category_provider.dart` | 新增 `_isBatchMode`、`_batchSelectedIds`、`enterBatchMode`、`exitBatchMode`、`toggleBatchSelect`、`batchMove` |
| `lib/providers/shop_provider.dart` | 同上 |

### 组件层

| 文件 | 变更 |
|------|------|
| `lib/widgets/common/tree_select/tree_select_sheet.dart` | 新增 `bookkeepingMode` 参数；`_onTapNode` 中不可选判断；`_isNodeSelectable` 方法 |
| `lib/widgets/common/tree_select/tree_select_item.dart` | 新增 `bookkeepingMode`、`isBookkeepingSelectable` 参数；灰色样式 |
| `lib/widgets/common/tree_select_form_field.dart` | 新增 `bookkeepingMode` 参数（默认 true） |

### UI 层

| 文件 | 变更 |
|------|------|
| `lib/pages/book/categories_page.dart` | 长按进入批量模式 + checkbox + 底部面板 + batchMove |
| `lib/pages/book/merchants_page.dart` | 同上 |
| `lib/pages/bookkeeping_rule/condition_editor.dart` | `TreeSelectFormField` 传 `bookkeepingMode: false` |
| `lib/pages/bookkeeping_rule/action_value_widgets.dart` | `TreeSelectFormField` 传 `bookkeepingMode: false` |

---

## 验证计划

1. `flutter analyze` — 零 lint 问题
2. 数据库迁移：新列成功创建，默认 true
3. `isBookkeepingSelectable = false` 测试：
   - 记账页面（item_add/edit）：节点灰色显示，点击仅展开，不选中
   - 管理页面移动弹窗：节点正常可选
   - 条件编辑器：正常可选
4. 批量移动测试：
   - 长按进入批量模式，多选节点
   - 移动到根目录 → 成功
   - 移动到指定节点 → 成功
   - 取消选择 → 清空并退出
   - 树刷新后勾选清除
