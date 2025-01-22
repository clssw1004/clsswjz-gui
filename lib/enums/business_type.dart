/// 账本操作业务类型
enum BusinessType {
  /// 根
  root('root'),

  /// 账目
  item('item'),

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
  attachment('attachment');

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
