import 'dart:ui';
import 'package:flutter/material.dart';

/// 主题间距配置
@immutable
class ThemeSpacing extends ThemeExtension<ThemeSpacing> {
  /// 表单项垂直间距
  final double formItemSpacing;

  /// 表单组垂直间距
  final double formGroupSpacing;

  /// 表单内边距
  final EdgeInsets formPadding;

  /// 表单项内边距
  final EdgeInsets formItemPadding;

  /// 表单组内边距
  final EdgeInsets formGroupPadding;

  /// 内容区域内边距
  final EdgeInsets contentPadding;

  /// 列表内边距
  final EdgeInsets listPadding;

  /// 列表项外边距
  final EdgeInsets listItemMargin;

  /// 列表项内边距
  final EdgeInsets listItemPadding;

  /// 列表项内容间距
  final double listItemSpacing;

  /// 加载更多区域内边距
  final EdgeInsets loadMorePadding;

  /// 页面内边距
  final EdgeInsets pagePadding;

  /// 底部弹出组件内边距
  final EdgeInsets bottomSheetPadding;

  const ThemeSpacing({
    this.formItemSpacing = 16.0,
    this.formGroupSpacing = 24.0,
    this.formPadding = const EdgeInsets.all(16.0),
    this.formItemPadding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
    this.formGroupPadding = const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    this.listPadding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
    this.listItemMargin = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
    this.listItemPadding = const EdgeInsets.all(12.0),
    this.listItemSpacing = 8.0,
    this.loadMorePadding = const EdgeInsets.symmetric(vertical: 8.0),
    this.bottomSheetPadding = const EdgeInsets.all(16.0),
    this.pagePadding = const EdgeInsets.all(16.0),
  });

  /// 根据屏幕尺寸创建间距配置
  factory ThemeSpacing.fromScreenSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final shortestSide = screenSize.shortestSide;

    // 基础间距，根据屏幕尺寸计算
    final baseSpacing = (shortestSide * 0.02).clamp(8.0, 16.0);
    final groupSpacing = (shortestSide * 0.04).clamp(16.0, 32.0);

    // 水平内边距，根据屏幕宽度计算
    final horizontalPadding = (screenSize.width * 0.04).clamp(16.0, 32.0);

    // 垂直内边距，根据屏幕高度计算
    final verticalPadding = (screenSize.height * 0.02).clamp(16.0, 24.0);

    // 列表相关间距
    final listHorizontalPadding = (screenSize.width * 0.03).clamp(12.0, 24.0);
    final listVerticalPadding = (screenSize.height * 0.005).clamp(4.0, 8.0);
    final listItemPadding = (shortestSide * 0.03).clamp(12.0, 16.0);
    final listItemSpacing = (shortestSide * 0.02).clamp(8.0, 12.0);

    return ThemeSpacing(
      formItemSpacing: baseSpacing,
      formGroupSpacing: groupSpacing,
      formPadding: EdgeInsets.all(horizontalPadding),
      formItemPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding * 0.75,
        vertical: baseSpacing,
      ),
      formGroupPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding * 0.5,
        vertical: baseSpacing,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      listPadding: EdgeInsets.symmetric(
        horizontal: listHorizontalPadding,
        vertical: listVerticalPadding,
      ),
      listItemMargin: EdgeInsets.symmetric(
        horizontal: listHorizontalPadding,
        vertical: listVerticalPadding,
      ),
      listItemPadding: EdgeInsets.all(listItemPadding),
      listItemSpacing: listItemSpacing,
      loadMorePadding: EdgeInsets.symmetric(vertical: listItemSpacing),
      bottomSheetPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      pagePadding: EdgeInsets.all(horizontalPadding),
    );
  }

  @override
  ThemeSpacing copyWith({
    double? formItemSpacing,
    double? formGroupSpacing,
    EdgeInsets? formPadding,
    EdgeInsets? formItemPadding,
    EdgeInsets? formGroupPadding,
    EdgeInsets? contentPadding,
    EdgeInsets? listPadding,
    EdgeInsets? listItemMargin,
    EdgeInsets? listItemPadding,
    double? listItemSpacing,
    EdgeInsets? loadMorePadding,
    EdgeInsets? bottomSheetPadding,
    EdgeInsets? pagePadding,
  }) {
    return ThemeSpacing(
      formItemSpacing: formItemSpacing ?? this.formItemSpacing,
      formGroupSpacing: formGroupSpacing ?? this.formGroupSpacing,
      formPadding: formPadding ?? this.formPadding,
      formItemPadding: formItemPadding ?? this.formItemPadding,
      formGroupPadding: formGroupPadding ?? this.formGroupPadding,
      contentPadding: contentPadding ?? this.contentPadding,
      listPadding: listPadding ?? this.listPadding,
      listItemMargin: listItemMargin ?? this.listItemMargin,
      listItemPadding: listItemPadding ?? this.listItemPadding,
      listItemSpacing: listItemSpacing ?? this.listItemSpacing,
      loadMorePadding: loadMorePadding ?? this.loadMorePadding,
      bottomSheetPadding: bottomSheetPadding ?? this.bottomSheetPadding,
      pagePadding: pagePadding ?? this.pagePadding,
    );
  }

  @override
  ThemeExtension<ThemeSpacing> lerp(
    covariant ThemeExtension<ThemeSpacing>? other,
    double t,
  ) {
    if (other is! ThemeSpacing) {
      return this;
    }

    return ThemeSpacing(
      formItemSpacing: lerpDouble(formItemSpacing, other.formItemSpacing, t)!,
      formGroupSpacing: lerpDouble(formGroupSpacing, other.formGroupSpacing, t)!,
      formPadding: EdgeInsets.lerp(formPadding, other.formPadding, t)!,
      formItemPadding: EdgeInsets.lerp(formItemPadding, other.formItemPadding, t)!,
      formGroupPadding: EdgeInsets.lerp(formGroupPadding, other.formGroupPadding, t)!,
      contentPadding: EdgeInsets.lerp(contentPadding, other.contentPadding, t)!,
      listPadding: EdgeInsets.lerp(listPadding, other.listPadding, t)!,
      listItemMargin: EdgeInsets.lerp(listItemMargin, other.listItemMargin, t)!,
      listItemPadding: EdgeInsets.lerp(listItemPadding, other.listItemPadding, t)!,
      listItemSpacing: lerpDouble(listItemSpacing, other.listItemSpacing, t)!,
      loadMorePadding: EdgeInsets.lerp(loadMorePadding, other.loadMorePadding, t)!,
      bottomSheetPadding: EdgeInsets.lerp(bottomSheetPadding, other.bottomSheetPadding, t)!,
      pagePadding: EdgeInsets.lerp(pagePadding, other.pagePadding, t)!,
    );
  }
}

/// 获取主题间距配置
extension ThemeSpacingExtension on ThemeData {
  ThemeSpacing get spacing => extension<ThemeSpacing>()!;
}

double lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}
