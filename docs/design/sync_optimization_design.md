# 同步流程优化设计方案

## 一、背景

当前 SyncService 在首次安装同步时，需要等待所有数据同步完成才能进入 APP。对于 35000+ 条数据，逐条事务同步约每秒几百条，导致用户在首次进入 APP 前需要等待数分钟。

核心问题：
1. **无优先级区分**：所有 BusinessType 的数据在同步时同等对待，没有先同步基础元数据、再同步大量业务数据的策略
2. **逐条数据库操作**：`_syncServerChanges` 中每条变更都独立执行 `existById` 查询 + 独立事务，3.5 万条数据产生大量 DB 操作开销

优化目标：
- 首次安装时，基础元数据（用户、账本等）同步完成后即可进入 APP
- 大量业务数据（账目条目等）在后台继续同步
- 优化同步效率，减少数据库操作次数

## 二、优先级分类

### 2.1 层级定义

根据实体依赖关系，确保「最小可运行数据集」原则，将所有 BusinessType 划分为 4 个优先级层级：

| 层级 | 业务类型 | 说明 | 预估数据量 |
|------|----------|------|-----------|
| **P0（Critical）** | `user`, `book`, `bookMember` | APP 运行最低要求：用户身份、账本、成员关系 | 极少（≤几十条） |
| **P1（High）** | `fund`, `bookkeepingRule`, `recurringConfig` | 配置级数据：账户、记账规则、固定收支配置 | 极少（≤几十条） |
| **P2（Normal）** | `category`, `shop`, `symbol`, `item`, `itemRelation` | 核心业务数据：分类、商家、标签、账目条目（数据量最大） | 大量（数万条） |
| **P3（Low）** | `note`, `debt`, `giftCard`, `vehicle`, `fuelRecord`, `attachment`, `activity`, `activityDefinition`, `userShare` | 扩展模块数据 | 中等 |

### 2.2 设计原则

- **P0+P1 构成「最小可运行数据集」**：同步完这批数据后，APP 可以进入主页、看到账本列表、切换账户等基础操作。仅 `user` `book` `bookMember` `fund` `bookkeepingRule` `recurringConfig`，总共几十条记录，几乎瞬间完成
- **P2 是数据量最大的部分**：分类、商家、标签、账目条目等核心业务数据，数量可达数万条。P0+P1 同步完即可先进 APP，P2 数据在后台同步；缺少时账目列表为空（或显示 ID），不影响其他功能模块
- **P3 是独立扩展模块**：各模块之间没有强依赖关系，完全可以在后台静默同步

## 三、方案设计

### 3.1 总览

```
首次安装同步流程（优化后）：

用户完成服务器配置
    │
    ▼
POST /api/sync/changes（上传本地变更 + 获取服务端变更）
    │
    ▼
处理 P0 + P1 优先数据（Critical + High）
    │
    ├── 同步完成 → 用户进入 APP（调用 makeStorageInit + restartApp）
    │                   │
    │                   ▼
    │           后台异步处理 P2 + P3
    │                   │
    │           全部完成后更新 lastSyncTime
    │           触发 SyncCompletedEvent（各 Provider 刷新数据）
    │
    └── 如果后台同步未完成时重启 APP
                        │
                        ▼
                下次启动时重新触发全量同步
                （服务端基于 syncTimeStamp 仅返回新变更）
```

### 3.2 后端 API 配合改造

仅靠客户端过滤不够——首次同步时服务端仍然把所有 35000 条数据打包在一个 HTTP 响应里返回，网络传输和 JSON 序列化本身就是瓶颈。需要服务端支持按 `businessTypes` 过滤返回。

#### 3.2.1 接口变更

`POST /api/sync/changes` 请求体新增可选字段 `businessTypes`：

```json
// 首次安装 — 仅请求优先数据
{
  "logs": [],
  "syncTimeStamp": null,
  "businessTypes": ["user", "book", "bookMember", "fund", "bookkeepingRule", "recurringConfig"]
}

// 后台同步 — 请求剩余数据
{
  "logs": [],
  "syncTimeStamp": null,
  "businessTypes": ["category", "shop", "symbol", "item", "itemRelation", "note", "debt", "giftCard", "vehicle", "fuelRecord", "attachment", "activity", "activityDefinition", "userShare"]
}

// 日常同步 — 不传 businessTypes，返回全量（保持向后兼容）
{
  "logs": [...],
  "syncTimeStamp": 1699000000000
}
```

