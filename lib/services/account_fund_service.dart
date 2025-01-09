import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/common.dart';
import '../models/vo/user_fund_vo.dart';
import 'base_service.dart';
import '../utils/date_util.dart';

/// 资金账户服务
class AccountFundService extends BaseService {
  /// 获取账本下的所有资金账户
  Future<OperateResult<List<AccountFund>>> getFundsByAccountBook(String accountBookId) async {
    final funds = await (db.select(db.accountFundTable)..where((t) => t.accountBookId.equals(accountBookId))).get();

    return OperateResult.success(funds);
  }

  /// 更新资金账户余额
  Future<OperateResult<void>> updateFundBalance(String id, double balanceChange) async {
    try {
      await db.transaction(() async {
        final fund = await (db.select(db.accountFundTable)..where((t) => t.id.equals(id))).getSingle();
        await db.update(db.accountFundTable).replace(
              fund.copyWith(
                fundBalance: fund.fundBalance + balanceChange,
                updatedAt: DateUtil.now(),
              ),
            );
      });
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '更新资金账户余额失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 获取用户的所有资金账户
  Future<List<UserFundVO>> getFundsByBook(String bookId) async {
    final funds = await (db.select(db.accountFundTable)
          ..where((t) => t.accountBookId.equals(bookId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();

    return await toUserFundVO(funds);
  }

  /// 获取资金账户
  Future<UserFundVO> getFund(String fundId) async {
    final funds = await (db.select(db.accountFundTable)..where((t) => t.id.equals(fundId))).getSingle();
    final result = await toUserFundVO([funds]);
    return result.first;
  }

  /// 将资金账户转换为视图对象
  Future<List<UserFundVO>> toUserFundVO(List<AccountFund> funds) async {
    return funds.isEmpty ? [] : funds.map((e) => UserFundVO.fromFundAndBooks(e)).toList();
  }

  /// 获取默认资金账户
  Future<AccountFund?> getDefaultFund(String userId) async {
    final fund = await (db.select(db.accountFundTable)
          ..where((t) => t.createdBy.equals(userId) & t.isDefault.equals(true)))
        .getSingleOrNull();
    if (fund == null) {}
    return fund;
  }
}
