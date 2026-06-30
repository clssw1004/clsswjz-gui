# Category/Shop Selectable + Batch Move Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `isBookkeepingSelectable` column to category/shop tables, respect it in TreeSelectSheet, add batch move to categories/merchants pages.

**Architecture:** DB migration → Builder/Driver pass-through → Provider batch state → TreeSelectSheet bookkeepingMode → Categories/Merchants page batch UI → Call site updates.

**Tech Stack:** Flutter, Drift (SQLite), Provider

---

### Task 1: Add DB column + migration

**Files:**
- Modify: `lib/database/tables/account_category_table.dart`
- Modify: `lib/database/tables/account_shop_table.dart`
- Modify: `lib/database/database.dart` (schema version + migration)
- Generate: `flutter pub run build_runner build` (regenerate database.g.dart)

- [ ] **Step 1: Add column to category table**

In `lib/database/tables/account_category_table.dart`, add after `sortOrder`:

```dart
BoolColumn get isBookkeepingSelectable => boolean().withDefault(const Constant(true))();
```

In `toCreateCompanion` and `toUpdateCompanion`, add parameter:

```dart
bool isBookkeepingSelectable = true,  // parameter
isBookkeepingSelectable: Value(isBookkeepingSelectable),  // companion
```

- [ ] **Step 2: Add column to shop table**

Same pattern as category table. Add column + companion param.

- [ ] **Step 3: Add migration in database.dart**

Find `Database` class `migration` getter. Add schema version bump:

```dart
if (versionBefore < 3) {  // or current version + 1
  await m.addColumn(accountCategoryTable, accountCategoryTable.isBookkeepingSelectable);
  await m.addColumn(accountShopTable, accountShopTable.isBookkeepingSelectable);
}
```

Also bump `schemaVersion` getter to current+1.

- [ ] **Step 4: Run build_runner**

```bash
cd /Users/cuiwei/wspec/clsswjz-gui && flutter pub run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 5: Verify analyze**

```bash
flutter analyze lib/database/
```

- [ ] **Step 6: Commit**

```bash
git add lib/database/ && git commit -m "feat: add isBookkeepingSelectable column to category/shop tables"
```

---

### Task 2: Driver/Builder pass-through

**Files:**
- Modify: `lib/drivers/data_driver.dart`
- Modify: `lib/drivers/special/log.data_driver.dart`
- Modify: `lib/drivers/special/log/builder/book_category.builder.dart`
- Modify: `lib/drivers/special/log/builder/book_shop.builder.dart`

- [ ] **Step 1: Add to DataDriver interface**

In `lib/drivers/data_driver.dart`:

```dart
// In createCategory
Future<OperateResult<String>> createCategory(String userId, String bookId, {
  required String name, required String categoryType, String? code, String? parentId,
  bool isBookkeepingSelectable = true,  // NEW
});

// In updateCategory  
Future<OperateResult<void>> updateCategory(String userId, String bookId, String categoryId, {
  String? name, String? parentId, int? sortOrder, String? lastAccountItemAt,
  bool? isBookkeepingSelectable,  // NEW (nullable for partial update)
});

// Same for createShop/updateShop
```

- [ ] **Step 2: Add to LogDataDriver implementation**

In `lib/drivers/special/log.data_driver.dart`:

`createCategory`: pass `isBookkeepingSelectable` to `CategoryCULog.create()`
`updateCategory`: pass `isBookkeepingSelectable` to `CategoryCULog.update()`
`createShop`/`updateShop`: same pattern

- [ ] **Step 3: Add to CategoryCULog builder**

In `lib/drivers/special/log/builder/book_category.builder.dart`:

```dart
// In static create method
static CategoryCULog create(String who, String bookId, {
  required String name, required String categoryType,
  String? code, String? parentId, int sortOrder = 1,
  bool isBookkeepingSelectable = true,  // NEW
}) => CategoryCULog()
    ...
    .withData(AccountCategoryTableCompanion(
      ...
      isBookkeepingSelectable: Value(isBookkeepingSelectable),  // NEW
    ));

// In static update method
static CategoryCULog update(String who, String bookId, String id, {
  String? name, String? parentId, int? sortOrder,
  String? lastAccountItemAt, bool? isBookkeepingSelectable,  // NEW
}) => CategoryCULog()
    ...
    .withData(AccountCategoryTableCompanion(
      ...
      isBookkeepingSelectable: Value.absentIfNull(isBookkeepingSelectable),  // NEW
    ));
```

Same for `ShopCULog`.

- [ ] **Step 4: Handle in fromCreateLog/fromUpdateLog**

In `book_category.builder.dart`:

```dart
// In fromCreateLog
data.putIfAbsent('isBookkeepingSelectable', () => true);

