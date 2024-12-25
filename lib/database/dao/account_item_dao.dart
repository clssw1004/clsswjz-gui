import 'package:drift/drift.dart';
import '../database.dart';

class AccountItemDao {
  final AppDatabase db;

  AccountItemDao(this.db);

  Future<int> insert(AccountItemTableCompanion entity) {
    return db.into(db.accountItemTable).insert(entity);
  }

  Future<void> batchInsert(List<AccountItemTableCompanion> entities) async {
    await db.batch((batch) {
      for (var entity in entities) {
        batch.insert(db.accountItemTable, entity,
            mode: InsertMode.insertOrReplace);
      }
    });
  }

  Future<bool> update(AccountItemTableCompanion entity) {
    return db.update(db.accountItemTable).replace(entity);
  }

  Future<int> delete(AccountItem entity) {
    return db.delete(db.accountItemTable).delete(entity);
  }

  Future<List<AccountItem>> findAll() {
    return db.select(db.accountItemTable).get();
  }

  Future<AccountItem?> findById(String id) {
    return (db.select(db.accountItemTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<AccountItem>> findByAccountBookId(String accountBookId) {
    final query = db.select(db.accountItemTable)
      ..where((t) => t.accountBookId.equals(accountBookId))
      ..orderBy([(t) => OrderingTerm.desc(t.accountDate)]);
    return query.get();
  }

  Future<List<AccountItem>> findByDateRange(
      String accountBookId, String startDate, String endDate) {
    return (db.select(db.accountItemTable)
          ..where((t) =>
              t.accountBookId.equals(accountBookId) &
              t.accountDate.isBetweenValues(startDate, endDate)))
        .get();
  }

  Future<List<AccountItem>> findByFundId(String fundId) {
    return (db.select(db.accountItemTable)
          ..where((t) => t.fundId.equals(fundId)))
        .get();
  }

  Future<List<AccountItem>> findByCategoryCode(String categoryCode) {
    return (db.select(db.accountItemTable)
          ..where((t) => t.categoryCode.equals(categoryCode)))
        .get();
  }

  Future<int> createAccountItem({
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
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
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
      conditions.add(
          db.accountItemTable.accountDate.isBetweenValues(startDate, endDate));
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
}
