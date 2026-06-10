# 非账本数据权限机制设计

## 背景

当前权限体系完全围绕账本展开：`rel_accountbook_user_table` 控制账本内数据的可见性。非账本实体（车辆、油耗记录、债务、附件等）没有权限控制，所有用户都能看到全部数据。

随着债务即将脱离账本作用域、未来更多非账本功能加入，需要一个通用的权限机制。

## 设计目标

1. 通用性：适用于所有非账本实体（现有 + 未来新增）
2. 简单：家庭场景用户数少（<10），不需要 RBAC 等复杂模型
3. 低侵入：不对实体表做任何修改，不改动 DAO 和同步逻辑
4. 兼容现有同步机制
5. 不影响账本已有权限体系

## 方案：用户间模块共享模型

**核心思路**：不在实体上挂权限，而是按"模块"（business type）粒度进行用户到用户的直接共享。用户 A 将"车辆"模块共享给用户 B，则 B 能看到 A 创建的所有车辆。

不需要创建组，不需要在实体表上加字段，不需要改 LogBuilder。

### 新增表

#### `rel_user_share`（用户模块共享）

| 列 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | UUID |
| owner_user_id | TEXT | 数据拥有者 |
| target_user_id | TEXT | 被共享用户 |
| business_type | TEXT | 模块类型（vehicle, fuelRecord, debt 等）|
| created_at | INTEGER | 共享时间 |
| UNIQUE | (owner_user_id, target_user_id, business_type) | |

不继承任何基类，只有必要的字段。

### 不受影响的模块

以下模块已有自身的可见性控制，不纳入共享系统：

| 模块 | 原因 |
|------|------|
| GiftCard（礼物卡） | 已有 fromUserId / toUserId 控制 |
| Attachment（附件） | 通过 businessCode + businessId 跟随父实体 |

### 查询模式

在 **DataDriver 层** 的列表查询方法中增加权限过滤，DAO 层不改。

```dart
// 在 log.data_driver.dart 的 listXxx 方法中
@override
Future<OperateResult<List<VehicleVO>>> listVehicles(String userId) async {
  try {
    // 1. 查出谁把车辆模块共享给了当前用户
    final sharedBy = await DaoManager.userShareDao.findOwnersByTarget(
      userId, BusinessType.vehicle.code);
    
    // 2. 查询自己创建的 + 别人共享的
    final vehicles = await DaoManager.vehicleDao.findByCreatorOrShared(
      userId, sharedBy);
    
    final vos = vehicles.map((v) => VehicleVO.fromVehicle(v)).toList();
    return OperateResult.success(vos);
  } catch (e) { ... }
}
```

对应 DAO 查询：
```sql
WHERE created_by = :currentUserId
   OR created_by IN (:sharedByUserIds)
ORDER BY ...
```

不需要子查询，不需要 junction table，不需要实体表权限字段。

### 与同步机制的兼容

- 同步逻辑完全不变（同步只关心 LogSync，不关心可见性）
- 服务端收到变更请求时按 operatorId 信任（现有机制）
- permission 数据（rel_user_share）本身也需要同步——通过 `noParent()` LogBuilder 记录

### 与账本权限的关系

| 维度 | 账本权限 | 模块共享 |
|------|---------|---------|
| 范围 | 账本内数据 | 非账本实体 |
| 控制表 | `rel_accountbook_user` | `rel_user_share` |
| 粒度 | 6 个布尔标记 | 模块级（business type） |
| 实体侵入 | 无（实体通过 accountBookId 关联） | 无（实体不含权限字段） |
| 适用 | items, categories, funds, notes... | vehicles, fuel records, debts... |

### 与数据驱动架构的关系

参考 `docs/design/data_driver_guide.md` 分层：

```
写入流程：UI → Provider → Driver → LogBuilder → DAO → Database + LogSync
                                                  ↕
                                           rel_user_share 表
读取流程：UI → Provider → Driver → DAO → Database
                         ↕
              按 userId + sharedBy 过滤
```

