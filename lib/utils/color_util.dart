import 'package:flutter/material.dart';
import '../enums/account_type.dart';
import '../enums/debt_type.dart';
import '../models/vo/user_item_vo.dart' show UserItemVO;

/// 颜色工具类
class ColorUtil {
  /// 支出 红色
  static const Color expense = Color.fromARGB(255, 185, 91, 75);

  /// 收入 绿色
  static const Color income = Color(0xFF43A047);

  /// 转账 柔和的蓝色 - Material Design 3 Blue 70
  static const Color transfer = Color(0xFF1B72C1);

  /// 获取账目金额颜色
  static Color getAmountColor(String? type) {
    final currentType =
        AccountItemType.fromCode(type) ?? AccountItemType.expense;
    switch (currentType) {
      case AccountItemType.expense:
        return expense;
      case AccountItemType.income:
        return income;
      case AccountItemType.transfer:
        return transfer;
    }
  }

  /// 获取债务标签颜色（借出同支出，借入同收入）
  static Color getDebtAmountColor(DebtType type) {
    switch (type) {
      case DebtType.lend:
        return expense;
      case DebtType.borrow:
        return income;
    }
  }

  /// 获取债务反转颜色（收款同收入，还款同支出）
  static Color getDebtAmountReverseColor(DebtType type) {
    switch (type) {
      case DebtType.lend:
        return income;
      case DebtType.borrow:
        return expense;
    }
  }

  /// 获取转账分类颜色
  static Color getTransferCategoryColor(UserItemVO item) {
    final category = item.categoryCode;
    if (category == DebtType.borrow.code ||
        category == DebtType.lend.operationCategory) {
      return income;
    }
    if (category == DebtType.lend.code ||
        category == DebtType.borrow.operationCategory) {
      return expense;
    }
    return transfer;
  }
}