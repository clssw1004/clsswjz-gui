import '../../database/database.dart';

class ItemRelationVO {
  final String id;
  final String itemId;
  final String accountBookId;
  final String relationCode;
  final String relationId;
  final int createdAt;
  final String createdBy;

  const ItemRelationVO({
    required this.id,
    required this.itemId,
    required this.accountBookId,
    required this.relationCode,
    required this.relationId,
    required this.createdAt,
    required this.createdBy,
  });

  factory ItemRelationVO.fromItemRelation(ItemRelation rel) {
    return ItemRelationVO(
      id: rel.id,
      itemId: rel.itemId,
      accountBookId: rel.accountBookId,
      relationCode: rel.relationCode,
      relationId: rel.relationId,
      createdAt: rel.createdAt,
      createdBy: rel.createdBy,
    );
  }
}
