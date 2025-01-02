/// 操作类型
enum OperateType {
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
  const OperateType(this.code);

  static OperateType? fromCode(String? code) {
    if (code == null) return null;
    return OperateType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => throw Exception('Invalid operate type code: $code'),
    );
  }

  /// 是否为批量操作
  bool get isBatch => code.startsWith('batch');

  /// 获取基础操作类型
  OperateType get baseType {
    if (!isBatch) return this;
    switch (this) {
      case OperateType.batchUpdate:
        return OperateType.update;
      case OperateType.batchCreate:
        return OperateType.create;
      case OperateType.batchDelete:
        return OperateType.delete;
      default:
        return this;
    }
  }
}
