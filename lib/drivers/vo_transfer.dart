
import '../database/database.dart';
import '../enums/business_type.dart';
import '../enums/symbol_type.dart';
import '../manager/dao_manager.dart';
import '../models/dto/item_filter_dto.dart';
import '../models/vo/attachment_show_vo.dart';
import '../models/vo/user_debt_vo.dart';
import '../models/vo/user_item_vo.dart';
import '../models/vo/user_fund_vo.dart';
import '../models/vo/user_note_vo.dart';
import '../utils/collection_util.dart';
import 'driver_factory.dart';

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

    final symbolMap = CollectionUtil.groupBy(
        await DaoManager.symbolDao
            .findByTypes([SymbolType.tag.code, SymbolType.project.code]),
        (s) => s.symbolType);

    final tags = CollectionUtil.toMap(
        symbolMap[SymbolType.tag.code] ?? [], (s) => s.code);
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

      final tag = tags[item.tagCode];

      final project = projects[item.projectCode];

      final createdByUser = users[item.createdBy];

      final updatedByUser = users[item.updatedBy];

      return UserItemVO.fromAccountItem(
        item: item,
        categoryName: category?.name,
        fundName: fund?.name,
        shopName: shop?.name,
        tagName: tag?.name,
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
      String bookId, String userId, List<AccountDebt> debts) async {
    final fundIds = debts.map((debt) => debt.fundId).toSet().toList();

    final funds = await DaoManager.fundDao.findByIds(fundIds);

    final fundMap = CollectionUtil.toMap(funds, (e) => e.id);

    final items = await DriverFactory.driver
            .listItemsByBook(userId, bookId,
                filter: ItemFilterDTO(
                  source: BusinessType.debt.code,
                  sourceIds: debts.map((debt) => debt.id).toList(),
                ))
            .then((value) => value.data) ??
        [];

    final itemMap = CollectionUtil.groupBy(items, (e) => e.sourceId);

    return debts.map((debt) {
      final subItems = itemMap[debt.id];
      final remainAmount =
          subItems?.fold<double>(0.0, (sum, e) => sum + e.amount) ?? 0.0;
      final totalAmount = subItems
              ?.where((item) => item.categoryCode == debt.debtType)
              .fold<double>(0.0, (sum, e) => sum + e.amount) ??
          0.0;
      return UserDebtVO.fromDebt(
        debt: debt,
        totalAmount: totalAmount,
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
