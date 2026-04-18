# 礼物卡模块设计方案

## 一、背景

用户需要开发一个独立的礼物卡模块，作为预付礼品卡使用，支持基础的过期功能。礼物卡模块独立于现有账本系统，不与账本关联。

## 二、模块介绍

### 2.1 功能概述

礼物卡（Gift Card）模块用于管理预付礼品卡，主要功能包括：

| 功能 | 说明 |
|------|------|
| 创建礼物卡 | 包含赠送人、接收人、描述、过期时间 |
| 状态管理 | 支持六种状态：草稿、已送出、已接收、已使用、已过期、已作废 |
| 礼物卡列表 | 分Tab查看：我收到的、我送出的 |
| 礼物卡详情 | 查看单张礼物卡详情，支持各种操作 |
| 编辑礼物卡 | 仅草稿状态可编辑内容 |
| 送出礼物卡 | 将草稿状态的卡片送出 |
| 接收礼物卡 | 已送出的卡片可被接收 |
| 标记已使用 | 已接收的卡片可标记为已使用 |
| 延期 | 已送出或已接收的卡片可延期 |
| 作废 | 非已使用/已作废状态的卡片可作废 |
| 删除礼物卡 | 仅草稿状态可删除 |

### 2.2 模块特性

- **独立模块**：不与现有账本系统关联，独立管理
- **基础过期功能**：记录过期时间，过期后显示状态
- **状态自动更新**：加载列表时自动检查并更新过期状态
- **日志驱动**：使用项目统一的日志驱动模式，数据变更记录到 log_sync_table
- **接收人选择**：可从账本关联成员中选择（去重、去掉自己），也可通过邀请码搜索

## 三、数据结构设计

### 3.1 数据库表设计

> **注意**：昵称字段不在数据库表中存储，查询时通过关联用户表翻译。

```dart
class GiftCardTable extends BaseBusinessTable {
  // 礼物卡ID (继承自 BaseBusinessTable，已有 id, createdAt, updatedAt, createdBy, updatedBy)

  // 赠送人用户ID
  TextColumn get fromUserId => text().named('from_user_id').withLength(min: 1, max: 64)();

  // 接收人用户ID
  TextColumn get toUserId => text().named('to_user_id').withLength(min: 1, max: 64)();

  // 礼品描述
  TextColumn get description => text().named('gift_description').nullable()();

  // 过期时间 (毫秒时间戳，0表示永久有效)
  IntColumn get expiredTime => integer().named('expired_time').withDefault(const Constant(0))();

  // 送出时间 (毫秒时间戳)
  IntColumn get sentTime => integer().named('sent_time').withDefault(const Constant(0))();

  // 接收时间 (毫秒时间戳)
  IntColumn get receivedTime => integer().named('received_time').withDefault(const Constant(0))();

  // 状态: draft(草稿), sent(已送出), received(已接收), used(已使用), expired(已过期), voided(已作废)
  TextColumn get status => text().named('status').withDefault(const Constant('draft'))();
}
```

**表字段说明：**

| 字段名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| id | TEXT | 是 | 礼物卡唯一标识 (UUID) |
| created_at | INTEGER | 是 | 创建时间 (毫秒时间戳) |
| updated_at | INTEGER | 是 | 更新时间 (毫秒时间戳) |
| created_by | TEXT | 是 | 创建人ID |
| updated_by | TEXT | 是 | 更新人ID |
| from_user_id | TEXT | 是 | 赠送人用户ID |
| to_user_id | TEXT | 是 | 接收人用户ID |
| gift_description | TEXT | 否 | 礼品描述 |
| expired_time | INTEGER | 是 | 过期时间 (毫秒时间戳，0表示永久有效) |
| sent_time | INTEGER | 是 | 送出时间 (毫秒时间戳) |
| received_time | INTEGER | 是 | 接收时间 (毫秒时间戳) |
| status | TEXT | 是 | 状态 (默认 draft) |