- **写入**：`rel_user_share` 通过 LogBuilder 写入（确保同步）
- **读取**：Driver 层组装 sharedBy 列表传给 DAO 做过滤
- **DAO 层**：不感知权限，只提供 `findByCreatorOrShared(userId, sharedBy)` 等查询方法
- **UI 层**：不直接操作权限数据，通过 Provider → Driver 访问

### UI 交互

#### 1. 共享设置页面（设置页内）

**入口**："我的" Tab → 设置区 → `CommonSettingTile`（`share` 图标）→ "数据共享"

**页面结构**：List 展示所有其他用户（非自己的用户列表），每个用户行展示共享开关。

```
┌──────────────────────────────┐
│  ← 数据共享                  │
├──────────────────────────────┤
│  共享给其他用户              │
│                              │
│  ┌──────────────────────────┐│
│  │ [头像] 张三              ││
│  │  车辆     [开关]         ││
│  │  油耗记录 [开关]         ││
│  │  债务     [开关]         ││
│  └──────────────────────────┘│
│  ┌──────────────────────────┐│
│  │ [头像] 李四              ││
│  │  车辆     [开关]         ││
│  │  油耗记录 [开关]         ││
│  │  债务     [开关]         ││
│  └──────────────────────────┘│
└──────────────────────────────┘
```

**交互逻辑**：
- 每行显示一个用户
- 用户下按模块列出 Switch（车辆、油耗记录、债务）
- 打开开关 → 创建 `rel_user_share` 记录（走 LogBuilder）
- 关闭开关 → 删除 `rel_user_share` 记录
- 没有组的概念，不需要邀请码

用户列表来源：通过 `UserDao.findSelectableRecipients(userId)` 获取（已有方法，返回所有其他账本成员）。

#### 2. 实体列表中的共享标识

- 他人共享的实体，卡片上显示 `SharedBadge`（复用 `lib/widgets/common/shared_badge.dart`）
  - 文字："来自 {创建者}" 
- 自己创建的实体：无标识
- 只在被共享的模块列表中显示此标识

#### 3. 实体列表查询变化

各非账本实体的 Provider 在 `loadItems` 时：
- 获取当前用户被共享了哪些模块
- 如果当前模块匹配，获取共享用户的 ID 列表
- 传给 Driver 做权限过滤

**无需在实体编辑页加共享范围选择器**——共享是模块级的，不是实体级的。

### 实现步骤

| 步骤 | 内容 | 涉及文件 |
|------|------|---------|
| 1 | 新增 `rel_user_share` 表 + DAO + LogBuilder | `database/tables/`, `database/dao/`, `log/builder/` |
| 2 | 更新 `AppDatabase` schemaVersion + migration | `database/database.dart` |
| 3 | 注册 DAO 到 `DaoManager` | `manager/dao_manager.dart` |
| 4 | Driver 接口 + 实现：shareModule / unshareModule / getSharedModules | `drivers/data_driver.dart`, `log.data_driver.dart` |
| 5 | SharedModuleProvider（读取用户被共享的模块+共享者列表） | `providers/` |
| 6 | 各非账本 Driver 的 list 方法增加权限过滤 | `log.data_driver.dart`（listVehicles 等） |
| 7 | UI 共享设置页面 | `pages/settings/` |
| 8 | MineTab 入口 + 路由 | `tabs/mine_tab.dart`, `routes/app_routes.dart` |
| 9 | 实体列表 `SharedBadge` 展示 | 各列表页 |

### 未来扩展

- **权限级别细化**：可将 `rel_user_share` 增加 `can_edit` 列（当前仅可见性控制）
- **服务端校验**：同步时服务端验证用户是否被共享了对应模块的读权限

## 验证

1. 将车辆模块共享给用户 B → B 能看到 A 创建的所有车辆
2. 未共享油耗记录模块 → B 看不到 A 的油耗记录
3. 关闭共享 → B 立即看不到 A 的车辆
4. 账本内数据权限不受影响
5. 同步数据正常（rel_user_share 通过 LogBuilder 同步）
