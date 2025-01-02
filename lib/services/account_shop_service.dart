import 'package:drift/drift.dart';
import '../database/dao/account_shop_dao.dart';
import '../database/database.dart';
import '../manager/database_manager.dart';
import '../models/common.dart';
import 'base_service.dart';
import '../utils/date_util.dart';

/// 商家服务
class AccountShopService extends BaseService {
  final AccountShopDao _accountShopDao;

  AccountShopService() : _accountShopDao = AccountShopDao(DatabaseManager.db);

  /// 获取账本下的所有商家
  Future<OperateResult<List<AccountShop>>> getShopsByAccountBook(
      String accountBookId) async {
    try {
      final shops = await (db.select(db.accountShopTable)
            ..where((t) => t.accountBookId.equals(accountBookId)))
          .get();
      return OperateResult.success(shops);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '获取账本商家失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 创建商家
  Future<OperateResult<String>> createShop({
    required String name,
    required String code,
    required String accountBookId,
    required String createdBy,
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
              updatedBy: createdBy,
              createdAt: DateUtil.now(),
              updatedAt: DateUtil.now(),
            ),
          );
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '创建商家失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 更新商家
  Future<OperateResult<void>> updateShop(AccountShop shop) async {
    try {
      await _accountShopDao.update(
          shop.id,
          AccountShopTableCompanion(
            name: Value(shop.name),
          ));
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '更新商家失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 删除商家
  Future<OperateResult<void>> deleteShop(String id) async {
    try {
      await _accountShopDao.delete(id);
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '删除商家失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
