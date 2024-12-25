import 'package:drift/drift.dart';
import '../database/dao/account_category_dao.dart';
import '../database/dao/account_fund_dao.dart';
import '../database/dao/account_item_dao.dart';
import '../database/database.dart';
import '../database/database_service.dart';
import '../models/common.dart';
import 'base_service.dart';

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

  Future<OperateResult<List<AccountItem>>> getByAccountBookId(
      String accountBookId) async {
    try {
      return OperateResult.success(
          await _accountItemDao.findByAccountBookId(accountBookId));
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
}
