import 'package:drift/drift.dart';
import '../database.dart';
import '../../utils/date_util.dart';
import '../tables/account_item_table.dart';
import 'base_dao.dart';

class AccountItemDao extends BaseDao<AccountItemTable, AccountItem> {
  AccountItemDao(super.db);

  Future<List<AccountItem>> findByAccountBookId(String accountBookId, {int limit = 20, int offset = 0}) {
    final query = db.select(db.accountItemTable)
      ..where((t) => t.accountBookId.equals(accountBookId))
      ..orderBy([(t) => OrderingTerm.desc(t.accountDate)])
      ..limit(limit, offset: offset);
    return query.get();
  }

  Future<List<AccountItem>> findByDateRange(String accountBookId, String startDate, String endDate) {
    return (db.select(db.accountItemTable)
          ..where((t) => t.accountBookId.equals(accountBookId) & t.accountDate.isBetweenValues(startDate, endDate)))
        .get();
  }

  Future<List<AccountItem>> findByFundId(String fundId) {
    return (db.select(db.accountItemTable)..where((t) => t.fundId.equals(fundId))).get();
  }

  Future<List<AccountItem>> findByCategoryCode(String categoryCode) {
    return (db.select(db.accountItemTable)..where((t) => t.categoryCode.equals(categoryCode))).get();
  }

  Future<void> createAccountItem({
    required String id,
    required double amount,
    required String type,
    required String accountDate,
    required String accountBookId,
    required String createdBy,
    required String updatedBy,
    String? description,
    String? categoryCode,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
  }) {
    return insert(
      AccountItemTableCompanion.insert(
        id: id,
        amount: amount,
        type: type,
        accountDate: accountDate,
        accountBookId: accountBookId,
        description: Value(description),
        categoryCode: Value(categoryCode),
        fundId: Value(fundId),
        shopCode: Value(shopCode),
        tagCode: Value(tagCode),
        projectCode: Value(projectCode),
        createdBy: createdBy,
        updatedBy: updatedBy,
        createdAt: DateUtil.now(),
        updatedAt: DateUtil.now(),
      ),
    );
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
