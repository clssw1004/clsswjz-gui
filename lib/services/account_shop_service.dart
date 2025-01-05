import '../database/dao/account_shop_dao.dart';
import '../database/database.dart';
import '../manager/database_manager.dart';
import '../models/common.dart';
import 'base_service.dart';

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
}
