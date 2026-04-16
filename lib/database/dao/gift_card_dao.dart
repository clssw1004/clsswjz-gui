import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/gift_card_table.dart';
import 'base_dao.dart';

class GiftCardDao extends BaseDao<GiftCardTable, GiftCard> {
  GiftCardDao(super.db);

  @override
  TableInfo<GiftCardTable, GiftCard> get table => db.giftCardTable;

  /// 根据状态查询
  Future<List<GiftCard>> findByStatus(String status) {
    return (db.select(table)..where((t) => t.status.equals(status))).get();
  }

  /// 查询所有并按过期时间排序
  Future<List<GiftCard>> findAllOrderByExpiredTime() {
    return (db.select(table)..orderBy([(t) => OrderingTerm.asc(t.expiredTime)])).get();
  }

  /// 查询我收到的礼物卡（接收人是我）
  Future<List<GiftCard>> findReceived(String userId) {
    return (db.select(table)
          ..where((t) => t.toUserId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// 查询我送出的礼物卡（赠送人是我）
  Future<List<GiftCard>> findSent(String userId) {
    return (db.select(table)
          ..where((t) => t.fromUserId.equals(userId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// 查询过期的礼物卡
  Future<List<GiftCard>> findExpired(int now) {
    return (db.select(table)
          ..where((t) =>
              (t.status.equals('sent') | t.status.equals('received')) &
              t.expiredTime.isSmallerThanValue(now) &
              t.expiredTime.isBiggerThanValue(0)))
        .get();
  }

  /// 更新状态
  Future<bool> updateStatus(String id, String status) {
    return update(
      id,
      GiftCardTableCompanion(status: Value(status)),
    );
  }

  /// 更新状态和时间
  Future<bool> updateStatusAndTime(String id, String status, int time) {
    return update(
      id,
      GiftCardTableCompanion(
        status: Value(status),
        sentTime: status == 'sent' ? Value(time) : const Value.absent(),
        receivedTime: status == 'received' ? Value(time) : const Value.absent(),
      ),
    );
  }

  /// 延期
  Future<bool> extendExpiredTime(String id, int expiredTime) {
    return update(
      id,
      GiftCardTableCompanion(expiredTime: Value(expiredTime)),
    );
  }
}