服务端处理逻辑：
- `businessTypes` 为空或不传 → 返回全量，行为不变
- `businessTypes` 有值 → 返回的 `changes` 仅包含匹配类型的 LogSync 记录
- `syncTimeStamp` 语义不变：记录本次同步的时间戳，下次同步仅返回此时间之后的变更
- **关键**：`syncTimeStamp` 应按服务端当前最大时间戳返回，不受 `businessTypes` 过滤影响。否则后台同步用上一次的 timestamp 会遗漏数据

#### 3.2.2 首次同步流程（客户端+服务端配合）

```
客户端                               服务端
  │                                    │
  │── POST /api/sync/changes ─────────→│
  │   {logs:[], syncTS:null,           │
  │    businessTypes:[P0+P1]}          │
  │                                    │── 查询所有类型的最新 timestamp = T
  │←── {changes:[P0+P1], syncTS:T} ──│── 过滤返回 P0+P1
  │                                    │
  │ 处理 P0+P1，进入 APP               │
  │                                    │
  │── POST /api/sync/changes ─────────→│  (后台异步发起)
  │   {logs:[], syncTS:null,           │
  │    businessTypes:[P2+P3]}          │
  │                                    │── 查询所有类型的最新 timestamp = T
  │←── {changes:[P2+P3], syncTS:T} ──│── 过滤返回 P2+P3
  │                                    │
  │ 处理 P2+P3，更新 lastSyncTime = T  │
```

两次请求的 `syncTimeStamp` 都是 `null`（首次同步），但 `syncTS` 返回值都是服务端同一个时间点 T。日常同步时客户端带 `syncTS: T`，服务端只返回 T 之后的变更。

### 3.3 SyncService 改造

#### 3.2.1 优先级分组

将 `_syncServerChanges` 拆分为三个核心方法：

```dart
/// 服务端变更同步入口
Future<void> _syncServerChanges({
  required List<LogSync> changes,
  required int syncTimestamp,
  Function(double percent, String message)? onProgress,
  bool priorityOnly = false,    // 仅同步 P0+P1
  bool backgroundMode = false,  // 后台模式（无进度回调）
}) async {
  final grouped = _groupByPriority(changes);
  
  if (priorityOnly) {
    // 首次启动：仅处理 P0+P1，剩余数据后台处理
    await _applyChangesByPriority(grouped, syncTimestamp, onProgress);
    _startBackgroundSync(grouped.backgroundChanges, syncTimestamp);
  } else if (backgroundMode) {
    // 后台模式：无进度回调，静默处理
    await _applyChangesByPriority(grouped, syncTimestamp, null);
    AppConfigManager.instance.setLastSyncTime(syncTimestamp);
    EventBus.instance.emit(const SyncCompletedEvent());
  } else {
    // 完整同步（非首次启动/手动触发）：按优先级顺序全部处理
    await _applyChangesByPriority(grouped, syncTimestamp, onProgress);
    AppConfigManager.instance.setLastSyncTime(syncTimestamp);
  }
}
```

#### 3.2.2 后台同步调度

```dart
void _startBackgroundSync(List<LogSync> changes, int syncTimestamp) {
  // 使用 Future.delayed 延后执行，确保 APP 导航完成
  Future.delayed(const Duration(seconds: 1), () async {
    try {
      await _syncServerChanges(
        changes: changes,
        syncTimestamp: syncTimestamp,
        backgroundMode: true,
      );
    } catch (e, stackTrace) {
      debugPrint('Background sync error: $e\n$stackTrace');
      // 后台同步失败不阻塞用户，下次启动时自动重试
    }
  });
}
```

#### 3.2.3 前台同步入口改造

```dart
Future<void> syncChanges({
  Function(double percent, String message)? onProgress,
  bool priorityOnly = false,
}) async {
  try {
    // ... 检查服务器健康状态 ...
    // ... 获取本地变更 ...
    // ... 上传本地变更到服务器（获取 SyncResponseDTO）...
    
    // 根据调用场景决定同步策略
    await _syncServerChanges(
      changes: syncResult.changes,
      syncTimestamp: syncResult.syncTimeStamp,
      onProgress: onProgress,
      priorityOnly: priorityOnly,
    );
    
    if (!priorityOnly) {
      // 完整同步完成后才更新 lastSyncTime
      AppConfigManager.instance.setLastSyncTime(syncResult.syncTimeStamp);
    }
  } catch (e, stackTrace) {
    // ...
  }
}
```

