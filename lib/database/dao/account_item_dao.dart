import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/account_item_table.dart';
import 'base_dao.dart';

class AccountItemDao extends BaseBookDao<AccountItemTable, AccountItem> {
  AccountItemDao(super.db);

  @override
  List<OrderClauseGenerator<AccountItemTable>> defaultOrderBy() {
    return [
      (t) => OrderingTerm.desc(t.accountDate),
    ];
  }

  Future<List<AccountItem>> findByConditions({
    String? accountBookId,
    String? type,
    String? categoryCode,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    String? startDate,
    String? endDate,
  }) {
    var query = db.select(db.accountItemTable);

    var conditions = <Expression<bool>>[];

    if (accountBookId != null) {
      conditions.add(db.accountItemTable.accountBookId.equals(accountBookId));
    }
    if (type != null) {
      conditions.add(db.accountItemTable.type.equals(type));
    }
    if (categoryCode != null) {
      conditions.add(db.accountItemTable.categoryCode.equals(categoryCode));
    }
    if (fundId != null) {
      conditions.add(db.accountItemTable.fundId.equals(fundId));
    }
    if (shopCode != null) {
      conditions.add(db.accountItemTable.shopCode.equals(shopCode));
    }
    if (tagCode != null) {
      conditions.add(db.accountItemTable.tagCode.equals(tagCode));
    }
    if (projectCode != null) {
      conditions.add(db.accountItemTable.projectCode.equals(projectCode));
    }
    if (startDate != null && endDate != null) {
      conditions.add(db.accountItemTable.accountDate.isBetweenValues(startDate, endDate));
    }

    if (conditions.isNotEmpty) {
      Expression<bool> whereClause = conditions.first;
      for (var i = 1; i < conditions.length; i++) {
        whereClause = whereClause & conditions[i];
      }
      query.where((tbl) => whereClause);
    }

    return query.get();
  }

  @override
  TableInfo<AccountItemTable, AccountItem> get table => db.accountItemTable;
}
