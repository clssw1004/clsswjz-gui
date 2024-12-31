import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/common.dart';
import 'base_service.dart';
import '../utils/date_util.dart';

/// 标签服务
class AccountSymbolService extends BaseService {
  /// 批量插入标签
  Future<OperateResult<void>> batchInsertSymbols(
      List<AccountSymbol> symbols) async {
    try {
      await db.transaction(() async {
        await db.batch((batch) {
          for (var symbol in symbols) {
            batch.insert(
              db.accountSymbolTable,
              AccountSymbolTableCompanion.insert(
                id: symbol.id,
                name: symbol.name,
                code: symbol.code,
                accountBookId: symbol.accountBookId,
                symbolType: symbol.symbolType,
                createdBy: symbol.createdBy,
                updatedBy: symbol.updatedBy,
                createdAt: symbol.createdAt,
                updatedAt: symbol.updatedAt,
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      });
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '批量插入标签失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

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
      await db.into(db.accountSymbolTable).insert(
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
      await db.update(db.accountSymbolTable).replace(symbol);
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
