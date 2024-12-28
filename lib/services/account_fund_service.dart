import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/common.dart';
import '../models/vo/user_fund_vo.dart';
import 'base_service.dart';

/// 资金账户服务
class AccountFundService extends BaseService {
  /// 批量插入资金账户
  Future<OperateResult<void>> batchInsertFunds(List<AccountFund> funds) async {
    try {
      await db.transaction(() async {
        await db.batch((batch) {
          for (var fund in funds) {
            batch.insert(
              db.accountFundTable,
              AccountFundTableCompanion.insert(
                id: fund.id,
                name: fund.name,
                fundType: fund.fundType,
                fundRemark: Value(fund.fundRemark),
                fundBalance: Value(fund.fundBalance),
                createdBy: fund.createdBy,
                updatedBy: fund.updatedBy,
                createdAt: fund.createdAt,
                updatedAt: fund.updatedAt,
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      });
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        '批量插入资金账户失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 获取账本下的所有资金账户
  Future<OperateResult<List<AccountFund>>> getFundsByAccountBook(
      String accountBookId) async {
    try {
      final query = db.select(db.accountFundTable).join([
        innerJoin(
          db.relAccountbookFundTable,
          db.relAccountbookFundTable.fundId.equalsExp(db.accountFundTable.id),
        ),
      ])
        ..where(db.relAccountbookFundTable.accountBookId.equals(accountBookId));

      final results = await query.get();
      final funds =
          results.map((row) => row.readTable(db.accountFundTable)).toList();
      return OperateResult.success(funds);
    } catch (e) {
      return OperateResult.failWithMessage(
        '获取账本资金账户失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 创建资金账户
  Future<OperateResult<String>> createFund({
    required String name,
    required String fundType,
    String? fundRemark,
    double fundBalance = 0.0,
    required String createdBy,
    required String updatedBy,
  }) async {
    try {
      final id = generateUuid();
      await db.into(db.accountFundTable).insert(
            AccountFundTableCompanion.insert(
              id: id,
              name: name,
              fundType: fundType,
              fundRemark: Value(fundRemark),
              fundBalance: Value(fundBalance),
              createdBy: createdBy,
              updatedBy: updatedBy,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage(
        '创建资金账户失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 更新资金账户
  Future<OperateResult<void>> updateFund(AccountFund fund) async {
    try {
      await db.update(db.accountFundTable).replace(fund);
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        '更新资金账户失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 删除资金账户
  Future<OperateResult<void>> deleteFund(String id) async {
    try {
      await db.transaction(() async {
        // 删除资金账户与账本的关联
        await (db.delete(db.relAccountbookFundTable)
              ..where((t) => t.fundId.equals(id)))
            .go();
        // 删除资金账户
        await (db.delete(db.accountFundTable)..where((t) => t.id.equals(id)))
            .go();
      });
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        '删除资金账户失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 更新资金账户余额
  Future<OperateResult<void>> updateFundBalance(
      String id, double balanceChange) async {
    try {
      await db.transaction(() async {
        final fund = await (db.select(db.accountFundTable)
              ..where((t) => t.id.equals(id)))
            .getSingle();
        await db.update(db.accountFundTable).replace(
              fund.copyWith(
                fundBalance: fund.fundBalance + balanceChange,
                updatedAt: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      });
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        '更新资金账户余额失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 获取用户的所有资金账户
  Future<OperateResult<List<UserFundVO>>> getFundsByUser(String userId) async {
    try {
      // 1. 查询用户创建的所有资金账户
      final fundsQuery = db.select(db.accountFundTable)
        ..where((t) => t.createdBy.equals(userId));
      final funds = await fundsQuery.get();

      if (funds.isEmpty) {
        return OperateResult.success([]);
      }

      // 2. 查询资金账户关联的账本信息
      final relQuery = db.select(db.relAccountbookFundTable).join([
        innerJoin(
          db.accountBookTable,
          db.relAccountbookFundTable.accountBookId.equalsExp(db.accountBookTable.id),
        ),
      ])..where(db.relAccountbookFundTable.fundId.isIn(funds.map((f) => f.id)));

      final relResults = await relQuery.get();

      // 3. 组装视图对象
      final result = funds.map((fund) {
        final relatedBooks = relResults
            .where((row) => row.readTable(db.relAccountbookFundTable).fundId == fund.id)
            .map((row) {
          final rel = row.readTable(db.relAccountbookFundTable);
          final book = row.readTable(db.accountBookTable);
          return RelatedAccountBook(
            id: book.id,
            name: book.name,
            description: book.description,
            icon: book.icon,
            fundIn: rel.fundIn,
            fundOut: rel.fundOut,
            isDefault: rel.isDefault,
          );
        }).toList();

        return UserFundVO(
          fund: fund,
          relatedBooks: relatedBooks,
        );
      }).toList();

      return OperateResult.success(result);
    } catch (e) {
      return OperateResult.failWithMessage(
        '获取用户资金账户失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
