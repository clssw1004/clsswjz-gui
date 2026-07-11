/// 账本操作业务类型
enum BusinessType {
  /// 根
  root('root'),

  /// 账目
  item('item'),

  /// 退款
  refund('refund'),

  /// 记事
  note('note'),

  /// 账本
  book('book'),

  /// 账本成员
  bookMember('bookMember'),

  /// 账本成员
  funBook('fundBook'),

  /// 账户
  fund('fund'),

  /// 分类
  category('category'),

  /// 商家
  shop('shop'),

  /// 标识（标签、项目）
  symbol('symbol'),

  /// 用户
  user('user'),

  /// 附件
  attachment('attachment'),

  /// 债务
  debt('debt'),

  /// 礼物卡
  giftCard('giftCard'),

  /// 活动
  activity('activity'),

  /// 活动定义
  activityDefinition('activityDefinition'),

  /// 车辆
  vehicle('vehicle'),

  /// 加油记录
  fuelRecord('fuelRecord'),

  /// 账目关联
  itemRelation('itemRelation'),

  /// 用户模块共享
  userShare('userShare'),

  /// 固定收支配置
  recurringConfig('recurringConfig'),

  /// 记账规则
  bookkeepingRule('bookkeepingRule');

  final String code;
  const BusinessType(this.code);

  static BusinessType? fromCode(String? code) {
    if (code == null) return null;
    return BusinessType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => throw Exception('Invalid business type code: $code'),
    );
  }
}

/// 账本操作类型
enum AccountBookOperateType {
  /// 更新
  update('update'),

  /// 创建
  create('create'),

  /// 删除
  delete('delete'),

  /// 批量更新
  batchUpdate('batchUpdate'),

  /// 批量创建
  batchCreate('batchCreate'),

  /// 批量删除
  batchDelete('batchDelete');

  final String code;
  const AccountBookOperateType(this.code);

  static AccountBookOperateType? fromCode(String? code) {
    if (code == null) return null;
    return AccountBookOperateType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => throw Exception('Invalid operate type code: $code'),
    );
  }
}

/// 数据同步优先级
enum SyncPriority {
  /// 关键 - 用户、账本等基础数据，必须优先同步
  critical,

  /// 高 - 账目依赖数据，同步完即可进入APP
  high,

  /// 中 - 核心业务数据（数据量大）
  normal,

  /// 低 - 扩展模块数据
  low,
}

/// BusinessType 到同步优先级的映射
extension BusinessTypeSyncPriority on BusinessType {
  SyncPriority get syncPriority {
    switch (this) {
      // P0: 身份与权限 - 条目极少，APP 进入的最低要求
      case BusinessType.user:
      case BusinessType.book:
      case BusinessType.bookMember:
        return SyncPriority.critical;
      // P1: 配置级数据 - 条目很少，基本功能依赖
      case BusinessType.fund:
      case BusinessType.bookkeepingRule:
      case BusinessType.recurringConfig:
        return SyncPriority.high;
      // P2: 核心业务数据 - 数据量大，但缺少时不影响 APP 基础展示
      case BusinessType.category:
      case BusinessType.shop:
      case BusinessType.symbol:
      case BusinessType.item:
      case BusinessType.itemRelation:
        return SyncPriority.normal;
      // P3: 扩展模块 - 独立模块数据，可在后台静默同步
      case BusinessType.root:
      case BusinessType.refund:
      case BusinessType.funBook:
      case BusinessType.note:
      case BusinessType.debt:
      case BusinessType.giftCard:
      case BusinessType.activity:
      case BusinessType.activityDefinition:
      case BusinessType.vehicle:
      case BusinessType.fuelRecord:
      case BusinessType.attachment:
      case BusinessType.userShare:
        return SyncPriority.low;
    }
  }
}
