import 'package:flutter/material.dart';
import '../enums/account_type.dart';

/// 颜色工具类
class ColorUtil {
  static const Color EXPENSE = Color.fromARGB(255, 185, 91, 75);
  static const Color INCOME = Color(0xFF43A047);

  /// 获取账目金额颜色
  static Color getAmountColor(String? type) {
    final currentType = AccountItemType.fromCode(type) ?? AccountItemType.expense;

    return currentType == AccountItemType.expense ? EXPENSE : INCOME;
  }
}
