import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/common.dart';
import '../models/vo/user_fund_vo.dart';
import '../utils/collection_util.dart';
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
      final funds = await (db.select(db.accountFundTable)
            ..where((t) => t.createdBy.equals(userId)))
          .get();

      return toUserFundVO(funds);
    } catch (e) {
      return OperateResult.failWithMessage(
        '获取用户资金账户失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 获取资金账户关联的账本
  Future<OperateResult<List<RelatedAccountBook>>> getDefaultRelatedBooks() async {
    final books = await db.select(db.accountBookTable).get();
    // 生成默认的RelatedAccountBook 对象
    return OperateResult.success(books.map((e) => RelatedAccountBook(
          accountBookId: e.id,
          name: e.name,
          description: e.description,
          icon: e.icon,
          fundIn: false,
          fundOut: false,
          isDefault: false,
        )).toList());
  }

  /// 将资金账户转换为视图对象
  Future<OperateResult<List<UserFundVO>>> toUserFundVO(
      List<AccountFund> funds) async {
    final List<UserFundVO> result = [];
    final fundMap = CollectionUtils.toMap(funds, (e) => e.id);
    // 查询出所有账本
    final books = await db.select(db.accountBookTable).get();
    // 查询出所有fundIds关联的记录
    final rels = await (db.select(db.relAccountbookFundTable)
          ..where((t) => t.fundId.isIn(funds.map((e) => e.id))))
        .get();

    // 查询出所有关联记录中包含该资金账户的记录
    final relGroupMap = CollectionUtils.groupBy(rels, (e) => e.fundId);
    relGroupMap.forEach((key, value) {
      if (fundMap.containsKey(key)) {
        final fund = fundMap[key];
        final relMap = CollectionUtils.toMap(value, (e) => e.accountBookId);
        final relatedBooks = books.map((e) {
          final rel = relMap[e.id];
          return RelatedAccountBook(
            accountBookId: e.id,
            name: e.name,
            fundIn: rel?.fundIn ?? false,
            fundOut: rel?.fundOut ?? false,
            isDefault: rel?.isDefault ?? false,
          );
        }).toList();

        result.add(UserFundVO.fromFundAndBooks(
          fund: fund!,
          books: relatedBooks,
        ));
      }
    });

    return OperateResult.success(result);
  }
}
