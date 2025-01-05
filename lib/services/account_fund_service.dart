import 'package:clsswjz/utils/id_util.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/common.dart';
import '../models/vo/user_fund_vo.dart';
import '../utils/collection_util.dart';
import 'base_service.dart';
import '../utils/date_util.dart';

/// 资金账户服务
class AccountFundService extends BaseService {
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
        message: '获取账本资金账户失败',
        exception: e is Exception ? e : Exception(e.toString()),
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
  Future<List<UserFundVO>> getFundsByUser(String userId) async {
    final funds = await (db.select(db.accountFundTable)
          ..where((t) => t.createdBy.equals(userId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
        .get();

    return await toUserFundVO(funds);
  }

  /// 获取资金账户
  Future<UserFundVO> getFund(String fundId) async {
    final funds = await (db.select(db.accountFundTable)
          ..where((t) => t.id.equals(fundId)))
        .getSingle();
    final result = await toUserFundVO([funds]);
    return result.first;
  }

  /// 获取资金账户关联的账本
  Future<OperateResult<List<FundBookVO>>> getDefaultRelatedBooks() async {
    final books = await db.select(db.accountBookTable).get();

    final users = await db.select(db.userTable).get();
    final userMap = CollectionUtil.toMap(users, (e) => e.id);
    // 生成默认的RelatedAccountBook 对象
    return OperateResult.success(books
        .map((e) => FundBookVO(
              id: IdUtil.genId(),
              accountBookId: e.id,
              name: e.name,
              description: e.description,
              fromId: e.createdBy,
              fromName: userMap[e.createdBy]?.nickname ?? '',
              icon: e.icon,
              fundIn: false,
              fundOut: false,
              isDefault: false,
            ))
        .toList());
  }

  /// 将资金账户转换为视图对象
  Future<List<UserFundVO>> toUserFundVO(List<AccountFund> funds) async {
    final List<UserFundVO> result = [];
    final fundMap = CollectionUtil.toMap(funds, (e) => e.id);
    // 查询出所有账本
    final books = await db.select(db.accountBookTable).get();
    // 查询出所有fundIds关联的记录
    final rels = await (db.select(db.relAccountbookFundTable)
          ..where((t) => t.fundId.isIn(funds.map((e) => e.id))))
        .get();

    final users = await db.select(db.userTable).get();
    final userMap = CollectionUtil.toMap(users, (e) => e.id);

    // 查询出所有关联记录中包含该资金账户的记录
    final relGroupMap = CollectionUtil.groupBy(rels, (e) => e.fundId);
    for (var fund in funds) {
      if (fundMap.containsKey(fund.id)) {
        final relMap = CollectionUtil.toMap(
            relGroupMap[fund.id] ?? [], (e) => e.accountBookId);
        final relatedBooks =
            books.where((e) => relMap.containsKey(e.id)).map((e) {
          final rel = relMap[e.id];
          return FundBookVO(
            id: rel.id,
            accountBookId: e.id,
            name: e.name,
            description: e.description,
            icon: e.icon,
            fromId: e.createdBy,
            fromName: userMap[e.createdBy]?.nickname ?? '',
            fundIn: rel.fundIn,
            fundOut: rel.fundOut,
            isDefault: rel.isDefault,
          );
        }).toList();

        result.add(UserFundVO.fromFundAndBooks(
          fund: fund,
          books: relatedBooks,
        ));
      }
    }

    return result;
  }

  /// 获取默认资金账户
  Future<AccountFund?> getDefaultFund(String userId) async {
    final fund = await (db.select(db.accountFundTable)
          ..where((t) => t.createdBy.equals(userId) & t.isDefault.equals(true)))
        .getSingleOrNull();
    if (fund == null) {}
    return fund;
  }

  Future<OperateResult<void>> addBookToDefaultFund(
      String bookId, String userId) async {
    final fund = await (db.select(db.accountFundTable)
          ..where((t) => t.createdBy.equals(userId) & t.isDefault.equals(true)))
        .getSingleOrNull();
    if (fund != null) {
      await db.into(db.relAccountbookFundTable).insert(
            RelAccountbookFundTableCompanion.insert(
              id: generateUuid(),
              accountBookId: bookId,
              fundId: fund.id,
              fundIn: const Value(true),
              fundOut: const Value(true),
              isDefault: const Value(false),
              createdAt: DateUtil.now(),
              updatedAt: DateUtil.now(),
            ),
          );
    }
    return OperateResult.success(null);
  }
}
