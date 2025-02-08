import 'package:drift/drift.dart';
import '../../models/dto/item_filter_dto.dart';
import '../database.dart';
import '../tables/account_item_table.dart';
import 'base_dao.dart';

class ItemDao extends BaseBookDao<AccountItemTable, AccountItem> {
  ItemDao(super.db);

  @override
  List<OrderClauseGenerator<AccountItemTable>> defaultOrderBy() {
    return [
      (t) => OrderingTerm.desc(t.accountDate),
    ];
  }

  @override
  Future<List<AccountItem>> listByBook(String accountBookId,
      {int? limit, int? offset, ItemFilterDTO? filter}) {
    var query = db.select(table)
      ..where((t) => t.accountBookId.equals(accountBookId));

    // 应用筛选条件
    if (filter != null) {
      // 账目类型筛选
      if (filter.types?.isNotEmpty == true) {
        query = query..where((t) => t.type.isIn(filter.types!));
      }

      // 金额范围筛选
      if (filter.minAmount != null) {
        query = query
          ..where((t) => t.amount.isBiggerOrEqualValue(filter.minAmount!));
      }
      if (filter.maxAmount != null) {
        query = query
          ..where((t) => t.amount.isSmallerOrEqualValue(filter.maxAmount!));
      }

      // 日期范围筛选
      if (filter.startDate != null) {
        query = query
          ..where((t) => t.accountDate.isBiggerOrEqualValue(filter.startDate!));
      }
      if (filter.endDate != null) {
        query = query
          ..where((t) => t.accountDate.isSmallerOrEqualValue(filter.endDate!));
      }

      // 分类筛选
      if (filter.categoryCodes?.isNotEmpty == true) {
        query = query..where((t) => t.categoryCode.isIn(filter.categoryCodes!));
      }

      // 商户筛选
      if (filter.shopCodes?.isNotEmpty == true) {
        query = query..where((t) => t.shopCode.isIn(filter.shopCodes!));
      }

      // 账户筛选
      if (filter.fundIds?.isNotEmpty == true) {
        query = query..where((t) => t.fundId.isIn(filter.fundIds!));
      }
      // 项目筛选
      if (filter.projectCodes?.isNotEmpty == true) {
        query = query..where((t) => t.projectCode.isIn(filter.projectCodes!));
      }

      // 标签筛选
      if (filter.tagCodes?.isNotEmpty == true) {
        query = query..where((t) => t.tagCode.isIn(filter.tagCodes!));
      }
    }

    // 按日期倒序排序
    query = query..orderBy([...defaultOrderBy()]);

    // 应用分页
    if (limit != null && limit > 0) {
      query = query..limit(limit, offset: offset);
    }

    return query.get();
  }

  @override
  TableInfo<AccountItemTable, AccountItem> get table => db.accountItemTable;
}
