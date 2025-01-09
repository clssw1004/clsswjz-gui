import 'package:drift/drift.dart';
import '../database/dao/account_category_dao.dart';
import '../database/database.dart';
import '../manager/database_manager.dart';
import '../models/common.dart';
import 'base_service.dart';

/// 账目分类服务
class AccountCategoryService extends BaseService {
  final AccountCategoryDao _accountCategoryDao;
  AccountCategoryService() : _accountCategoryDao = AccountCategoryDao(DatabaseManager.db);

  /// 获取账本下的所有分类
  Future<OperateResult<List<AccountCategory>>> getCategoriesByAccountBook(String accountBookId) async {
    try {
      final categories =
          await (db.select(db.accountCategoryTable)..where((t) => t.accountBookId.equals(accountBookId))).get();
      return OperateResult.success(categories);
    } catch (e) {
      return OperateResult.failWithMessage(message: '获取账本分类失败: ${e.toString()}', exception: e as Exception);
    }
  }

  /// 获取账本下指定类型的分类
  Future<OperateResult<List<AccountCategory>>> getCategoriesByType(String accountBookId, String categoryType) async {
    try {
      final categories = await (db.select(db.accountCategoryTable)
            ..where((t) => t.accountBookId.equals(accountBookId) & t.categoryType.equals(categoryType)))
          .get();
      return OperateResult.success(categories);
    } catch (e) {
      return OperateResult.failWithMessage(message: '获取账本分类失败: ${e.toString()}', exception: e as Exception);
    }
  }

  Future<OperateResult<bool>> checkCategoryName(String bookId, String categoryType, String name) async {
    final categories = await (db.select(db.accountCategoryTable)
          ..where((t) => t.accountBookId.equals(bookId) & t.categoryType.equals(categoryType) & t.name.equals(name)))
        .get();
    if (categories.isNotEmpty) {
      return OperateResult.failWithMessage(message: '分类名称已存在');
    }
    return OperateResult.success(true);
  }
}
