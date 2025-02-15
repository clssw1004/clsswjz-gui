import 'package:flutter/material.dart';
import '../enums/account_type.dart';
import '../enums/debt_type.dart';

/// 颜色工具类
class ColorUtil {
  /// 支出 红色
  static const Color EXPENSE = Color.fromARGB(255, 185, 91, 75);

  /// 收入 绿色
  static const Color INCOME = Color(0xFF43A047);

  /// 转账 柔和的蓝色
  static const Color TRANSFER = Color(0xFF64B5F6);

  /// 获取账目金额颜色
  static Color getAmountColor(String? type) {
    final currentType =
        AccountItemType.fromCode(type) ?? AccountItemType.expense;
    switch (currentType) {
      case AccountItemType.expense:
        return EXPENSE;
      case AccountItemType.income:
        return INCOME;
      case AccountItemType.transfer:
        return TRANSFER;
    }
  }

  /// 获取债务金额颜色
  static Color getDebtAmountColor(DebtType type) {
    switch (type) {
      case DebtType.lend:
        return EXPENSE;
      case DebtType.borrow:
        return INCOME;
    }
  }
}