> **昵称翻译**：GiftCardVO 中的 fromUserNickname 和 toUserNickname 字段是在查询时通过关联用户表翻译的，不存储在数据库中。

### 3.2 枚举类型

```dart
enum GiftCardStatus {
  draft('draft'),       // 草稿
  sent('sent'),         // 已送出
  received('received'), // 已接收
  used('used'),         // 已使用
  expired('expired'),   // 已过期
  voided('voided');     // 已作废

  final String code;
  const GiftCardStatus(this.code);

  static GiftCardStatus fromCode(String code) =>
    values.firstWhere((e) => e.code == code, orElse: () => draft);

  String get text => switch(this) {
    draft => '草稿',
    sent => '已送出',
    received => '已接收',
    used => '已使用',
    expired => '已过期',
    voided => '已作废'
  };
}
```

### 3.3 数据模型

**GiftCardVO** - 值对象，用于页面展示：

```dart
class GiftCardVO {
  final String id;
  final String fromUserId;
  final String fromUserNickname;
  final String toUserId;
  final String toUserNickname;
  final String? description;
  final int expiredTime;
  final int sentTime;
  final int receivedTime;
  final GiftCardStatus status;
  final int createdAt;
  final int updatedAt;
  final String createdBy;
  final String updatedBy;

  bool get isExpired => status == GiftCardStatus.sent &&
      DateTime.now().millisecondsSinceEpoch > expiredTime && expiredTime > 0;

  bool get isPermanent => expiredTime <= 0;

  GiftCardStatus get effectiveStatus => isExpired ? GiftCardStatus.expired : status;
}
```

### 3.4 文件清单

| 层级 | 文件路径 | 说明 |
|------|----------|------|
| 数据库 | `lib/database/tables/gift_card_table.dart` | 表定义 |
| 数据库 | `lib/database/dao/gift_card_dao.dart` | DAO层 |
| 数据库 | `lib/database/database.dart` | 添加 GiftCardTable 到 Drift 数据库 |
| 枚举 | `lib/enums/gift_card_status.dart` | 状态枚举 |
| 枚举 | `lib/enums/gift_card.dart` | 查询类型枚举 (GiftCardQueryType) |
| 枚举 | `lib/enums/business_type.dart` | 添加 giftCard 业务类型 |
| 模型 | `lib/models/vo/gift_card_vo.dart` | 值对象 |
| 驱动接口 | `lib/drivers/data_driver.dart` | 定义礼物卡相关接口 |
| 驱动实现 | `lib/drivers/special/log.data_driver.dart` | 实现礼物卡相关方法 |
| 日志构建器 | `lib/drivers/special/log/builder/gift_card.builder.dart` | 日志驱动构建器 |
| 状态 | `lib/providers/gift_card_provider.dart` | 状态管理 |
| 事件 | `lib/events/special/event_book.dart` | 添加 GiftCardChangedEvent |
| 同步 | `lib/providers/sync_provider.dart` | 订阅礼物卡变更事件 |
| 状态注册 | `lib/manager/provider_manager.dart` | 注册 GiftCardProvider |
| DAO注册 | `lib/manager/dao_manager.dart` | 注册 GiftCardDao |
| 页面 | `lib/pages/gift_card/gift_card_list_page.dart` | 礼物卡列表页 |
| 页面 | `lib/pages/gift_card/gift_card_form_page.dart` | 礼物卡表单页 |
| 页面 | `lib/pages/gift_card/gift_card_detail_page.dart` | 礼物卡详情页 |
| 入口 | `lib/pages/tabs/mine_tab.dart` | 在"我的"页面添加入口 |
| 路由 | `lib/routes/app_routes.dart` | 路由配置 |

## 四、UX/UI 页面设计

### 4.1 入口设计

在"我的"（Mine）页面中添加礼物卡入口入口：

