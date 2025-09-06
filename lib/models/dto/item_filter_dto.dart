import 'dart:convert';

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

  final String? source;

  final List<String>? sourceIds;

  /// 关键字
  /// 用于搜索账目description
  final String? keyword;

  const ItemFilterDTO(
      {this.types,
      this.categoryCodes,
      this.shopCodes,
      this.fundIds,
      this.tagCodes,
      this.projectCodes,
      this.minAmount,
      this.maxAmount,
      this.startDate,
      this.endDate,
      this.source,
      this.sourceIds,
      this.keyword});

  /// 复制并修改
  ItemFilterDTO copyWith(
      {List<String>? types,
      List<String>? categoryCodes,
      List<String>? shopCodes,
      List<String>? fundIds,
      List<String>? tagCodes,
      List<String>? projectCodes,
      double? minAmount,
      double? maxAmount,
      String? startDate,
      String? endDate,
      String? source,
      String? sourceId,
      String? keyword}) {
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
      source: source ?? this.source,
      sourceIds: sourceIds ?? sourceIds,
      keyword: keyword ?? this.keyword,
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
      endDate == null &&
      source == null &&
      (sourceIds?.isEmpty ?? true) &&
      (keyword == null || keyword!.isEmpty);

  /// 是否不为空
  bool get isNotEmpty => !isEmpty;

  static ItemFilterDTO fromJson(String json) {
    final map = jsonDecode(json);
    final filter = ItemFilterDTO(
      types: (map['types'] as List?)?.map((e) => e.toString()).toList(),
      categoryCodes:
          (map['categoryCodes'] as List?)?.map((e) => e.toString()).toList(),
      shopCodes: (map['shopCodes'] as List?)?.map((e) => e.toString()).toList(),
      fundIds: (map['fundIds'] as List?)?.map((e) => e.toString()).toList(),
      tagCodes: (map['tagCodes'] as List?)?.map((e) => e.toString()).toList(),
      projectCodes:
          (map['projectCodes'] as List?)?.map((e) => e.toString()).toList(),
      minAmount: map['minAmount']?.toDouble(),
      maxAmount: map['maxAmount']?.toDouble(),
      startDate: map['startDate']?.toString(),
      endDate: map['endDate']?.toString(),
      source: map['source']?.toString(),
      sourceIds: (map['sourceIds'] as List?)?.map((e) => e.toString()).toList(),
      keyword: map['keywords']?.toString(),
    );
    return filter;
  }

  /// 转换为JSON字符串
  static String toJsonString(ItemFilterDTO filter) {
    Map<String, dynamic> map = {};
    if (filter.types?.isNotEmpty == true) {
      map['types'] = filter.types;
    }
    if (filter.categoryCodes?.isNotEmpty == true) {
      map['categoryCodes'] = filter.categoryCodes;
    }
    if (filter.shopCodes?.isNotEmpty == true) {
      map['shopCodes'] = filter.shopCodes;
    }
    if (filter.fundIds?.isNotEmpty == true) {
      map['fundIds'] = filter.fundIds;
    }
    if (filter.tagCodes?.isNotEmpty == true) {
      map['tagCodes'] = filter.tagCodes;
    }
    if (filter.projectCodes?.isNotEmpty == true) {
      map['projectCodes'] = filter.projectCodes;
    }
    if (filter.minAmount != null) {
      map['minAmount'] = filter.minAmount;
    }
    if (filter.maxAmount != null) {
      map['maxAmount'] = filter.maxAmount;
    }
    if (filter.startDate != null) {
      map['startDate'] = filter.startDate;
    }
    if (filter.endDate != null) {
      map['endDate'] = filter.endDate;
    }
    if (filter.source != null) {
      map['source'] = filter.source;
    }
    if (filter.sourceIds?.isNotEmpty == true) {
      map['sourceIds'] = filter.sourceIds;
    }
    if (filter.keyword?.isNotEmpty == true) {
      map['keywords'] = filter.keyword;
    }
    return jsonEncode(map);
  }
}
