import 'package:clsswjz/constants/constant.dart';
import 'package:drift/drift.dart';
import '../database/dao/account_category_dao.dart';
import '../database/dao/account_fund_dao.dart';
import '../database/dao/account_item_dao.dart';
import '../database/dao/account_shop_dao.dart';
import '../database/dao/account_symbol_dao.dart';
import '../database/dao/user_dao.dart';
import '../database/database.dart';
import '../manager/database_manager.dart';
import '../models/common.dart';
import '../utils/collection_util.dart';
import 'base_service.dart';
import '../models/vo/account_item_vo.dart';

class AccountItemService extends BaseService {
  final AccountItemDao _accountItemDao;
  final AccountCategoryDao _accountCategoryDao;
  final AccountFundDao _accountFundDao;
  final AccountSymbolDao _accountSymbolDao;
  final AccountShopDao _accountShopDao;
  final UserDao _userDao;

  AccountItemService()
      : _accountItemDao = AccountItemDao(DatabaseManager.db),
        _accountCategoryDao = AccountCategoryDao(DatabaseManager.db),
        _accountFundDao = AccountFundDao(DatabaseManager.db),
        _accountSymbolDao = AccountSymbolDao(DatabaseManager.db),
        _accountShopDao = AccountShopDao(DatabaseManager.db),
        _userDao = UserDao(DatabaseManager.db);

  /// 创建账目
  Future<OperateResult<String>> createAccountItem({
    required double amount,
    required String type,
    required String accountDate,
    required String accountBookId,
    required String userId,
    String? description,
    String? categoryCode,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
  }) async {
    try {
      // 验证分类是否存在
      if (categoryCode != null) {
        final categories = await _accountCategoryDao.findByAccountBookIdAndType(
            accountBookId, type);
        if (!categories.any((c) => c.code == categoryCode)) {
          return OperateResult.failWithMessage('无效的分类代码', null);
        }
      }

      // 验证资金账户是否存在
      if (fundId != null) {
        final fund = await _accountFundDao.findById(fundId);
        if (fund == null) {
          return OperateResult.failWithMessage('无效的资金账户', null);
        }
      }

      final id = generateUuid();
      await _accountItemDao.createAccountItem(
        id: id,
        amount: amount,
        type: type,
        accountDate: accountDate,
        accountBookId: accountBookId,
        description: description,
        categoryCode: categoryCode,
        fundId: fundId,
        shopCode: shopCode,
        tagCode: tagCode,
        projectCode: projectCode,
        createdBy: userId,
        updatedBy: userId,
      );

      // 如果指定了资金账户，更新账户余额
      if (fundId != null) {
        final fund = await _accountFundDao.findById(fundId);
        if (fund != null) {
          double newBalance = fund.fundBalance;
          if (type == 'INCOME') {
            newBalance += amount;
          } else if (type == 'EXPENSE') {
            newBalance -= amount;
          }
          await _accountFundDao.updateBalance(fundId, newBalance);
        }
      }

      // 更新分类的最后记账时间
      if (categoryCode != null) {
        final categories = await _accountCategoryDao.findByAccountBookIdAndType(
            accountBookId, type);
        final category = categories.firstWhere((c) => c.code == categoryCode);
        await _accountCategoryDao.update(AccountCategoryTableCompanion(
          id: Value(category.id),
          lastAccountItemAt: Value(DateTime.now()),
          updatedBy: Value(userId),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ));
      }

      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage('创建账目失败：$e', e as Exception);
    }
  }

  /// 更新账目
  Future<OperateResult<void>> updateAccountItem({
    required String id,
    required String userId,
    double? amount,
    String? type,
    String? accountDate,
    String? description,
    String? categoryCode,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
  }) async {
    try {
      final item = await _accountItemDao.findById(id);
      if (item == null) {
        return OperateResult.failWithMessage('账目不存在', null);
      }

      // 如果修改了资金账户，先恢复原账户余额
      if (item.fundId != null) {
        final oldFund = await _accountFundDao.findById(item.fundId!);
        if (oldFund != null) {
          double oldBalance = oldFund.fundBalance;
          if (item.type == 'INCOME') {
            oldBalance -= item.amount;
          } else if (item.type == 'EXPENSE') {
            oldBalance += item.amount;
          }
          await _accountFundDao.update(AccountFundTableCompanion(
            id: Value(item.fundId!),
            fundBalance: Value(oldBalance),
            name: Value(oldFund.name),
            fundType: Value(oldFund.fundType),
            fundRemark: Value(oldFund.fundRemark),
            createdBy: Value(oldFund.createdBy),
            createdAt: Value(oldFund.createdAt),
            updatedBy: Value(userId),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ));
        }
      }

      await _accountItemDao.update(AccountItemTableCompanion(
        id: Value(id),
        amount: Value(amount ?? item.amount),
        type: Value(type ?? item.type),
        accountDate: Value(accountDate ?? item.accountDate),
        description: Value(description ?? item.description ?? ''),
        categoryCode: Value(categoryCode ?? item.categoryCode ?? ''),
        fundId: Value(fundId ?? item.fundId ?? ''),
        shopCode: Value(shopCode ?? item.shopCode ?? ''),
        tagCode: Value(tagCode ?? item.tagCode ?? ''),
        projectCode: Value(projectCode ?? item.projectCode ?? ''),
        accountBookId: Value(item.accountBookId),
        createdBy: Value(item.createdBy),
        createdAt: Value(item.createdAt),
        updatedBy: Value(userId),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));

      // 如果修改了资金账户或金额，更新新账户余额
      if (fundId != null || amount != null) {
        final targetFundId = fundId ?? item.fundId;
        if (targetFundId != null) {
          final fund = await _accountFundDao.findById(targetFundId);
          if (fund != null) {
            double newBalance = fund.fundBalance;
            final targetAmount = amount ?? item.amount;
            final targetType = type ?? item.type;
            if (targetType == 'INCOME') {
              newBalance += targetAmount;
            } else if (targetType == 'EXPENSE') {
              newBalance -= targetAmount;
            }
            await _accountFundDao.update(AccountFundTableCompanion(
              id: Value(targetFundId),
              fundBalance: Value(newBalance),
              name: Value(fund.name),
              fundType: Value(fund.fundType),
              fundRemark: Value(fund.fundRemark),
              createdBy: Value(fund.createdBy),
              createdAt: Value(fund.createdAt),
              updatedBy: Value(userId),
              updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
            ));
          }
        }
      }

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage('更新账目失败：$e', e as Exception);
    }
  }