```
┌─────────────────────────────┐
│         我的                 │
│  ┌─────────────────────┐   │
│  │ 👤 用户头像/名称      │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 🎁 礼物卡管理        │  ← 点击进入礼物卡模块
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ 📁 账本管理          │   │
│  └─────────────────────┘   │
│  ┌─────────────────────┐   │
│  │ ⚙️ 设置              │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

### 4.2 礼物卡列表页

```
┌─────────────────────────────┐
│  ← 礼物卡                   │
├─────────────────────────────┤
│ [我收到的] [我送出的]       │ ← Tab切换
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ 🎁 生日礼物              │ │
│ │ 来自：张三               │ │
│ │ 有效期至 2026-12-31     │ │
│ │ 状态：已接收             │ │
│ └─────────────────────────┘ │
│ ┌─────────────────────────┐ │
│ │ 🎁 节日红包              │ │
│ │ 送给：李四               │ │
│ │ 尚未送出                 │ │
│ │ 状态：草稿               │ │
│ └─────────────────────────┘ │
│                             │
│                       [+]   │ ← 悬浮添加按钮
└─────────────────────────────┘
```

**页面特点：**
- 卡片式布局展示礼物卡，使用渐变色背景
- Tab切换：我收到的、我送出的
- 显示：描述、赠送人/接收人、有效期、状态、时间信息
- 支持下拉刷新
- 支持滑动删除（仅我送出的草稿状态）
- 悬浮按钮：创建礼物卡
- 点击卡片进入详情页

### 4.3 礼物卡表单页（创建/编辑）

```
┌─────────────────────────────┐
│  ← 创建礼物卡      [保存]   │
├─────────────────────────────┤
│                             │
│  赠送人                     │
│  ┌─────────────────────────┐ │
│  │ [当前用户显示名称]       │ │ ← 只读，显示用户昵称
│  └─────────────────────────┘ │
│                             │
│  接收人 *                    │
│  ┌─────────────────────────┐ │
│  │ 从账本成员中选择       ▼ │ │ ← 下拉选择
│  └─────────────────────────┘ │
│  或通过邀请码搜索            │
│  ┌─────────────────────────┐ │
│  │ 请输入邀请码        🔍   │ │
│  └─────────────────────────┘ │
│                             │
│  礼物描述                    │
│  ┌─────────────────────────┐ │
│  │ 请输入礼物描述（可选）   │ │
│  │                         │ │
│  └─────────────────────────┘ │
│                             │
│  过期时间                    │
│  ┌─────────────────────────┐ │
│  │ 永久有效         [开关] │ │
│  └─────────────────────────┘ │
│  (选择日期则默认为23:59:59) │
│                             │
└─────────────────────────────┘
```

**表单字段：**

| 字段 | 类型 | 必填 | 校验规则 |
|------|------|------|----------|
| 赠送人 | 只读 | 是 | 显示当前用户昵称 |
| 接收人 | 下拉选择/邀请码搜索 | 是 | 从账本成员中选择或通过邀请码搜索 |
| 礼物描述 | 多行文本 | 否 | 最大500字符 |
| 过期时间 | 日期选择/永久有效开关 | 否 | 不选择则永久有效，选择则到日，默认23:59:59 |

### 4.4 礼物卡详情页

```
┌─────────────────────────────┐
│  礼物卡详情                 │
│                             │
│  ┌───────────────────────┐ │
│  │ [状态]     有效期至   │ │
│  │      🎁              │ │
│  │   生日礼物           │ │
│  │   来自：张三         │ │
│  │                      │ │
│  │ 送出时间:2026-04-15  │ │
│  │ 创建时间:2026-04-10  │ │
│  └───────────────────────┘ │
│                             │
│  [    送出礼物卡    ]       │ ← 草稿状态显示
│  [    接收礼物卡    ]       │ ← 已送出状态显示
│  [  标记为已使用   ]       │ ← 已接收状态显示
│  [编辑] [延期] [作废]      │ ← 根据状态显示
│                             │
└─────────────────────────────┘
```

**页面特点：**
- 模拟实际礼物卡片布局，使用渐变色背景
- 展示完整礼物卡信息
- 根据状态显示不同操作按钮：
  - 草稿：编辑、送出、作废
  - 已送出：接收、延期、作废
  - 已接收：标记已使用、延期、作废
  - 已使用/已过期/已作废：仅显示信息

## 五、技术实现要点

### 5.1 DataDriver 接口定义

> **遵循原则**：只定义基础 CRUD 方法，业务操作通过 updateGiftCard 原子方式实现。

```dart
// lib/drivers/data_driver.dart