### 3.3 性能优化

#### 3.3.1 批量 ID 存在性检查（必做）

当前瓶颈：`_syncServerChanges` 中每条变更都执行一次 `existById` 查询，N 条变更 = N 次数据库查询。

优化方式：
- 在 `LogSyncDao` 中新增 `existIdsSet(List<String> ids)` 方法
- 一次性查询所有 ID，用 Set 实现 O(1) 查找

```dart
/// LogSyncDao 新增
Future<Set<String>> existIdsSet(List<String> ids) async {
  if (ids.isEmpty) return {};
  final rows = await (db.select(db.logSyncTable)
    ..where((tbl) => tbl.id.isIn(ids))
  ).get();
  return rows.map((e) => e.id).toSet();
}

/// SyncService 使用
final allIds = changes.map((e) => e.id).toList();
final existingIds = await DaoManager.logSyncDao.existIdsSet(allIds);
final existingSet = existingIds.toSet(); // HashSet, O(1) lookup

for (final change in changes) {
  if (!existingSet.contains(change.id) && change.businessType.isNotEmpty) {
    await DatabaseManager.db.transaction(() async {
      final log = LogBuilder.fromLog(change);
      await log.executeWithoutRecord();
      await DaoManager.logSyncDao.insert(change);
    });
  }
}
```

#### 3.3.2 同类型批量事务（可选，需验证）

设计取舍：单条事务的初衷是单条数据问题不影响其他数据同步。如果经性能评估后确认需要进一步优化，可按以下方案实现：

```dart
/// 根据 batchThreshold 决定是否启用批量模式
Future<void> _applyBatchIfNeeded(
  List<LogSync> changes,
  int syncTimestamp,
  int batchThreshold,
) async {
  // 按 businessType 分组
  final byType = <String, List<LogSync>>{};
  for (final change in changes) {
    byType.putIfAbsent(change.businessType, () => []).add(change);
  }
  
  for (final entry in byType.entries) {
    final typeChanges = entry.value;
    if (typeChanges.length >= batchThreshold) {
      await _applyBatchTypeChanges(typeChanges);
    } else {
      for (final change in typeChanges) {
        await _applySingleChange(change);
      }
    }
  }
}

/// 批量应用同类型变更（同一事务）
Future<void> _applyBatchTypeChanges(List<LogSync> changes) async {
  await DatabaseManager.db.transaction(() async {
    for (final change in changes) {
      final log = LogBuilder.fromLog(change);
      await log.executeWithoutRecord();
      // insert 暂时记录，事务提交后一次性写入
      await DaoManager.logSyncDao.insert(change);
    }
  });
}
```

**建议**：先实施 3.3.1 批量 ID 检查 + 优先级分批，评估效果后再决定是否启用 3.3.2。

### 3.4 SyncProvider 扩展

```dart
class SyncProvider extends ChangeNotifier {
  bool _syncing = false;
  bool _backgroundSyncing = false;  // 新增：后台同步中
  double _progress = 0.0;
  double _backgroundProgress = 0.0; // 新增：后台同步进度
  String? _currentStep;
  
  /// 仅同步优先数据（首次安装使用）
  Future<void> syncPriorityData() async {
    if (_syncing) return;
    _syncing = true;
    _progress = 0.0;
    _currentStep = null;
    notifyListeners();
    try {
      await ServiceManager.syncService.syncChanges(
        priorityOnly: true,
        onProgress: (progress, step) {
          _progress = progress.toDouble() / 100;
          _currentStep = step;
          notifyListeners();
        },
      );
    } finally {
      _syncing = false;
      _progress = 0.0;
      _currentStep = null;
      notifyListeners();
    }
  }
  
  /// 全量同步（现有方法，增加按优先级顺序处理）
  Future<void> syncData() async {
    // ... 保持原有逻辑，syncService 内部按优先级顺序处理 ...
  }
}
```

### 3.5 首次启动流程修改

#### 当前流程（首次安装自托管模式）

```
ServerConfigPage._initSelfhost()
  └─ authService.loginOrRegister()
  └─ AppConfigManager.storgeSelfhostMode()
  └─ DatabaseManager.init() + ServiceManager.init(syncInit: true)
  └─ syncProvider.syncData()       ← 等待全量同步完成（数分钟）
  └─ makeStorageInit()
  └─ RestartWidget.restartApp()
```

