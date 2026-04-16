import '../../database/database.dart';
import '../../enums/gift_card_status.dart';

/// 礼物卡视图对象
class GiftCardVO {
  /// ID
  final String id;

  /// 赠送人用户ID
  final String fromUserId;

  /// 赠送人昵称（查询时翻译）
  final String fromUserNickname;

  /// 接收人用户ID
  final String toUserId;

  /// 接收人昵称（查询时翻译）
  final String toUserNickname;

  /// 礼品描述
  final String? description;

  /// 过期时间 (毫秒时间戳，0表示永久有效)
  final int expiredTime;

  /// 送出时间 (毫秒时间戳)
  final int sentTime;

  /// 接收时间 (毫秒时间戳)
  final int receivedTime;

  /// 状态
  final GiftCardStatus status;

  /// 创建时间
  final int createdAt;

  /// 更新时间
  final int updatedAt;

  /// 创建人ID
  final String createdBy;

  /// 更新人ID
  final String updatedBy;

  const GiftCardVO({
    required this.id,
    required this.fromUserId,
    required this.fromUserNickname,
    required this.toUserId,
    required this.toUserNickname,
    this.description,
    required this.expiredTime,
    required this.sentTime,
    required this.receivedTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.updatedBy,
  });

  /// 赠送人显示名称
  String get fromWho => fromUserNickname;

  /// 接收人显示名称
  String get toWho => toUserNickname;

  /// 是否已过期
  bool get isExpired {
    if (expiredTime <= 0) return false; // 永久有效
    return status == GiftCardStatus.sent &&
        DateTime.now().millisecondsSinceEpoch > expiredTime;
  }

  /// 是否永久有效
  bool get isPermanent => expiredTime <= 0;

  /// 有效状态（考虑过期时间）
  GiftCardStatus get effectiveStatus {
    if (isExpired) {
      return GiftCardStatus.expired;
    }
    return status;
  }

  /// 从数据库实体创建视图对象（不翻译昵称）
  static GiftCardVO fromGiftCard(GiftCard giftCard) {
    return GiftCardVO(
      id: giftCard.id,
      fromUserId: giftCard.fromUserId,
      fromUserNickname: '',
      toUserId: giftCard.toUserId,
      toUserNickname: '',
      description: giftCard.description,
      expiredTime: giftCard.expiredTime,
      sentTime: giftCard.sentTime,
      receivedTime: giftCard.receivedTime,
      status: GiftCardStatus.fromCode(giftCard.status),
      createdAt: giftCard.createdAt,
      updatedAt: giftCard.updatedAt,
      createdBy: giftCard.createdBy,
      updatedBy: giftCard.updatedBy,
    );
  }

  /// 创建带昵称的视图对象（工厂构造方法）
  factory GiftCardVO.withNicknames({
    required String id,
    required String fromUserId,
    required String fromUserNickname,
    required String toUserId,
    required String toUserNickname,
    String? description,
    required int expiredTime,
    required int sentTime,
    required int receivedTime,
    required GiftCardStatus status,
    required int createdAt,
    required int updatedAt,
    required String createdBy,
    required String updatedBy,
  }) {
    return GiftCardVO(
      id: id,
      fromUserId: fromUserId,
      fromUserNickname: fromUserNickname,
      toUserId: toUserId,
      toUserNickname: toUserNickname,
      description: description,
      expiredTime: expiredTime,
      sentTime: sentTime,
      receivedTime: receivedTime,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// 复制并设置翻译后的昵称
  GiftCardVO copyWith({
    String? fromUserNickname,
    String? toUserNickname,
  }) {
    return GiftCardVO(
      id: id,
      fromUserId: fromUserId,
      fromUserNickname: fromUserNickname ?? this.fromUserNickname,
      toUserId: toUserId,
      toUserNickname: toUserNickname ?? this.toUserNickname,
      description: description,
      expiredTime: expiredTime,
      sentTime: sentTime,
      receivedTime: receivedTime,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// 转换为数据库实体
  GiftCard toGiftCard() {
    return GiftCard(
      id: id,
      fromUserId: fromUserId,
      toUserId: toUserId,
      description: description,
      expiredTime: expiredTime,
      sentTime: sentTime,
      receivedTime: receivedTime,
      status: status.code,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }
}