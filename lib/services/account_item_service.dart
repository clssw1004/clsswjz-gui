import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import '../database/dao/account_category_dao.dart';
import '../database/dao/account_fund_dao.dart';
import '../database/dao/account_item_dao.dart';
import '../database/database.dart';
import '../database/database_service.dart';
import '../models/common.dart';
import 'base_service.dart';
import '../models/vo/account_item_vo.dart';

class AccountItemService extends BaseService {
  final AccountItemDao _accountItemDao;
  final AccountCategoryDao _accountCategoryDao;
  final AccountFundDao _accountFundDao;

  AccountItemService()
      : _accountItemDao = AccountItemDao(DatabaseService.db),
        _accountCategoryDao = AccountCategoryDao(DatabaseService.db),
        _accountFundDao = AccountFundDao(DatabaseService.db);

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
          return OperateResult.fail('无效的分类代码', null);
        }
      }

      // 验证资金账户是否存在
      if (fundId != null) {
        final fund = await _accountFundDao.findById(fundId);
        if (fund == null) {
          return OperateResult.fail('无效的资金账户', null);
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
      return OperateResult.fail('创建账目失败：$e', e as Exception);
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
        return OperateResult.fail('账目不存在', null);
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
          await _accountFundDao.updateBalance(item.fundId!, oldBalance);
        }
      }

      await _accountItemDao.update(AccountItemTableCompanion(
        id: Value(id),
        amount: absentIfNull(amount),
        type: absentIfNull(type),
        accountDate: absentIfNull(accountDate),
        description: absentIfNull(description),
        categoryCode: absentIfNull(categoryCode),
        fundId: absentIfNull(fundId),
        shopCode: absentIfNull(shopCode),
        tagCode: absentIfNull(tagCode),
        projectCode: absentIfNull(projectCode),
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
            await _accountFundDao.updateBalance(targetFundId, newBalance);
          }
        }
      }

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail('更新账目失败：$e', e as Exception);
    }
  }

  /// 删除账目
  Future<OperateResult<void>> deleteAccountItem(String id) async {
    try {
      final item = await _accountItemDao.findById(id);
      if (item == null) {
        return OperateResult.fail('账目不存在', null);
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
      return OperateResult.fail('删除账目失败：$e', e as Exception);
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
      return OperateResult.fail('获取账目列表失败：$e', e as Exception);
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
      return OperateResult.fail('获取账目列表失败：$e', e as Exception);
    }
  }

  Future<OperateResult<List<AccountItem>>> getAll() async {
    try {
      return OperateResult.success(await _accountItemDao.findAll());
    } catch (e) {
      return OperateResult.fail('获取账目列表失败：$e', e as Exception);
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
    final categories = categoryCodes.isEmpty
        ? <AccountCategory>[]
        : await (db.select(db.accountCategoryTable)
              ..where((t) => t.code.isIn(categoryCodes)))
            .get();

    final funds = fundIds.isEmpty
        ? <AccountFund>[]
        : await (db.select(db.accountFundTable)
              ..where((t) => t.id.isIn(fundIds)))
            .get();

    final shops = shopCodes.isEmpty
        ? <AccountShop>[]
        : await (db.select(db.accountShopTable)
              ..where((t) => t.code.isIn(shopCodes)))
            .get();

    final symbols = [...tagCodes, ...projectCodes].isEmpty
        ? <AccountSymbol>[]
        : await (db.select(db.accountSymbolTable)
              ..where((t) => t.code.isIn([...tagCodes, ...projectCodes])))
            .get();

    final users = userIds.isEmpty
        ? <User>[]
        : await (db.select(db.userTable)..where((t) => t.id.isIn(userIds)))
            .get();

    // 4. 组装VO对象
    return items.map((item) {
      // 查找关联数据
      final category = item.categoryCode == null
          ? null
          : categories.firstWhereOrNull(
              (c) => c.code == item.categoryCode,
            );

      final fund = item.fundId == null
          ? null
          : funds.firstWhereOrNull(
              (f) => f.id == item.fundId,
            );

      final shop = item.shopCode == null
          ? null
          : shops.firstWhereOrNull(
              (s) => s.code == item.shopCode,
            );

      final tag = item.tagCode == null
          ? null
          : symbols.firstWhereOrNull(
              (s) => s.code == item.tagCode && s.symbolType == 'TAG',
            );

      final project = item.projectCode == null
          ? null
          : symbols.firstWhereOrNull(
              (s) => s.code == item.projectCode && s.symbolType == 'PROJECT',
            );

      final createdByUser = users.firstWhereOrNull(
        (u) => u.id == item.createdBy,
      );

      final updatedByUser = users.firstWhereOrNull(
        (u) => u.id == item.updatedBy,
      );

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
