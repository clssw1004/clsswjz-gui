import 'package:drift/drift.dart';
import 'package:flutter_gui/database/dao/account_book_dao.dart';
import 'package:flutter_gui/database/dao/rel_accountbook_user_dao.dart';
import 'package:flutter_gui/database/database.dart';
import 'package:flutter_gui/database/database_service.dart';
import 'package:flutter_gui/models/common.dart';
import 'base_service.dart';

class AccountBookService extends BaseService {
  final AccountBookDao _accountBookDao;
  final RelAccountbookUserDao _relAccountbookUserDao;

  AccountBookService()
      : _accountBookDao = AccountBookDao(DatabaseService.db),
        _relAccountbookUserDao = RelAccountbookUserDao(DatabaseService.db);

  /// 创建账本
  Future<OperateResult<String>> createAccountBook({
    required String name,
    required String description,
    required String userId,
    String currencySymbol = '¥',
    String? icon,
  }) async {
    try {
      final id = generateUuid();

      // 创建账本
      await _accountBookDao.createAccountBook(
        id: id,
        name: name,
        description: description,
        createdBy: userId,
        updatedBy: userId,
        currencySymbol: currencySymbol,
        icon: icon,
      );

      // 创建账本用户关系（创建者拥有所有权限）
      await _relAccountbookUserDao.insert(
        RelAccountbookUserTableCompanion.insert(
          id: generateUuid(),
          userId: userId,
          accountBookId: id,
          canViewBook: const Value(true),
          canEditBook: const Value(true),
          canDeleteBook: const Value(true),
          canViewItem: const Value(true),
          canEditItem: const Value(true),
          canDeleteItem: const Value(true),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.fail('创建账本失败：$e', e as Exception);
    }
  }

  /// 更新账本信息
  Future<OperateResult<void>> updateAccountBook({
    required String id,
    required String userId,
    String? name,
    String? description,
    String? currencySymbol,
    String? icon,
  }) async {
    try {
      final book = await _accountBookDao.findById(id);
      if (book == null) {
        return OperateResult.fail('账本不存在', null);
      }

      await _accountBookDao.update(AccountBookTableCompanion(
        id: Value(id),
        name: name != null ? Value(name) : const Value.absent(),
        description:
            description != null ? Value(description) : const Value.absent(),
        currencySymbol: currencySymbol != null
            ? Value(currencySymbol)
            : const Value.absent(),
        icon: icon != null ? Value(icon) : const Value.absent(),
        updatedBy: Value(userId),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail('更新账本失败：$e', e as Exception);
    }
  }

  /// 获取账本信息
  Future<OperateResult<AccountBook>> getAccountBook(String id) async {
    try {
      final book = await _accountBookDao.findById(id);
      if (book == null) {
        return OperateResult.fail('账本不存在', null);
      }
      return OperateResult.success(book);
    } catch (e) {
      return OperateResult.fail('获取账本信息失败：$e', e as Exception);
    }
  }

  /// 获取用户的账本列表
  Future<OperateResult<List<AccountBook>>> getUserAccountBooks(
      String userId) async {
    try {
      final books = await _accountBookDao.findByUserId(userId);
      return OperateResult.success(books);
    } catch (e) {
      return OperateResult.fail('获取账本列表失败：$e', e as Exception);
    }
  }

  /// 删除账本
  Future<OperateResult<void>> deleteAccountBook(String id) async {
    try {
      final book = await _accountBookDao.findById(id);
      if (book == null) {
        return OperateResult.fail('账本不存在', null);
      }

      await _accountBookDao.delete(book);
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail('删除账本失败：$e', e as Exception);
    }
  }

  /// 添加账本成员
  Future<OperateResult<void>> addMember({
    required String accountBookId,
    required String userId,
    bool canViewBook = true,
    bool canEditBook = false,
    bool canDeleteBook = false,
    bool canViewItem = true,
    bool canEditItem = false,
    bool canDeleteItem = false,
  }) async {
    try {
      await _relAccountbookUserDao.insert(
        RelAccountbookUserTableCompanion.insert(
          id: generateUuid(),
          userId: userId,
          accountBookId: accountBookId,
          canViewBook: Value(canViewBook),
          canEditBook: Value(canEditBook),
          canDeleteBook: Value(canDeleteBook),
          canViewItem: Value(canViewItem),
          canEditItem: Value(canEditItem),
          canDeleteItem: Value(canDeleteItem),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail('添加成员失败：$e', e as Exception);
    }
  }
}