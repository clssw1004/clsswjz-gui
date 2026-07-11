# 同步接口分页拉取设计方案

## 背景

当前同步流程使用 `POST /api/sync/changes` 一个接口同时处理本地日志上传和服务端变更拉取，且变更拉取一次性返回所有数据。在初始同步 35000+ 条数据的场景下，存在以下问题：

1. 单次响应数据量大，内存占用高
2. 前端需等待全部数据返回后才能开始处理
3. 无法按需分批拉取，进度汇报不精确
4. 日常同步与初始同步共用同一接口，无法针对优化

## 目标

参考 git push/pull 语义拆分同步 API，支持分页拉取服务端变更，每次拉取 1000 条。

## 设计

### API 拆分

| 接口 | 语义 | 职责 |
|------|------|------|
| `POST /api/sync/push` | git push | 上传本地变更日志到服务端，返回处理结果 |
| `POST /api/sync/pull` | git pull | 分页拉取服务端变更到本地 |

### commitId 机制

Push 时服务端生成 commitId（nanoid），将本次处理的日志 ID 列表以 `commit:{commitId}` 为 key 缓存到 LRU 缓存中（TTL 5 分钟）。Pull 时客户端可选传入 commitId，服务端通过缓存查找排除已 push 的日志，避免 push 上去的日志又被 pull 回来。

```
Push → 处理日志 → 生成 commitId → 缓存 processedLogIds → 返回 {commitId, totalChanges, ...}
Pull(syncTimeStamp, commitId, page, pageSize) → 查缓存 -> excludeIds → 分页查询 → 返回 {changes, total, ...}
```

### 缓存实现

使用 `lru-cache` npm 包：

```typescript
const cache = new LRUCache<string, string>({
  max: 500,               // 最多缓存 500 个 key
  ttl: 5 * 60 * 1000,    // TTL 5 分钟
});
```

LRU + TTL 自动淘汰，无需手动清理。

### 分页方案

- 排序字段：`log.operatedAt ASC`
- 分页方式：offset 分页（`page` + `pageSize`）
- 过滤条件：`sync_state = 'synced' AND sync_time > :syncTimeStamp`（可选加 businessTypes、commitId 排除）
- 同步时间戳在整个分页过程中固定不变，所有分页共用同一个查询基准时间点

### 并发处理

分页拉取过程中，其他客户端 push 的日志会导致：
- 少量重复（新日志进到已拉取页）：客户端 `existIdsSet` 去重跳过
- 少量遗漏（offset 偏移）：下个同步周期 catch up
- 最终一致性有保证

## 交互流程

### 日常同步（少量变更）

```
Client                           Server
  │                                │
  │── POST /api/sync/push ────────→│ 上传本地日志（可能为空）
  │   {logs, syncTimeStamp}        │ 处理日志，生成 commitId
  │←──── {results, syncTimeStamp,  │ 统计 totalChanges
  │       totalChanges, commitId}──│
  │                                │
  │ (totalChanges=0 → 跳过 pull)   │
  │                                │
  │── 更新 lastSyncTime ──────────→│
```

### 初始同步（大量变更）

```
Client                           Server
  │                                │
  │── POST /api/sync/push ────────→│
  │←─── {commitId, totalChanges} ──│
  │                                │
  │── POST /api/sync/pull ────────→│  第一页
  │   {syncTimeStamp, commitId,    │
  │    page:1, pageSize:1000}      │
  │←── {changes[1000], total:35000,│
  │     page:1, pageSize:1000}   ──│
  │                                │
  │── POST /api/sync/pull ────────→│  第二页
  │   {syncTimeStamp, commitId,    │
  │    page:2, pageSize:1000}      │
  │←── {changes[1000], total:35000,│
  │     page:2, pageSize:1000}   ──│
  │        ...                     │  ...重复直到全部拉完
  │                                │
  │── 更新 lastSyncTime ──────────→│
```

### 优先同步（首次安装）

```
Client                           Server
  │                                │
  │── POST /api/sync/push ────────→│  推送全部本地日志
  │←─── {commitId, totalChanges} ──│
  │                                │
  │── POST /api/sync/pull ────────→│  只拉 P0+P1（businessTypes）
  │   {businessTypes: ["user",     │
  │    "book",..., "fund"...],     │
  │    page:1, pageSize:1000}      │
  │←── {changes[P0+P1], total:500}─│
  │        ...                     │  继续拉完 P0+P1
  │                                │
  │── 进入 APP ───────────────────→│
  │                                │
  │  (后台 3 秒后)                  │
  │── POST /api/sync/pull ────────→│  拉取 P2+P3（无 commitId）
  │   {businessTypes: ["item",     │
  │    "note",...],                │
  │    page:1, pageSize:1000}      │
  │←── {changes[P2+P3], total:34500│
  │        ...                     │  继续拉完 P2+P3
  │                                │
  │── 更新 lastSyncTime ──────────→│
  │── emit SyncCompletedEvent ────→│
```

## 数据结构

### Push 请求（复用现有 SyncDto）

```typescript
class SyncDto {
  logs: LogSync[];
  syncTimeStamp?: number;
}
```

### Push 响应

```typescript
class SyncPushResult {
  results: LogResult[];
  syncTimeStamp: number;
  totalChanges: number;
  commitId: string;
}
```

### Pull 请求

```typescript
class SyncPullDto {
  syncTimeStamp: number;
  businessTypes?: string[];
  page: number;
  pageSize: number;
  commitId?: string;
}
```

### Pull 响应

```typescript
class SyncPullResult {
  changes: LogSync[];
  total: number;
  page: number;
  pageSize: number;
  syncTimeStamp: number;
}
```

## 涉及修改的文件

### 后端

| 文件 | 改动 |
|------|------|
| `package.json` | 新增 `lru-cache` 依赖 |
| `src/utils/cache.util.ts` | 使用 lru-cache 重构 |
| `src/pojo/dto/log-sync/sync.dto.ts` | 新增 push/pull DTO |
| `src/controllers/sync.controller.ts` | 拆分为 push + pull |
| `src/services/sync.service.ts` | 拆 sync() 为 push() + pull() |

### 前端

| 文件 | 改动 |
|------|------|
| `lib/models/sync.dart` | 拆为 SyncPushResponse / SyncPullResponse |
| `lib/services/sync_service.dart` | 重构为 push + pull 循环 |
