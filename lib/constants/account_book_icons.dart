import 'package:flutter/material.dart';

/// 账本可选图标列表
const accountBookIcons = [
  // 钱包和储蓄相关
  Icons.account_balance_wallet,
  Icons.savings,
  Icons.credit_card,
  Icons.wallet,
  Icons.attach_money,
  Icons.money,
  Icons.monetization_on,
  Icons.currency_exchange,

  // 银行和金融相关
  Icons.account_balance,
  Icons.payments,
  Icons.payment,
  Icons.price_check,
  Icons.price_change,
  Icons.currency_yuan,
  Icons.currency_bitcoin,

  // 账单和记录相关
  Icons.receipt_long,
  Icons.receipt,
  Icons.description,
  Icons.sticky_note_2,
  Icons.note,
  Icons.list_alt,

  // 分类和统计相关
  Icons.pie_chart,
  Icons.bar_chart,
  Icons.trending_up,
  Icons.analytics,
  Icons.assessment,
  Icons.insert_chart,

  // 时间和计划相关
  Icons.calendar_today,
  Icons.event_note,
  Icons.schedule,
  Icons.timer,
  Icons.date_range,

  // 目标和储蓄相关
  Icons.stars,
  Icons.favorite,
  Icons.flag,
  Icons.emoji_events,
  Icons.military_tech,
  Icons.workspace_premium,

  // 家庭和生活相关
  Icons.home,
  Icons.house,
  Icons.shopping_cart,
  Icons.shopping_bag,
  Icons.store,
  Icons.restaurant,

  // 交通和旅行相关
  Icons.directions_car,
  Icons.flight,
  Icons.train,
  Icons.directions_bus,
  Icons.hotel,
  Icons.luggage,

  // 工作和商务相关
  Icons.work,
  Icons.business_center,
  Icons.cases,
  Icons.apartment,
  Icons.corporate_fare,

  // 教育和学习相关
  Icons.school,
  Icons.book,
  Icons.auto_stories,
  Icons.library_books,

  // 健康和医疗相关
  Icons.medical_services,
  Icons.local_hospital,
  Icons.health_and_safety,
  Icons.fitness_center,

  // 娱乐和休闲相关
  Icons.sports_esports,
  Icons.sports,
  Icons.movie,
  Icons.music_note,
  Icons.gamepad,

  // 其他常用图标
  Icons.star,
  Icons.grade,
  Icons.bookmark,
  Icons.label,
  Icons.folder,
  Icons.category,
];

/// 默认账本图标
///
///
String defaultIcon() {
  return accountBookIcons.first.codePoint.toString();
}