#### 优化后流程

```
ServerConfigPage._initSelfhost()
  └─ authService.loginOrRegister()
  └─ AppConfigManager.storgeSelfhostMode()
  └─ DatabaseManager.init() + ServiceManager.init(syncInit: true)
  └─ syncProvider.syncPriorityData()  ← 仅等待 P0+P1 同步完成（数秒）
  └─ makeStorageInit()
  └─ RestartWidget.restartApp()
      └─ 进入 APP 后，SyncManager._syncOnAppLaunch() 不再触发
          （因为 syncChanges 已在后台继续运行）
```

### 3.6 lastSyncTime 更新策略

| 场景 | 更新时机 |
|------|----------|
| 首次安装（优先级同步） | 后台 P2+P3 全部同步完成后更新 |
| 非首次启动（全量同步） | 全部变更处理完成后更新（保持现有行为） |
| 手动触发同步 | 全部变更处理完成后更新 |
| 后台同步失败 | 不更新，下次启动时自动重试 |

### 3.7 非首次启动（正常使用）的同步行为

现有行为（无需大改）：
1. `SyncManager._syncOnAppLaunch` 已是非阻塞后台同步
2. 优化后仅需在 `_syncServerChanges` 中按优先级顺序处理
3. 用户进入 APP 不受同步影响

事件触发自动同步保持全量同步行为（包含优先级排序）。

## 四、涉及修改的文件

| 文件 | 修改类型 | 说明 |
|------|----------|------|
| `lib/enums/business_type.dart` | 新增扩展 | 添加 `syncPriority` getter |
| `lib/services/sync_service.dart` | 核心修改 | 拆分 `_syncServerChanges` 为优先级分批 + 后台处理 |
| `lib/database/dao/log_sync_dao.dart` | 新增方法 | `existIdsSet` 批量 ID 存在性检查 |
| `lib/providers/sync_provider.dart` | 状态扩展 | 新增 `backgroundSyncing` 状态 + `syncPriorityData` 方法 |
| `lib/pages/settings/server_config_page.dart` | 调用调整 | 首次初始化调用 `syncPriorityData` |
| `lib/widgets/setting/self_host_form.dart` | UI 更新 | 显示优先级同步进度 |

## 五、边界情况

1. **后台同步未完成时 APP 被关闭**：后台 sync Future 会丢失。下次启动时，`_syncOnAppLaunch` 重新触发完整同步，`lastSyncTime` 未更新所以服务端仍返回未处理的变更
2. **后台同步时用户手动编辑数据**：本地编辑生成新的 `LogSync`（syncState=unsynced），下次完整同步时上传。不会与后台同步产生冲突
3. **后台同步时用户手动触发同步**：后台同步的 `_syncing` 标志防止并发，\**但后台同步使用`backgroundMode`，不在`SyncProvider`的`_syncing`锁范围内*\*，需确保后台同步与全量同步不互相干扰
4. **首次安装时用户退出初始化页面**：当前 `_initSelfhost` 中 sync 是 await 的，用户无法在同步完成前退出。优化后 `syncPriorityData` 只需数秒即可完成，体验明显改善
5. **多用户共享账本**：P0+P1 包含 user、book、bookMember，确保用户身份和权限信息优先同步，避免权限相关报错

## 六、验证方案

1. **首次安装性能验证**：
   - 在自托管服务器部署 35000+ 条数据（其中 item 占 30000+ 条）
   - 新设备首次安装，测量从完成服务器配置到进入 APP 的等待时间
   - 预期：从数分钟缩短至数秒

2. **首次安装数据完整性验证**：
   - 进入 APP 后检查：账本列表、分类、账户等基础数据是否显示
   - 等待后台同步完成后检查：账目条目总数是否与服务器一致

3. **非首次启动验证**：
   - 验证首页不因同步阻塞
   - 验证同步完成事件触发的 Provider 刷新正常

4. **后台同步容错验证**：
   - 后台同步过程中杀掉 APP
   - 重新启动，验证同步自动恢复且数据不丢失

5. **回归验证**：
   - 离线模式不受影响（无同步功能）
   - 手动同步按钮功能正常
   - 事件驱动的自动同步正常
   - 附件上传下载正常
