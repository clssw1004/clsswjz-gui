import '../manager/database_manager.dart';
import '../manager/user_config_manager.dart';
import '../models/common.dart';
import '../models/vo/statistic_vo.dart';
import '../models/vo/user_vo.dart';
import '../enums/account_type.dart';
import 'package:drift/drift.dart' hide Column;

class StatisticService {
  // 统计当前用户的账本数、账目数、记账天数
  Future<OperateResult<UserStatisticVO>> getUserStatisticInfo(
      String userId) async {
    UserVO user = UserConfigManager.instance.currentUser;
    final db = DatabaseManager.db;
    // 1. 统计账本数量
    final bookCount = await (db.select(db.relAccountbookUserTable)
          ..where((tbl) => tbl.userId.equals(user.id)))
        .get()
        .then((value) => value.length);

    // 2. 统计账目数量
    final itemQuery = db.select(db.accountItemTable).join([
      leftOuterJoin(
        db.relAccountbookUserTable,
        db.relAccountbookUserTable.accountBookId.equalsExp(
          db.accountItemTable.accountBookId,
        ),
      ),
    ]);

    itemQuery.where(db.relAccountbookUserTable.userId.equals(user.id) &
        db.relAccountbookUserTable.canViewItem.equals(true));

    final itemCount = await itemQuery
        .map((row) => row.readTable(db.accountItemTable))
        .get()
        .then((value) => value.length);

    // 3. 统计记账天数(根据账目创建时间去重计算)
    final query = db.select(db.accountItemTable).join([
      leftOuterJoin(
        db.relAccountbookUserTable,
        db.relAccountbookUserTable.accountBookId.equalsExp(
          db.accountItemTable.accountBookId,
        ),
      ),
    ]);

    query.where(db.relAccountbookUserTable.userId.equals(user.id) &
        db.relAccountbookUserTable.canViewItem.equals(true));

    final days = await query
        .map((row) => row.readTable(db.accountItemTable))
        .get()
        .then((items) => items
            .map((item) => item.accountDate)
            .map((date) => date.toString().split(' ')[0])
            .toSet()
            .length);

    return OperateResult.success(UserStatisticVO(
      bookCount: bookCount,
      itemCount: itemCount,
      dayCount: days,
    ));
  }

  /// 查询指定账本的收入、支出、结余统计信息
  Future<OperateResult<BookStatisticVO>> getBookStatisticInfo(
      String accountBookId) async {
    final db = DatabaseManager.db;

    // 使用SQL聚合函数直接计算收入总额
    final incomeQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.income.code))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final incomeResult = await incomeQuery.getSingle();
    final income = incomeResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 使用SQL聚合函数直接计算支出总额
    final expenseQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          db.accountItemTable.type.equals(AccountItemType.expense.code))
      ..addColumns([db.accountItemTable.amount.sum()]);

    final expenseResult = await expenseQuery.getSingle();
    final expense = expenseResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

    // 计算结余（收入减去支出）
    final balance = income + expense;

    // 获取最近一天的日期
    final lastDayQuery = db.selectOnly(db.accountItemTable)
      ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
          (db.accountItemTable.type.equals(AccountItemType.income.code) |
              db.accountItemTable.type.equals(AccountItemType.expense.code)))
      ..orderBy([OrderingTerm.desc(db.accountItemTable.accountDate)])
      ..limit(1)
      ..addColumns([db.accountItemTable.accountDate]);

    final lastDayResult = await lastDayQuery.getSingleOrNull();

    double lastDayIncome = 0.0;
    double lastDayExpense = 0.0;
    double lastDayBalance = 0.0;
    String lastDay = '';
    if (lastDayResult != null) {
      lastDay = lastDayResult.read(db.accountItemTable.accountDate) ?? '';
      // 查询最近一天的收入
      final lastDayIncomeQuery = db.selectOnly(db.accountItemTable)
        ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
            db.accountItemTable.type.equals(AccountItemType.income.code) &
            db.accountItemTable.accountDate.equals(lastDay))
        ..addColumns([db.accountItemTable.amount.sum()]);

      final lastDayIncomeResult = await lastDayIncomeQuery.getSingle();
      lastDayIncome =
          lastDayIncomeResult.read(db.accountItemTable.amount.sum()) ?? 0.0;

      // 查询最近一天的支出
      final lastDayExpenseQuery = db.selectOnly(db.accountItemTable)
        ..where(db.accountItemTable.accountBookId.equals(accountBookId) &
            db.accountItemTable.type.equals(AccountItemType.expense.code) &
            db.accountItemTable.accountDate.equals(lastDay))
        ..addColumns([db.accountItemTable.amount.sum()]);

      final lastDayExpenseResult = await lastDayExpenseQuery.getSingle();
      lastDayExpense =
          lastDayExpenseResult.read(db.accountItemTable.amount.sum()) ?? 0.0;
      // 计算最近一天的结余
      lastDayBalance = lastDayIncome + lastDayExpense;
    }

    return OperateResult.success(BookStatisticVO(
      totalIncome: income,
      totalExpense: expense,
      totalBalance: balance,
      lastDayIncome: lastDayIncome,
      lastDayExpense: lastDayExpense,
      lastDayBalance: lastDayBalance,
      lastDate: lastDay,
    ));
  }
}
