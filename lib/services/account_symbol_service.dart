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

  /// 创建标签
  Future<OperateResult<String>> createSymbol({
    required String name,
    required String code,
    required String accountBookId,
    required String symbolType,
    required String createdBy,
    required String updatedBy,
  }) async {
    try {
      final id = generateUuid();
      await _accountSymbolDao.insert(
        AccountSymbolTableCompanion.insert(
          id: id,
          name: name,
          code: code,
          accountBookId: accountBookId,
          symbolType: symbolType,
          createdBy: createdBy,
          updatedBy: updatedBy,
          createdAt: DateUtil.now(),
          updatedAt: DateUtil.now(),
        ),
      );
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '创建标签失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 更新标签
  Future<OperateResult<void>> updateSymbol(AccountSymbol symbol) async {
    try {
      await _accountSymbolDao.update(
          symbol.id,
          AccountSymbolTableCompanion(
            name: Value(symbol.name),
            updatedBy: Value(symbol.updatedBy),
            updatedAt: Value(DateUtil.now()),
          ));
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '更新标签失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 删除标签
  Future<OperateResult<void>> deleteSymbol(String id) async {
    try {
      await (db.delete(db.accountSymbolTable)..where((t) => t.id.equals(id)))
          .go();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '删除标签失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
