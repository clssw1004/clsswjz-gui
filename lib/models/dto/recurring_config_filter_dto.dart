/// 固定收支配置筛选参数
class RecurringConfigFilterDTO {
  /// 类型: INCOME / EXPENSE
  final String? type;

  /// 启用状态
  final bool? isActive;

  /// 频率类型: weekly / monthly
  final String? frequencyType;

  /// 关键词（按备注搜索）
  final String? keyword;

  const RecurringConfigFilterDTO({
    this.type,
    this.isActive,
    this.frequencyType,
    this.keyword,
  });

  RecurringConfigFilterDTO copyWith({
    String? type,
    bool? isActive,
    String? frequencyType,
    String? keyword,
  }) {
    return RecurringConfigFilterDTO(
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      frequencyType: frequencyType ?? this.frequencyType,
      keyword: keyword ?? this.keyword,
    );
  }
}
