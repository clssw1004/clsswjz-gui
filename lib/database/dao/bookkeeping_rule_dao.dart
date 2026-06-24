import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/bookkeeping_rule_table.dart';
import 'base_dao.dart';

/// 记账规则数据访问对象
class BookkeepingRuleDao
    extends BaseBookDao<BookkeepingRuleTable, BookkeepingRule> {
  BookkeepingRuleDao(super.db);

  @override
  TableInfo<BookkeepingRuleTable, BookkeepingRule> get table =>
      db.bookkeepingRuleTable;

  /// 查询某账本所有规则（含过滤）
  Future<List<BookkeepingRule>> findByBookWithFilter(
    String accountBookId, {
    bool? isActive,
  }) {
    final query = (db.select(table)
      ..where((t) => t.accountBookId.equals(accountBookId))
      ..orderBy([
        (t) => OrderingTerm.desc(t.priority),
        (t) => OrderingTerm.desc(t.createdAt),
      ]));
    if (isActive != null) {
      query.where((t) => t.isActive.equals(isActive));
    }
    return query.get();
  }
}
