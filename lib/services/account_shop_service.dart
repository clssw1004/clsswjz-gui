import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/common.dart';
import 'base_service.dart';

/// 商家服务
class AccountShopService extends BaseService {
  /// 批量插入商家
  Future<OperateResult<void>> batchInsertShops(List<AccountShop> shops) async {
    try {
      await db.transaction(() async {
        await db.batch((batch) {
          for (var shop in shops) {
            batch.insert(
              db.accountShopTable,
              AccountShopTableCompanion.insert(
                id: shop.id,
                name: shop.name,
                code: shop.code,
                accountBookId: shop.accountBookId,
                createdBy: shop.createdBy,
                updatedBy: shop.updatedBy,
                createdAt: shop.createdAt,
                updatedAt: shop.updatedAt,
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      });
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail(
        '批量插入商家失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 获取账本下的所有商家
  Future<OperateResult<List<AccountShop>>> getShopsByAccountBook(
      String accountBookId) async {
    try {
      final shops = await (db.select(db.accountShopTable)
            ..where((t) => t.accountBookId.equals(accountBookId)))
          .get();
      return OperateResult.success(shops);
    } catch (e) {
      return OperateResult.fail(
        '获取账本商家失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 创建商家
  Future<OperateResult<String>> createShop({
    required String name,
    required String code,
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
  }) async {
    try {
      final id = generateUuid();
      await db.into(db.accountShopTable).insert(
            AccountShopTableCompanion.insert(
              id: id,
              name: name,
              code: code,
              accountBookId: accountBookId,
              createdBy: createdBy,
              updatedBy: updatedBy,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.fail(
        '创建商家失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 更新商家
  Future<OperateResult<void>> updateShop(AccountShop shop) async {
    try {
      await db.update(db.accountShopTable).replace(shop);
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail(
        '更新商家失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 删除商家
  Future<OperateResult<void>> deleteShop(String id) async {
    try {
      await (db.delete(db.accountShopTable)..where((t) => t.id.equals(id)))
          .go();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail(
        '删除商家失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
