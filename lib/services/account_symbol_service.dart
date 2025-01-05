import 'package:drift/drift.dart';
import '../database/dao/account_symbol_dao.dart';
import '../database/database.dart';
import '../manager/database_manager.dart';
import '../models/common.dart';
import 'base_service.dart';
import '../utils/date_util.dart';

/// 标签服务
class AccountSymbolService extends BaseService {
  final AccountSymbolDao _accountSymbolDao;

  AccountSymbolService()
      : _accountSymbolDao = AccountSymbolDao(DatabaseManager.db);

  /// 获取账本下的所有标签
  Future<OperateResult<List<AccountSymbol>>> getSymbolsByAccountBook(
      String accountBookId) async {
    try {
      final symbols = await (db.select(db.accountSymbolTable)
            ..where((t) => t.accountBookId.equals(accountBookId)))
          .get();
      return OperateResult.success(symbols);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '获取账本标签失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 获取账本下指定类型的标签
  Future<OperateResult<List<AccountSymbol>>> getSymbolsByType(
      String accountBookId, String symbolType) async {
    try {
      final symbols = await (db.select(db.accountSymbolTable)
            ..where((t) =>
                t.accountBookId.equals(accountBookId) &
                t.symbolType.equals(symbolType)))
          .get();
      return OperateResult.success(symbols);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '获取账本标签失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