// In fromUpdateLog  
isBookkeepingSelectable: data['isBookkeepingSelectable'] as bool?,
```

Same for shop builder.

- [ ] **Step 5: Verify and commit**

```bash
flutter analyze lib/drivers/
git add lib/drivers/ && git commit -m "feat: pass isBookkeepingSelectable through driver/builder layer"
```

---

### Task 3: Provider batch mode state

**Files:**
- Modify: `lib/providers/category_provider.dart`
- Modify: `lib/providers/shop_provider.dart`

- [ ] **Step 1: Add batch state to CategoryProvider**

In `lib/providers/category_provider.dart`:

```dart
bool _isBatchMode = false;
bool get isBatchMode => _isBatchMode;
Set<String> _batchSelectedIds = {};
Set<String> get batchSelectedIds => Set.unmodifiable(_batchSelectedIds);

void enterBatchMode() {
  _isBatchMode = true;
  notifyListeners();
}

void exitBatchMode() {
  _isBatchMode = false;
  _batchSelectedIds.clear();
  notifyListeners();
}

void toggleBatchSelect(String id) {
  if (_batchSelectedIds.contains(id)) {
    _batchSelectedIds.remove(id);
  } else {
    _batchSelectedIds.add(id);
  }
  if (_batchSelectedIds.isEmpty) {
    _isBatchMode = false;
  }
  notifyListeners();
}

Future<void> batchMove(String? targetParentId) async {
  if (_batchSelectedIds.isEmpty) return;
  final ids = _batchSelectedIds.toList();
  final parentIds = ids.map((_) => targetParentId).toList();
  final sortOrders = List.generate(ids.length, (_) => 0);
  await batchUpdatePositions(ids: ids, parentIds: parentIds, sortOrders: sortOrders);
  exitBatchMode();
}
```

- [ ] **Step 2: Same for ShopProvider**

Identical pattern, with `AccountShop`.

- [ ] **Step 3: Verify and commit**

```bash
flutter analyze lib/providers/
git add lib/providers/ && git commit -m "feat: add batch mode state to category/shop providers"
```

---

### Task 4: TreeSelectSheet/Item bookkeepingMode

**Files:**
- Modify: `lib/widgets/common/tree_select/tree_select_sheet.dart`
- Modify: `lib/widgets/common/tree_select/tree_select_item.dart`
- Modify: `lib/widgets/common/tree_select_form_field.dart`

- [ ] **Step 1: Add `bookkeepingMode` to TreeSelectSheet**

Add parameter:
```dart
final bool bookkeepingMode;
// constructor
this.bookkeepingMode = true,
```

Add `_isNodeSelectable` check in `_onTapNode`:
```dart
void _onTapNode(TreeNode<T> node) {
  if (widget.onNodeTap != null) {
    widget.onNodeTap!(node.data);
    return;
  }
  // NEW: bookkeeping mode check
  if (widget.bookkeepingMode && _isNodeNonSelectable(node.data)) {
    // Just toggle expand, don't select
    _onToggleExpand(node);
    return;
  }
  // ... rest of selection logic
}

bool _isNodeNonSelectable(dynamic data) {
  // Check by reflection or type: if data is AccountCategory/AccountShop 
  // and has isBookkeepingSelectable field
  final map = data is Map ? data : _toMap(data);
  final val = map['isBookkeepingSelectable'];
  return val == false;
}

