import 'package:flutter/material.dart';

/// 礼物卡状态枚举
enum GiftCardStatus {
  /// 草稿
  draft('draft'),

  /// 已送出
  sent('sent'),

  /// 已接收
  received('received'),

  /// 已使用
  used('used'),

  /// 已过期
  expired('expired'),

  /// 已作废
  voided('voided');

  final String code;

  const GiftCardStatus(this.code);

  static GiftCardStatus fromCode(String code) {
    return GiftCardStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => GiftCardStatus.draft,
    );
  }

  String get text {
    switch (this) {
      case GiftCardStatus.draft:
        return '草稿';
      case GiftCardStatus.sent:
        return '已送出';
      case GiftCardStatus.received:
        return '已接收';
      case GiftCardStatus.used:
        return '已使用';
      case GiftCardStatus.expired:
        return '已过期';
      case GiftCardStatus.voided:
        return '已作废';
    }
  }

  Color get color {
    switch (this) {
      case GiftCardStatus.draft:
        return Colors.grey;
      case GiftCardStatus.sent:
        return Colors.blue;
      case GiftCardStatus.received:
        return Colors.orange;
      case GiftCardStatus.used:
        return Colors.green;
      case GiftCardStatus.expired:
        return Colors.red;
      case GiftCardStatus.voided:
        return Colors.brown;
    }
  }
}