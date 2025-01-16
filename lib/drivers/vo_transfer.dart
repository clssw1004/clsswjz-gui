import '../database/database.dart';
import '../enums/symbol_type.dart';
import '../manager/dao_manager.dart';
import '../models/vo/account_item_vo.dart';
import '../models/vo/user_fund_vo.dart';
import '../utils/collection_util.dart';

class VOTransfer {
  static Future<List<AccountItemVO>> transferAccountItem(List<AccountItem>? items) async {
    if (items == null || items.isEmpty) {
      return [];
    }

    // 2. 获取所有需要查询的ID和代码
    final categoryCodes = items.where((item) => item.categoryCode != null).map((item) => item.categoryCode!).toSet().toList();

    final fundIds = items.where((item) => item.fundId != null).map((item) => item.fundId!).toSet().toList();

    final shopCodes = items.where((item) => item.shopCode != null).map((item) => item.shopCode!).toSet().toList();

    final tagCodes = items.where((item) => item.tagCode != null).map((item) => item.tagCode!).toSet().toList();

    final projectCodes = items.where((item) => item.projectCode != null).map((item) => item.projectCode!).toSet().toList();

    // 获取所有用户ID
    final userIds = {
      ...items.map((item) => item.createdBy),
      ...items.map((item) => item.updatedBy),
    }.toList();

    // 3. 批量查询关联数据
    final categories = CollectionUtil.toMap(await DaoManager.accountCategoryDao.findByCodes(categoryCodes), (c) => c.code);

    final funds = CollectionUtil.toMap(await DaoManager.accountFundDao.findByIds(fundIds), (f) => f.id);

    final shops = CollectionUtil.toMap(await DaoManager.accountShopDao.findByCodes(shopCodes), (s) => s.code);

    final symbolMap = CollectionUtil.groupBy(
        await DaoManager.accountSymbolDao.findByTypes([SymbolType.tag.code, SymbolType.project.code]), (s) => s.symbolType);

    final tags = CollectionUtil.toMap(symbolMap[SymbolType.tag.name] ?? [], (s) => s.code);
    final projects = CollectionUtil.toMap(symbolMap[SymbolType.project.name] ?? [], (s) => s.code);

    final users = CollectionUtil.toMap(await DaoManager.userDao.findByIds(userIds), (u) => u.id);

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

      return AccountItemVO.fromAccountItem(
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

  /// 将资金账户转换为视图对象
  static Future<List<UserFundVO>> transferFunds(List<AccountFund>? funds) async {
    return funds == null || funds.isEmpty ? [] : funds.map((e) => UserFundVO.fromFundAndBooks(e)).toList();
  }

  /// 将资金账户转换为视图对象
  static Future<UserFundVO?> transferFund(AccountFund? fund) async {
    return fund == null ? null : UserFundVO.fromFundAndBooks(fund);
  }
}
