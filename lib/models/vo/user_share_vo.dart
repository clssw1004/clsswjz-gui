import '../../database/database.dart';

/// 用户模块共享 VO
class UserShareVO {
  final String id;
  final String ownerUserId;
  final String targetUserId;
  final String businessType;
  final int createdAt;

  const UserShareVO({
    required this.id,
    required this.ownerUserId,
    required this.targetUserId,
    required this.businessType,
    required this.createdAt,
  });

  factory UserShareVO.fromUserShare(UserShare share) {
    return UserShareVO(
      id: share.id,
      ownerUserId: share.ownerUserId,
      targetUserId: share.targetUserId,
      businessType: share.businessType,
      createdAt: share.createdAt,
    );
  }
}
