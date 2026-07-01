
import '../database/database.dart';
import '../enums/business_type.dart';
import '../enums/symbol_type.dart';
import '../manager/dao_manager.dart';
import '../models/vo/attachment_show_vo.dart';
import '../models/vo/user_debt_vo.dart';
import '../models/vo/user_item_vo.dart';
import '../models/vo/user_fund_vo.dart';
import '../models/vo/user_note_vo.dart';
import '../utils/collection_util.dart';

class VOTransfer {
  static Future<List<UserItemVO>> transferItems(
      List<AccountItem>? items) async {
    if (items == null || items.isEmpty) {
      return [];
    }

    // 2. 获取所有需要查询的ID和代码
    final categoryCodes = items
        .where((item) => item.categoryCode != null)
        .map((item) => item.categoryCode!)
        .toSet()
        .toList();

    final fundIds = items
        .where((item) => item.fundId != null)
        .map((item) => item.fundId!)
        .toSet()
        .toList();

    final shopCodes = items
        .where((item) => item.shopCode != null)
        .map((item) => item.shopCode!)
        .toSet()
        .toList();

    // 获取所有用户ID
    final userIds = {
      ...items.map((item) => item.createdBy),
      ...items.map((item) => item.updatedBy),
    }.toList();

    // 3. 批量查询关联数据
    final categories = CollectionUtil.toMap(
        await DaoManager.categoryDao.findByCodes(categoryCodes), (c) => c.code);

    final funds = CollectionUtil.toMap(
        await DaoManager.fundDao.findByIds(fundIds), (f) => f.id);

    final shops = CollectionUtil.toMap(
        await DaoManager.shopDao.findByCodes(shopCodes), (s) => s.code);

    // 批量加载 item_rel_field（取 TAG 类型）
    final relFieldMap = await DaoManager.itemRelFieldDao.findByItemIds(
      items.map((i) => i.id).toList(),
      fieldCode: 'TAG',
    );
    // 收集所有 tag code → 查 symbol 拿 name
    final allTagCodes = relFieldMap.values
        .expand((fields) => fields.map((f) => f.fieldValue))
        .toSet()
        .toList();
    final tagSymbols = CollectionUtil.toMap(
      await DaoManager.symbolDao.findByCodes(allTagCodes),
      (s) => s.code,
    );

    final symbolMap = CollectionUtil.groupBy(
        await DaoManager.symbolDao
            .findByTypes([SymbolType.project.code]),
        (s) => s.symbolType);

    final projects = CollectionUtil.toMap(
        symbolMap[SymbolType.project.code] ?? [], (s) => s.code);

    final users = CollectionUtil.toMap(
        await DaoManager.userDao.findByIds(userIds), (u) => u.id);

    // 4. 组装VO对象
    return items.map((item) {
      // 查找关联数据
      final category = categories[item.categoryCode];

      final fund = funds[item.fundId];

      final shop = shops[item.shopCode];

      final itemRelFields = relFieldMap[item.id] ?? [];
      final itemTags = itemRelFields
          .map((f) => tagSymbols[f.fieldValue])
          .whereType<AccountSymbol>()
          .toList();

      final project = projects[item.projectCode];

      final createdByUser = users[item.createdBy];

      final updatedByUser = users[item.updatedBy];

      return UserItemVO.fromAccountItem(
        item: item,
        categoryName: category?.name,
        fundName: fund?.name,
        shopName: shop?.name,
        tags: itemTags,
        projectName: project?.name,
        createdByName: createdByUser?.nickname,
        updatedByName: updatedByUser?.nickname,
      );
    }).toList();
  }

  static Future<List<UserNoteVO>> transferNote(List<AccountNote>? notes) async {
    final groupMap = CollectionUtil.toMap(
        await DaoManager.symbolDao.findByTypes([SymbolType.noteGroup.code]),
        (s) => s.code);
    if (notes == null || notes.isEmpty) {
      return [];
    } else {
      return notes.map((e) {
        final group = groupMap[e.groupCode];
        return UserNoteVO.fromAccountNote(e, group?.name);
      }).toList();
    }
  }

  /// 将资金账户转换为视图对象
  static Future<List<UserFundVO>> transferFunds(
      List<AccountFund>? funds) async {
    return funds == null || funds.isEmpty
        ? []
        : funds.map((e) => UserFundVO.fromFundAndBooks(e)).toList();
  }

  /// 将资金账户转换为视图对象
  static Future<UserFundVO?> transferFund(AccountFund? fund) async {
    return fund == null ? null : UserFundVO.fromFundAndBooks(fund);
  }

  static Future<List<UserDebtVO>> transferDebts(
      List<AccountDebt> debts) async {
    final fundIds = debts.map((debt) => debt.fundId).toSet().toList();

    final funds = await DaoManager.fundDao.findByIds(fundIds);

    final fundMap = CollectionUtil.toMap(funds, (e) => e.id);

    final items = debts.isNotEmpty
        ? await DaoManager.itemDao.findBySource(
            BusinessType.debt.code,
            debts.map((debt) => debt.id).toList(),
          )
        : <AccountItem>[];

    final itemMap = CollectionUtil.groupBy(items, (e) => e.sourceId);

    return debts.map((debt) {
      final subItems = itemMap[debt.id];
      final debtAmount = subItems
              ?.where((item) => item.categoryCode == debt.debtType)
              .fold<double>(0.0, (sum, e) => sum + e.amount) ??
          0.0;
      final operationAmount = subItems
              ?.where((item) => item.categoryCode != debt.debtType)
              .fold<double>(0.0, (sum, e) => sum + e.amount) ??
          0.0;
      // 历史数据中存在符号存储（借出为负），abs() 兼容新旧数据
      final remainAmount = debtAmount.abs() - operationAmount.abs();
      return UserDebtVO.fromDebt(
        debt: debt,
        totalAmount: debtAmount.abs(),
        remainAmount: remainAmount,
        fundName: fundMap[debt.fundId]?.name ?? '',
      );
    }).toList();
  }

  static Future<List<AttachmentShowVO>> transferAttachments(
      List<Attachment>? attachments) async {
    if (attachments == null || attachments.isEmpty) {
      return [];
    }
    final businessTypeMap = CollectionUtil.groupByWith(
        attachments, (s) => s.businessCode, (s) => s.businessId);
    final items = (businessTypeMap.containsKey(BusinessType.item.code)
        ? await transferItems(await DaoManager.itemDao
            .findByIds(businessTypeMap[BusinessType.item.code]!))
        : []) as List<UserItemVO>;

    final notes = (businessTypeMap.containsKey(BusinessType.note.code)
        ? await transferNote(await DaoManager.noteDao
            .findByIds(businessTypeMap[BusinessType.note.code]!))
        : []) as List<UserNoteVO>;

    final Map<String, String> businessNameMap = {};
    for (var item in items) {
      businessNameMap[item.id] =
          '${item.categoryName}${item.description ?? ""}';
    }
    for (var note in notes) {
      businessNameMap[note.id] = note.title ?? "";
    }

    return await Future.wait(attachments.map((e) =>
        AttachmentShowVO.fromAttachment(
            e,
            businessNameMap.containsKey(e.businessId)
                ? businessNameMap[e.businessId]!
                : " ")));
  }
}
