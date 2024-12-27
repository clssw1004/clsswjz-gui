import 'package:flutter/material.dart';
import 'dart:ui';

/// 主题圆角扩展
class ThemeRadius extends ThemeExtension<ThemeRadius> {
  /// 圆角大小
  final double radius;

  const ThemeRadius({
    required this.radius,
  });

  @override
  ThemeExtension<ThemeRadius> copyWith({
    double? radius,
  }) {
    return ThemeRadius(
      radius: radius ?? this.radius,
    );
  }

  @override
  ThemeExtension<ThemeRadius> lerp(
    covariant ThemeExtension<ThemeRadius>? other,
    double t,
  ) {
    if (other is! ThemeRadius) {
      return this;
    }
    return ThemeRadius(
      radius: lerpDouble(radius, other.radius, t) ?? radius,
    );
  }
} 