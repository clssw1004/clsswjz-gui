# 同步接口分页拉取改造方案

## Context

当前同步流程中，`POST /api/sync/changes` 一次性返回所有服务端变更。对于 35000+ 条数据初始同步场景，内存占用高、单次响应慢、前端处理长时间阻塞。日常同步场景虽数据量小，但也受限于同一接口设计。需要在前后端同时改造，参考 git push/pull 语义拆分 API，支持分页拉取变更，每次拉取 1000 条，处理完所有页后更新 lastSyncTime。

## 场景分析

需要涵盖两个场景：

| 场景 | 数据量 | 特点 |
|------|--------|------|
| **初始同步**（首次安装） | 35000+ 变化 | 全量拉取，priorityOnly 先拉 P0+P1，后台再拉 P2+P3 |
| **日常同步**（正常使用） | 0~50 变化 | 用户编辑后手动/自动触发，少量本地日志上传，少量服务端变更 |

分页对此两者的影响：
- **初始同步**：分页避免单次加载全部数据，UI 不卡死
- **日常同步**：totalChanges=0 时直接跳过 pull 阶段（比当前 API 更优，当前无法跳过），totalChanges 很小则只拉 1 页，多一次 push 调用开销可忽略

## 设计决策

- **方案 A**：所有分页拉取完成后再更新 lastSyncTime（不逐页更新）
- **API 拆分**：参考 git 设计，拆为 `push`（上传本地日志）+ `pull`（分页拉取变更）
- **commitId 机制**：push 时生成 commitId，缓存关联的日志 ID 列表，pull 时可选传入以排除刚推的日志
- **内存缓存**：使用 `lru-cache` npm 包替代原始的 `const cache = {}`
- **分页方式**：offset 分页（`page`/`pageSize`），排序 `operatedAt ASC`，并发冲突由客户端 `existIdsSet` 去重兜底

## 后端改动

### 1. 安装依赖

```bash
pnpm add lru-cache
```

### 2. 改造 `src/utils/cache.util.ts`

```typescript
import { LRUCache } from 'lru-cache';

const cache = new LRUCache<string, string>({
  max: 500,          // 最多缓存 500 个 key
  ttl: 5 * 60 * 1000, // 默认 TTL 5 分钟
});

export const setCache = (key: string, value: string) => {
  cache.set(key, value);
};

export const getCache = (key: string) => {
  return cache.get(key) ?? null;
};
```

- `lru-cache` 自带 TTL + LRU 淘汰，无需手动清理
- `max: 500` 控制内存上限，commitId 只需保留几分钟

### 3. DTO：`src/pojo/dto/log-sync/sync.dto.ts`

```typescript
// Push 请求（复用现有 SyncDto，不变）
export class SyncDto {
  logs: LogSync[];
  syncTimeStamp?: number;
  businessTypes?: string[];
}

// Push 响应（新增 commitId）
export class SyncPushResult {
  results: LogResult[];
  syncTimeStamp: number;
  totalChanges: number;    // 待拉取变更总数（估算，用于进度显示）
  commitId: string;        // 本次 push 生成的 commit ID
}

// Pull 请求（新增）
export class SyncPullDto {
  syncTimeStamp: number;    // 客户端原始 lastSyncTime（在整个分页过程中固定不变）
  businessTypes?: string[];
  page: number;             // 页码，从 1 开始
  pageSize: number;         // 每页条数，默认 1000
  commitId?: string;        // 可选，排除已 push 的日志
}

// Pull 响应
export class SyncPullResult {
  changes: LogSync[];
  total: number;            // 当前查询条件下的总条数（可能随并发 push 波动）
  page: number;
  pageSize: number;
  syncTimeStamp: number;    // 服务器当前时间戳（用于最终更新 lastSyncTime）
}
```

### 4. Controller：`src/controllers/sync.controller.ts`

```typescript
@Post('push')
async push(@Body() dto: SyncDto, @Request() req): Promise<SyncPushResult> {
  return await this.syncService.push(dto.logs, req.user.sub, dto.syncTimeStamp);
}

@Post('pull')
async pull(@Body() dto: SyncPullDto, @Request() req): Promise<SyncPullResult> {
  return await this.syncService.pull(req.user.sub, dto);
}
```

### 5. Service：`src/services/sync.service.ts`

**`push()` 方法 — 原有 `sync()` 改造：**
1. 处理每个日志（与现有 `sync()` 前半部分相同）
   - 遍历 logs，调用 processLog()
   - 兼容空 logs 场景（日常同步无本地变更时调用 push({logs: []})）
2. 生成 commitId = nanoid()
3. 缓存 `commitId → JSON.stringify(processedLogIds)`（TTL 5 分钟）
4. 统计待拉取变更总数 totalChanges（查询条件与 pull 相同，仅 count，不分页）
5. 返回 `{results, syncTimeStamp, totalChanges, commitId}`

