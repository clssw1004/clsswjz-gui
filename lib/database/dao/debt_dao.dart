import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/account_debt_table.dart';
import 'base_dao.dart';

class DebtDao extends BaseBookDao<AccountDebtTable, AccountDebt> {
  DebtDao(super.db);

  @override
  TableInfo<AccountDebtTable, AccountDebt> get table => db.accountDebtTable;

  @override
  Future<List<AccountDebt>> listByBook(String accountBookId,
      {int? limit, int? offset, String? keyword}) {
    final query = (db.select(table)
      ..where((t) {
        var predicate = t.accountBookId.equals(accountBookId);
        if (keyword != null && keyword.isNotEmpty) {
          predicate = predicate & t.debtor.like('%$keyword%');
        }
        return predicate;
      })
      ..orderBy(defaultOrderBy()));
    if (limit != null) {
      query.limit(limit, offset: offset);
    }
    return query.get();
  }
}