/// 创建礼物卡
Future<OperateResult<String>> createGiftCard(
  String userId, {
  required String toUserId,
  String? description,
  int? expiredTime,  // 毫秒时间戳，0或不传表示永久有效
});

/// 删除礼物卡（仅草稿状态）
Future<OperateResult<void>> deleteGiftCard(String userId, String giftCardId);

/// 更新礼物卡（原子方式，支持所有可更新字段）
Future<OperateResult<void>> updateGiftCard(
  String userId,
  String giftCardId, {
  String? toUserId,
  String? description,
  int? expiredTime,
  int? sentTime,
  int? receivedTime,
  String? status,
});

/// 获取礼物卡列表
/// [type] 查询类型：received(我收到的), sent(我送出的), all(全部)
Future<OperateResult<List<GiftCardVO>>> listGiftCards(
  String userId, {
  GiftCardQueryType type = GiftCardQueryType.all,
});

/// 获取礼物卡详情
Future<OperateResult<GiftCardVO>> getGiftCard(String userId, String giftCardId);
```

> **业务操作调用方式**（不在接口中定义，通过 updateGiftCard 实现）：
> - 送出：`.updateGiftCard(status: 'sent', sentTime: now)`
> - 接收：`.updateGiftCard(status: 'received', receivedTime: now)`
> - 延期：`.updateGiftCard(expiredTime: newTime)`
> - 作废：`.updateGiftCard(status: 'voided')`
> - 标记已使用：`.updateGiftCard(status: 'used')`

### 5.2 接收人获取逻辑

从当前用户所属账本的关联成员中获取可选择的接收人：

```dart
/// 获取当前用户可选择的接收人列表（从账本关联成员中获取，去重、去掉自己）
Future<List<({String userId, String nickname})>> getSelectableRecipients() async {
  final userId = AppConfigManager.instance.userId;

  // 1. 获取用户所属的所有账本
  final userBooks = await (db.select(relAccountbookUserTable)
        ..where((t) => t.userId.equals(userId)))
      .get();

  // 2. 获取这些账本的所有成员
  final bookIds = userBooks.map((ub) => ub.accountBookId).toList();
  final allMembers = await (db.select(relAccountbookUserTable)
        ..where((t) => t.accountBookId.isIn(bookIds)))
      .get();

  // 3. 去重、去掉自己
  final memberUserIds = allMembers
      .map((m) => m.userId)
      .where((id) => id != userId)
      .toSet()
      .toList();

  // 4. 查找用户信息
  final users = await userDao.findByIds(memberUserIds);

  return users.map((u) => (userId: u.id, nickname: u.nickname)).toList();
}
```

### 5.3 邀请码搜索

直接使用 UserDao 中已有的 findByInviteCode 方法：

```dart
/// 根据邀请码查找用户
Future<OperateResult<({String userId, String nickname})>> findUserByInviteCode(String inviteCode) async {
  final user = await DaoManager.userDao.findByInviteCode(inviteCode);
  if (user == null) {
    return OperateResult.failWithMessage(message: '邀请码无效');
  }
  return OperateResult.success((
    userId: user.id,
    nickname: user.nickname ?? user.username ?? '未知用户',
  ));
}
```

### 5.4 过期状态自动更新

在加载列表时检查过期时间，自动更新过期状态：

```dart
/// 检查并更新过期状态
Future<void> _checkAndUpdateExpiredStatus() async {
  final now = DateTime.now().millisecondsSinceEpoch;
  final expiredCards = await giftCardDao.findExpired(now);

  for (final card in expiredCards) {
    await giftCardDao.updateStatus(card.id, GiftCardStatus.expired.code);
  }
}
```

### 5.5 时间处理规范

- 所有时间字段存储为毫秒时间戳 (INTEGER)
- 使用 `DateUtil` 进行时间格式化
- 过期时间为0表示永久有效
- 用户选择日期后，默认追加时间 23:59:59

### 5.6 数据流向

```
UI层 (Pages)
    ↓ ↑