  /// 删除账目
  Future<OperateResult<void>> deleteAccountItem(String id) async {
    try {
      final item = await _accountItemDao.findById(id);
      if (item == null) {
        return OperateResult.failWithMessage('账目不存在', null);
      }

      // 如果有关联资金账户，恢复账户余额
      if (item.fundId != null) {
        final fund = await _accountFundDao.findById(item.fundId!);
        if (fund != null) {
          double newBalance = fund.fundBalance;
          if (item.type == 'INCOME') {
            newBalance -= item.amount;
          } else if (item.type == 'EXPENSE') {
            newBalance += item.amount;
          }
          await _accountFundDao.updateBalance(item.fundId!, newBalance);
        }
      }

      await _accountItemDao.delete(item);
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage('删除账目失败：$e', e as Exception);
    }
  }

  /// 获取账目列表
  Future<OperateResult<List<AccountItem>>> getAccountItems({
    String? accountBookId,
    String? type,
    String? categoryCode,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final items = await _accountItemDao.findByConditions(
        accountBookId: accountBookId,
        type: type,
        categoryCode: categoryCode,
        fundId: fundId,
        shopCode: shopCode,
        tagCode: tagCode,
        projectCode: projectCode,
        startDate: startDate,
        endDate: endDate,
      );
      return OperateResult.success(items);
    } catch (e) {
      return OperateResult.failWithMessage('获取账目列表失败：$e', e as Exception);
    }
  }

  /// 获取账本的账目列表（包含关联信息）
  Future<OperateResult<List<AccountItemVO>>> getByAccountBookId(
      String accountBookId) async {
    try {
      final items = await _accountItemDao.findByAccountBookId(accountBookId);
      if (items.isEmpty) {
        return OperateResult.success([]);
      }
      return OperateResult.success(
        await toVos(items),
      );
    } catch (e) {
      return OperateResult.failWithMessage('获取账目列表失败：$e', e as Exception);
    }
  }

  Future<OperateResult<List<AccountItem>>> getAll() async {
    try {
      return OperateResult.success(await _accountItemDao.findAll());
    } catch (e) {
      return OperateResult.failWithMessage('获取账目列表失败：$e', e as Exception);
    }
  }

  Future<List<AccountItemVO>> toVos(List<AccountItem> items) async {
    if (items.isEmpty) {
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

    final tagCodes = items
        .where((item) => item.tagCode != null)
        .map((item) => item.tagCode!)
        .toSet()
        .toList();

    final projectCodes = items
        .where((item) => item.projectCode != null)
        .map((item) => item.projectCode!)
        .toSet()
        .toList();

    // 获取所有用户ID
    final userIds = {
      ...items.map((item) => item.createdBy),
      ...items.map((item) => item.updatedBy),
    }.toList();

    // 3. 批量查询关联数据
    final categories = CollectionUtils.toMap(
        await _accountCategoryDao.findByCodes(categoryCodes), (c) => c.code);

    final funds = CollectionUtils.toMap(
        await _accountFundDao.findByIds(fundIds), (f) => f.id);

    final shops = CollectionUtils.toMap(
        await _accountShopDao.findByCodes(shopCodes), (s) => s.code);

    final symbolMap = CollectionUtils.groupBy(
        await _accountSymbolDao
            .findByTypes([SYMBOL_TYPE_TAG, SYMBOL_TYPE_PROJECT]),
        (s) => s.symbolType);

    final tags =
        CollectionUtils.toMap(symbolMap[SYMBOL_TYPE_TAG] ?? [], (s) => s.code);
    final projects = CollectionUtils.toMap(
        symbolMap[SYMBOL_TYPE_PROJECT] ?? [], (s) => s.code);

    final users =
        CollectionUtils.toMap(await _userDao.findByIds(userIds), (u) => u.id);

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
}
