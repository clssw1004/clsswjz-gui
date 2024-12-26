import 'package:flutter/material.dart';
import '../constants/enums.dart';

/// 颜色工具类
class ColorUtil {
  /// 获取账目金额颜色
  static Color getAmountColor(BuildContext context, String? type) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentType =
        AccountItemType.fromCode(type) ?? AccountItemType.expense;

    return currentType == AccountItemType.expense
        ? colorScheme.error
        : const Color(0xFF43A047);
  }
}