Provider层 (GiftCardProvider)
    ↓ ↑
Driver层 (LogDataDriver)
    ↓ ↑
日志构建器 (GiftCardCULog)
    ↓ ↑
DAO层 (GiftCardDao)
    ↓ ↑
Database层 (GiftCardTable)
```

## 六、状态流转

```
[草稿] --(送出)--> [已送出] --(接收)--> [已接收] --(标记已使用)--> [已使用]
   |                   |                  |
   +--(作废)---------> [已作废]           +--(作废)--> [已作废]
   |                                     |
   +---------------(过期)---------------> [已过期]
```

## 七、技术实现规范

### 7.1 DataDriver 接口设计原则

参考项目中其他模块的实现，DataDriver 中只定义基础的 CRUD 方法，不定义过多的业务专用方法。具体规范如下：

**应定义的接口：**
- `createGiftCard` - 创建礼物卡
- `deleteGiftCard` - 删除礼物卡
- `updateGiftCard` - 更新礼物卡（原子方式，支持所有可更新字段）
- `listGiftCards` - 获取礼物卡列表（支持类型过滤）
- `getGiftCard` - 获取单个礼物卡详情

**不应定义的接口（应通过 updateGiftCard 实现）：**
- ~~`sendGiftCard`~~ - 使用 `updateGiftCard(status: GiftCardStatus.sent.code, sentTime: now)`
- ~~`receiveGiftCard`~~ - 使用 `updateGiftCard(status: GiftCardStatus.received.code, receivedTime: now)`
- ~~`extendGiftCard`~~ - 使用 `updateGiftCard(expiredTime: newTime)`
- ~~`voidGiftCard`~~ - 使用 `updateGiftCard(status: GiftCardStatus.voided.code)`
- ~~`markAsUsed`~~ - 使用 `updateGiftCard(status: GiftCardStatus.used.code)`

**updateGiftCard 接口设计：**
```dart
Future<OperateResult<void>> updateGiftCard(
  String userId,
  String giftCardId, {
  String? toUserId,
  String? description,
  int? expiredTime,
  int? sentTime,
  int? receivedTime,
  String? status,
});
```

### 7.2 操作权限规范

为保证业务逻辑清晰，操作权限遵循以下规则：

| 操作 | 权限要求 | 说明 |
|------|----------|------|
| 创建 | 当前用户 | 赠送人默认为当前登录用户 |
| 编辑 | 赠送人 + 草稿状态 | 仅草稿状态可编辑 |
| 送出 | 赠送人 + 草稿状态 | 赠送人操作 |
| 接收 | 接收人 + 已送出状态 | 接收人操作 |
| 标记已使用 | 赠送人 + 已接收状态 | 由赠送人确认已使用 |
| 延期 | 赠送人 + 已送出/已接收状态 | 仅赠送人可延期 |
| 作废 | 赠送人 + 非已使用/非已作废状态 | 仅赠送人可作废 |
| 删除 | 赠送人 + 草稿状态 | 仅草稿状态可删除 |

### 7.3 数据同步机制

礼物卡操作后需要同步到云端，采用事件驱动模式：

**事件定义（lib/events/special/event_book.dart）：**
```dart
class GiftCardChangedEvent {
  final GiftCardVO giftCard;
  final OperateType operateType;
  const GiftCardChangedEvent(this.operateType, this.giftCard);
}
```

**Provider 中触发同步（lib/providers/gift_card_provider.dart）：**
```dart
// 操作成功后触发同步事件
EventBus.instance.emit(GiftCardChangedEvent(OperateType.update, card));
```

**SyncProvider 订阅事件（lib/providers/sync_provider.dart）：**
```dart
void _subscribeToEvents() {
  _subscriptions.addAll([
    // ... 其他事件
    EventBus.instance.on<GiftCardChangedEvent>(_handleGiftCardChanged),
  ]);
}

