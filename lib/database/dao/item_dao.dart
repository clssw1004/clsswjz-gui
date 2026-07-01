import 'package:drift/drift.dart';
import '../../manager/dao_manager.dart';
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
      (t) => OrderingTerm.desc(t.createdAt),
    ];
  }

  @override
  Future<List<AccountItem>> listByBook(String accountBookId,
      {int? limit, int? offset, ItemFilterDTO? filter}) async {
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
        final relFields = await DaoManager.itemRelFieldDao
            .findByFieldCodeAndValues('TAG', filter.tagCodes!);
        final matchingIds = relFields.map((f) => f.itemId).toSet().toList();
        if (matchingIds.isEmpty) {
          query = query..where((t) => t.id.equals('__no_match__'));
        } else {
          query = query..where((t) => t.id.isIn(matchingIds));
        }
      }
      // 来源筛选
      if (filter.source != null) {
        query = query..where((t) => t.source.equals(filter.source!));
      }
      if (filter.sourceIds?.isNotEmpty == true) {
        query = query..where((t) => t.sourceId.isIn(filter.sourceIds!));
      }
      // 关键字筛选
      if (filter.keyword != null && filter.keyword!.isNotEmpty) {
        final kw = filter.keyword!.trim();

        // 纯数字 → 金额检索（账目可能为负数，双向匹配）
        final isNum = RegExp(r'^-?\d+(\.\d+)?$').hasMatch(kw);
        final amountVal = isNum ? double.tryParse(kw) : null;

        // 日期格式 yyyy-MM-dd 或 yyyy/MM/dd → 日期检索
        final isDate = RegExp(r'^\d{4}[-/]\d{1,2}[-/]\d{1,2}$').hasMatch(kw);
        final dateStr = isDate ? kw.replaceAll('/', '-') : null;

        // 分类名称反向查找 → 匹配的 category_code
        final catCodes = (await (db.select(db.accountCategoryTable)
          ..where((tbl) =>
              tbl.accountBookId.equals(accountBookId) &
              tbl.name.contains(kw))).get())
            .map((c) => c.code)
            .toList();

        // 商户名称反向查找 → 匹配的 shop_code
        final shopCodes = (await (db.select(db.accountShopTable)
          ..where((tbl) =>
              tbl.accountBookId.equals(accountBookId) &
              tbl.name.contains(kw))).get())
            .map((s) => s.code)
            .toList();

        // 资金账户名称反向查找 → 匹配的 fund_id
        final fundIds = (await (db.select(db.accountFundTable)
          ..where((tbl) =>
              tbl.accountBookId.equals(accountBookId) &
              tbl.name.contains(kw))).get())
            .map((f) => f.id)
            .toList();

        // 项目名称反向查找 → 匹配的 project_code
        final projectCodes = (await (db.select(db.accountSymbolTable)
          ..where((tbl) =>
              tbl.accountBookId.equals(accountBookId) &
              tbl.symbolType.equals('PROJECT') &
              tbl.name.contains(kw))).get())
            .map((s) => s.code)
            .toList();

        // 标签名称反向查找 → 匹配的 tag_code
        final tagCodes = (await (db.select(db.accountSymbolTable)
          ..where((tbl) =>
              tbl.accountBookId.equals(accountBookId) &
              tbl.symbolType.equals('TAG') &
              tbl.name.contains(kw))).get())
            .map((s) => s.code)
            .toList();
        // 从 item_rel_field 反查匹配标签的 item_id
        final tagItemIds = tagCodes.isNotEmpty
            ? await DaoManager.itemRelFieldDao
                .findByFieldCodeAndValues('TAG', tagCodes)
                .then((rows) => rows.map((f) => f.itemId).toList())
            : <String>[];

        query = query..where((t) {
          final conds = <Expression<bool>>[
            t.description.contains(kw),
          ];
          if (amountVal != null) {
            conds.add(t.amount.isIn([amountVal, -amountVal]));
          }
          if (dateStr != null) {
            conds.add(t.accountDate.like('$dateStr%'));
          }
          if (catCodes.isNotEmpty) {
            conds.add(t.categoryCode.isIn(catCodes));
          }
          if (shopCodes.isNotEmpty) {
            conds.add(t.shopCode.isIn(shopCodes));
          }
          if (fundIds.isNotEmpty) {
            conds.add(t.fundId.isIn(fundIds));
          }
          if (projectCodes.isNotEmpty) {
            conds.add(t.projectCode.isIn(projectCodes));
          }
          if (tagItemIds.isNotEmpty) {
            conds.add(t.id.isIn(tagItemIds));
          }
          return conds.reduce((a, b) => a | b);
        });
      }
    }

    // 按日期倒序排序
    query = query..orderBy([...defaultOrderBy()]);

    // 应用分页
    if (limit != null && limit > 0) {
      query = query..limit(limit, offset: offset);
    }

    return await query.get();
  }

  /// 按来源类型和来源ID列表查询，不限账本
  Future<List<AccountItem>> findBySource(
      String source, List<String> sourceIds) async {
    return (db.select(table)
      ..where((t) =>
          t.source.equals(source) & t.sourceId.isIn(sourceIds))
      ..orderBy([...defaultOrderBy()]))
        .get();
  }

  @override
  TableInfo<AccountItemTable, AccountItem> get table => db.accountItemTable;
}
