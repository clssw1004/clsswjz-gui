import 'dart:ui';
import 'package:flutter/material.dart';

/// 主题间距配置
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

  const ThemeSpacing({
    required this.formItemSpacing,
    required this.formGroupSpacing,
    required this.formPadding,
    required this.formItemPadding,
    required this.formGroupPadding,
    required this.contentPadding,
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
  }) {
    return ThemeSpacing(
      formItemSpacing: formItemSpacing ?? this.formItemSpacing,
      formGroupSpacing: formGroupSpacing ?? this.formGroupSpacing,
      formPadding: formPadding ?? this.formPadding,
      formItemPadding: formItemPadding ?? this.formItemPadding,
      formGroupPadding: formGroupPadding ?? this.formGroupPadding,
      contentPadding: contentPadding ?? this.contentPadding,
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
      formGroupSpacing:
          lerpDouble(formGroupSpacing, other.formGroupSpacing, t)!,
      formPadding: EdgeInsets.lerp(formPadding, other.formPadding, t)!,
      formItemPadding:
          EdgeInsets.lerp(formItemPadding, other.formItemPadding, t)!,
      formGroupPadding:
          EdgeInsets.lerp(formGroupPadding, other.formGroupPadding, t)!,
      contentPadding: EdgeInsets.lerp(contentPadding, other.contentPadding, t)!,
    );
  }
}

/// 获取主题间距配置
extension ThemeSpacingExtension on ThemeData {
  ThemeSpacing get spacing => extension<ThemeSpacing>()!;
}