void _handleGiftCardChanged(GiftCardChangedEvent event) {
  // 礼物卡任何操作都需要同步
  syncData();
}
```

### 7.4 页面导航与状态保持

**列表页返回时保持之前的 Tab：**

1. GiftCardListPage 支持接收初始 tab 索引参数：
```dart
class GiftCardListPage extends StatefulWidget {
  final int? initialTabIndex;
  const GiftCardListPage({super.key, this.initialTabIndex});
}
```

2. 路由配置支持传递 tab 参数：
```dart
giftCardList: (context) {
  final args = ModalRoute.of(context)?.settings.arguments;
  final tabIndex = args is int ? args : 0;
  return GiftCardListPage(initialTabIndex: tabIndex);
},
```

3. 详情页操作后返回对应 tab：
```dart
// 接收操作后返回"我收到的"tab (索引0)
Navigator.pop(context, 0);
// 送出/标记已使用/作废后返回"我送出的"tab (索引1)
Navigator.pop(context, 1);
```

4. 列表页处理返回结果：
```dart
void _navigateToDetail(BuildContext context, GiftCardVO card) async {
  final result = await Navigator.pushNamed(
    context,
    AppRoutes.giftCardDetail,
    arguments: card,
  );
  if (result is int && mounted) {
    _tabController.animateTo(result);
  }
}
```

### 7.5 按钮样式规范

参考项目中其他模块（如 item_add_page.dart）的按钮样式：

**主要操作按钮（FilledButton）：**
- 高度：48
- 内边距：horizontal 32, vertical 16
- 用于：送出、接收、标记为已使用等主要操作

**次要操作按钮（OutlinedButton）：**
- 高度：44
- 内边距：horizontal 24, vertical 12
- 布局：使用 Wrap 替代 Row + Expanded，支持自适应换行
- 间距：spacing 12, runSpacing 12
- 用于：编辑、延期、作废等次要操作

### 7.6 编辑页面下拉选项处理

编辑礼物卡时，接收人可能是账本成员之外的用户，需要确保下拉选项中包含当前接收人：

```dart
void _ensureRecipientInOptions() {
  if (_toUserId != null && _toUserNickname != null) {
    final exists = _recipientOptions.any((o) => o.userId == _toUserId);
    if (!exists) {
      _recipientOptions.add(RecipientOption(
        userId: _toUserId!,
        nickname: _toUserNickname!,
      ));
    }
  }
}
```

在 initState 中调用，确保编辑时不会因为接收人不在下拉列表中而报错。

## 八、验证测试点

1. **创建功能**：选择接收人，设置描述和过期时间，成功创建礼物卡
2. **列表显示**：验证Tab切换正常显示"我收到的"和"我送出的"
3. **接收人选择**：验证可从下拉列表选择，可通过邀请码搜索
4. **送出功能**：草稿状态的卡片可送出，记录送出时间
5. **接收功能**：已送出的卡片可被接收，记录接收时间
6. **标记已使用**：已接收的卡片可标记为已使用
7. **延期功能**：已送出或已接收的卡片可延期
8. **作废功能**：非已使用/已作废状态的卡片可作废
9. **编辑功能**：仅草稿状态可编辑
10. **删除功能**：仅草稿状态可删除
11. **过期自动更新**：验证过期状态自动更新
12. **永久有效**：过期时间为0时显示"永久有效"