**`pull()` 方法 — 新增：**
1. 构建查询条件：

   ```typescript
   const qb = this.logSyncRepository.createQueryBuilder('log')
     .select([...])
     .where('sync_state = :syncState', { syncState: SyncState.SYNCED })
     .andWhere('sync_time > :syncTime', { syncTime: dto.syncTimeStamp });
   
   if (dto.businessTypes?.length) {
     qb.andWhere('log.businessType IN (:...businessTypes)', { businessTypes: dto.businessTypes });
   }
   
   if (dto.commitId) {
     const excludeIds = getCache(`commit:${dto.commitId}`);
     if (excludeIds) {
       const ids = JSON.parse(excludeIds);
       qb.andWhere('log.id NOT IN (:...excludeIds)', { excludeIds: ids });
     }
   }
   
   const [changes, total] = await qb
     .orderBy('log.operatedAt', 'ASC')
     .skip((dto.page - 1) * dto.pageSize)
     .take(dto.pageSize)
     .getManyAndCount();
   ```

2. 脱敏处理（与现有相同）
3. 返回 `{changes, total, page: dto.page, pageSize: dto.pageSize, syncTimeStamp: now()}`

### 并发 push 的处理

- 分页过程中其他端 push 的日志不会被 commitId 排除（它们属于不同 commit）
- 如果新日志的 `operatedAt` 落在已拉取页范围 → 少量重复，客户端 `existIdsSet` 去重跳过
- 如果落在未拉取页范围 → 正常出现在后续 offset 页中
- 如果 offset 偏移造成少量遗漏 → 下个 sync 周期 catch up（最终一致性）
- `total` 值在页间可能微变，前端只用作分页终止判断，不减进度精度

## 前端改动

### 1. 模型：`lib/models/sync.dart`

拆分为两个独立的 DTO，不再共用一个 SyncResponseDTO：

```dart
/// Push 响应
class SyncPushResponse {
  final List<SyncResultDTO> results;
  final int syncTimeStamp;
  final int totalChanges;
  final String commitId;

  SyncPushResponse({...});
  factory SyncPushResponse.fromJson(Map<String, dynamic> json) => ...;
}

/// Pull 响应
class SyncPullResponse {
  final List<LogSync> changes;
  final int total;
  final int page;
  final int pageSize;
  final int syncTimeStamp;

  SyncPullResponse({...});
  factory SyncPullResponse.fromJson(Map<String, dynamic> json) => ...;
}
```

### 2. Service：`lib/services/sync_service.dart`

**`syncChanges()` 重构为 push + pull 两个阶段：**

```
syncChanges({onProgress, priorityOnly = false}):

  // 阶段 0：前置准备（不变）
  健康检查
  读取 lastSyncTime
  列出本地 unsynced 日志

  // 阶段 1：Push - 上传本地变更
  pushResult = await _pushClientChanges(
    logs: clientChanges,
    syncTimeStamp: lastSyncTime,
    onProgress: onProgress,
  )
  // pushResult = {results, syncTimeStamp: serverTs, totalChanges, commitId}

  // 阶段 2：Pull - 分页拉取服务端变更
  if (priorityOnly) {
    // ── 首次启动优先同步 ──
    // 只拉 P0+P1，不更新 lastSyncTime
    await _pullServerChanges(
      syncTimeStamp: lastSyncTime,   // ← 使用原始 lastSyncTime，固定不变
      businessTypes: _priorityTypes,
      commitId: pushResult.commitId,
      onProgress: onProgress,
    )
    // 启动后台同步（P2+P3 分页拉取）
    _startBackgroundSync(
      syncTimeStamp: lastSyncTime,
      commitId: pushResult.commitId,  // 后台拉取继续使用同一 commitId 排除
    )
    // priorityOnly 不更新 lastSyncTime，由后台完成后更新
  } else {
    // ── 完整同步（日常同步） ──
    if (pushResult.totalChanges > 0) {
      await _pullServerChanges(
        syncTimeStamp: lastSyncTime,
        commitId: pushResult.commitId,
        onProgress: onProgress,
      )
    }
    // 更新 lastSyncTime
    AppConfigManager.instance.setLastSyncTime(pushResult.syncTimeStamp);
  }
```

**`_pushClientChanges()` — 新方法：**

```dart
Future<SyncPushResponse> _pushClientChanges({
  required List<LogSync> logs,
  required int? syncTimeStamp,
  Function(double, String)? onProgress,
}) async {
  // 1. 上传附件（原有逻辑）
  await _uploadFiles(...);
  
  // 2. POST /api/sync/push
  final response = await HttpClient.instance.post<SyncPushResponse>(
    path: '/api/sync/push',
    data: {
      'logs': logs.map((e) => e.toJson()).toList(),
      'syncTimeStamp': syncTimeStamp,
    },
    transform: (data) => SyncPushResponse.fromJson(data['data']),
  );
  if (!response.ok) throw Exception(response.message);
  
  final result = response.data!;
  
  // 3. 更新本地日志同步状态（原有 _syncLogState 逻辑）
  await _syncLogState(results: result.results, ...);
  
  return result;
}
```