Map<String, dynamic> _toMap(dynamic data) {
  if (data is AccountCategory) {
    return {'isBookkeepingSelectable': data.isBookkeepingSelectable};
  }
  if (data is AccountShop) {
    return {'isBookkeepingSelectable': data.isBookkeepingSelectable};
  }
  return {};
}
```

Actually, simpler: pass a `selectableCheck` callback. But types are different. Let me use a generic approach:

Add to TreeSelectSheet:
```dart
final bool Function(T data)? isSelectableCheck;
```

And `_onTapNode`:
```dart
if (widget.isSelectableCheck != null && !widget.isSelectableCheck!(node.data)) {
  if (node.children.isNotEmpty) _onToggleExpand(node);
  return;
}
```

- [ ] **Step 2: Pass isSelectableCheck through TreeSelectFormField**

In `lib/widgets/common/tree_select_form_field.dart`:

```dart
// For both multiSelect and singleSelect paths in _showPicker
TreeSelectSheet<T>(
  ...
  isSelectableCheck: (data) {
    // Default: all selectable
    return true;
  },
);
```

The actual check logic is caller-provided based on the data type.

- [ ] **Step 3: Add grey styling for non-selectable items in TreeSelectItem**

In `lib/widgets/common/tree_select/tree_select_item.dart`:
Add param `bool selectable = true`.
In build, when `!selectable`:
- Text: `color.withAlpha(100)` instead of full opacity
- LevelTab: `color.withAlpha(80)` instead of `color`
- Remove InkWell ripple effect (show don't indicate tap)

- [ ] **Step 4: Verify and commit**

```bash
flutter analyze lib/widgets/common/tree_select/
git add lib/widgets/common/tree_select/ && git commit -m "feat: add bookkeepingMode + selectable to TreeSelectSheet/Item"
```

---

### Task 5: Categories/Merchants page batch move UI

**Files:**
- Modify: `lib/pages/book/categories_page.dart`
- Modify: `lib/pages/book/merchants_page.dart`

- [ ] **Step 1: Restructure AppBar for batch mode**

In `categories_page.dart` `_buildTreeView`:
When `_provider.isBatchMode`:
- AppBar: title = "已选择 N 项", actions = ["取消" TextButton]
- Each tree tile: show checkbox on left, hide right-side action buttons
- Bottom: show batch action panel (SafeArea + "移动到..." button)

When not batch mode: current behavior.

- [ ] **Step 2: Add checkbox to tree tile in batch mode**

In `_buildTreeTile`, after the expand chevron (line 206):
```dart
if (_provider.isBatchMode)
  Checkbox(
    value: _provider.batchSelectedIds.contains(node.data.id),
    onChanged: (_) => _provider.toggleBatchSelect(node.data.id),
    visualDensity: VisualDensity.compact,
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
```

- [ ] **Step 3: Add bottom action panel for batch mode**

```dart
Widget _buildBatchPanel() {
  if (!_provider.isBatchMode || _provider.batchSelectedIds.isEmpty)
    return const SizedBox.shrink();
  return Container(
    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
    decoration: BoxDecoration(
      color: colorScheme.surface,
      border: Border(top: BorderSide(color: colorScheme.outline.withAlpha(20))),
    ),
    child: SafeArea(
      top: false,
      child: Row(children: [
        Text("已选择 ${_provider.batchSelectedIds.length} 项"),
        const Spacer(),
        FilledButton.icon(
          icon: const Icon(Icons.drive_file_move_outlined, size: 18),
          label: const Text('移动到...'),
          onPressed: () => _showBatchMoveDialog(),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => _provider.exitBatchMode(),
          child: const Text('取消选择'),
        ),
      ]),
    ),
  );
}
```

- [ ] **Step 4: Implement batch move dialog**

```dart
void _showBatchMoveDialog() async {
  // Same pattern as _showMoveDialog but without excluding any node
  // Uses TreeSelectSheet with noShell + onNodeTap
  ...
  TreeSelectSheet<AccountCategory>(
    ...
    noShell: true,
    onNodeTap: (data) async {
      Navigator.pop(ctx);
      await _provider.batchMove(data.id);
      // SnackBar success
    },
  );
}
```

Include a "根目录" button in the dialog header.

- [ ] **Step 5: Long press to enter batch mode**

In `_buildTreeTile`, add long press handler:
```dart
onLongPress: () {
  _provider.enterBatchMode();
  _provider.toggleBatchSelect(node.data.id);
},
```

- [ ] **Step 6: Same changes for merchants_page.dart**

Identical pattern — checkbox, batch panel, batch move dialog, long press handler.

- [ ] **Step 7: Verify and commit**

```bash
flutter analyze lib/pages/book/
git add lib/pages/book/ && git commit -m "feat: batch move UI for categories/merchants pages"
```

---

### Task 6: Update call sites (condition_editor, action_value_widgets)

**Files:**
- Modify: `lib/pages/bookkeeping_rule/condition_editor.dart`
- Modify: `lib/pages/bookkeeping_rule/action_value_widgets.dart`

- [ ] **Step 1: Pass selectable check to TreeSelectFormField in condition_editor**

Both category and shop `TreeSelectFormField` calls add:
```dart
isSelectableCheck: (data) => true,  // all selectable in filter mode
```

- [ ] **Step 2: Same for action_value_widgets**

```dart
isSelectableCheck: (s) => true,
```

- [ ] **Step 3: Commit**

```bash
git add lib/pages/bookkeeping_rule/ && git commit -m "chore: pass isSelectableCheck to rule editor tree selects"
```

---

### Task 7: Verify full project

- [ ] **Full analyze**

```bash
cd /Users/cuiwei/wspec/clsswjz-gui && flutter analyze
```

Expected: 0 new errors/warnings (pre-existing issues OK).

- [ ] **Push branch**

```bash
git push origin feat/category-selectable-batch-move
```
