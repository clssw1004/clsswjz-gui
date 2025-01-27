import 'package:json_annotation/json_annotation.dart';


/// 账目筛选参数
@JsonSerializable()
class ItemFilterDTO {
  /// 账目类型列表（支出、收入、转账）
  final List<String>? types;

  /// 分类ID列表
  final List<String>? categoryCodes;

  /// 商户ID列表
  final List<String>? shopCodes;

  /// 账户ID列表
  final List<String>? fundIds;

  /// 标签ID列表
  final List<String>? tagCodes;

  /// 项目ID列表
  final List<String>? projectCodes;

  /// 金额下限
  final double? minAmount;

  /// 金额上限
  final double? maxAmount;

  /// 开始日期
  final String? startDate;

  /// 结束日期
  final String? endDate;

  const ItemFilterDTO({
    this.types,
    this.categoryCodes,
    this.shopCodes,
    this.fundIds,
    this.tagCodes,
    this.projectCodes,
    this.minAmount,
    this.maxAmount,
    this.startDate,
    this.endDate,
  });


  /// 复制并修改
  ItemFilterDTO copyWith({
    List<String>? types,
    List<String>? categoryCodes,
    List<String>? shopCodes,
    List<String>? fundIds,
    List<String>? tagCodes,
    List<String>? projectCodes,
    double? minAmount,
    double? maxAmount,
    String? startDate,
    String? endDate,
  }) {
    return ItemFilterDTO(
      types: types ?? this.types,
      categoryCodes: categoryCodes ?? this.categoryCodes,
      shopCodes: shopCodes ?? this.shopCodes,
      fundIds: fundIds ?? this.fundIds,
      tagCodes: tagCodes ?? this.tagCodes,
      projectCodes: projectCodes ?? this.projectCodes,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// 是否为空
  bool get isEmpty =>
      (types?.isEmpty ?? true) &&
      (categoryCodes?.isEmpty ?? true) &&
      (shopCodes?.isEmpty ?? true) &&
      (fundIds?.isEmpty ?? true) &&
      (tagCodes?.isEmpty ?? true) &&
      (projectCodes?.isEmpty ?? true) &&
      minAmount == null &&
      maxAmount == null &&
      startDate == null &&
      endDate == null;

  /// 是否不为空
  bool get isNotEmpty => !isEmpty;
} 