**`_pullServerChanges()` — 新方法：**

```dart
Future<void> _pullServerChanges({
  required int syncTimeStamp,
  List<String>? businessTypes,
  String? commitId,
  required Function(double, String) onProgress,
}) async {
  int page = 1;
  const pageSize = 1000;
  
  do {
    final response = await HttpClient.instance.post<SyncPullResponse>(
      path: '/api/sync/pull',
      data: {
        'syncTimeStamp': syncTimeStamp,
        if (businessTypes != null) 'businessTypes': businessTypes,
        'page': page,
        'pageSize': pageSize,
        if (commitId != null) 'commitId': commitId,
      },
      transform: (data) => SyncPullResponse.fromJson(data['data']),
    );
    if (!response.ok) throw Exception(response.message);
    
    final pullResult = response.data!;
    
    if (pullResult.changes.isNotEmpty) {
      await _applyChanges(
        changes: pullResult.changes,
        onProgress: onProgress,
        getProgressDetail: ...,
        progressStart: ..., progressEnd: ...,
      );
    }
    
    // total 可能在页间变化，这里用拉取时的 total 判断是否继续
    page++;
  } while ((page - 1) * pageSize < pullResult.total);  // 用当前页返回的 total
}
```

**后台同步改造（`_startBackgroundSync`）：**

```dart
void _startBackgroundSync(int syncTimeStamp, String? commitId) {
  Future.delayed(Duration(seconds: 3), () async {
    await _pullServerChanges(
      syncTimeStamp: syncTimeStamp,
      businessTypes: _backgroundTypes,
      commitId: commitId,          // 复用同一 commitId 排除已 push 日志
      onProgress: safeCallback,
    );
    // 后台全部拉取完成后更新 lastSyncTime
    AppConfigManager.instance.setLastSyncTime(...);
    EventBus.instance.emit(const SyncCompletedEvent());
  });
}
```

**关于进度常量：** 流程变化后进度值也需要对应调整：
```
progressStart:  0%   → 开始
progressPush:   50%  → push 阶段完成（上传日志、更新本地状态）
progressPull:   50%  → pull 阶段开始（分页拉取变更）
progressPull 内部按 (processedPageCount / totalPages) 或 (processedChanges / total) 递增
progressDone:  100%  → 完成
```

**日常同步 vs 初始同步的进度差异：**
- 日常同步：push (50%) → totalChanges=0 直接跳到 100%
- 初始同步：push (50%) → 多页 pull (50%~100%) 缓慢推进
- 这个差异可以通过 progress 常量和 `totalChanges` 判断来控制

### 3. `_syncClientChanges` 和 `_syncServerChanges` 的退役

- `_syncClientChanges` 拆分逻辑到 `_pushClientChanges`
- `_syncServerChanges` 被 `_pullServerChanges` 替代（原有的优先级分组 + 双重 _applyChanges 逻辑由 pull + _syncChanges 处理）
- `_applyChanges` 和 `_applyChangesSilent` 保留不动（核心的批处理/降级逻辑不变）

## 涉及修改的文件

### 后端
| 文件 | 改动 |
|------|------|
| `package.json` | 新增 `lru-cache` 依赖 |
| `src/utils/cache.util.ts` | 替换为 `lru-cache` 实现 |
| `src/pojo/dto/log-sync/sync.dto.ts` | 新增 `SyncPushResult`、`SyncPullDto`、`SyncPullResult` |
| `src/controllers/sync.controller.ts` | 拆分为 `POST /push` + `POST /pull` |
| `src/services/sync.service.ts` | 拆 `sync()` 为 `push()` + `pull()` |

### 前端
| 文件 | 改动 |
|------|------|
| `lib/models/sync.dart` | 拆分为独立的 `SyncPushResponse` / `SyncPullResponse` |
| `lib/services/sync_service.dart` | `_syncClientChanges` → `_pushClientChanges`，新增 `_pullServerChanges`，重构 `syncChanges` 流程，改造后台同步 |

## 验证方案

1. **日常同步**（无本地变更 + 服务端无变更）：push 返回 totalChanges=0 → 跳过 pull → 更新 lastSyncTime
2. **日常同步**（有少量本地变更 + 服务端少量变更）：push → 1 页 pull → 更新 lastSyncTime
3. **初始同步**（priorityOnly）：push → 多页 pull(P0+P1) → 后台继续多页 pull(P2+P3) → 更新 lastSyncTime
4. **commitId 排除**：push 的日志不出现在 pull 结果中（通过 total 校验）
5. **重复兼容**：不带 commitId 的 pull 正常返回（total 偏大，existIdsSet 去重）
6. **回归**：离线模式、手动同步、事件触发同步不受影响
