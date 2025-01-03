import 'package:clsswjz/enums/account_type.dart';
import 'package:clsswjz/manager/service_manager.dart';
import 'package:clsswjz/utils/collection_util.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../database/dao/account_book_dao.dart';
import '../database/dao/account_category_dao.dart';
import '../database/dao/account_fund_dao.dart';
import '../database/dao/rel_accountbook_user_dao.dart';
import '../database/dao/user_dao.dart';
import '../database/database.dart';
import '../manager/database_manager.dart';
import '../models/common.dart';
import '../models/vo/account_book_permission_vo.dart';
import '../models/vo/book_member_vo.dart';
import '../models/vo/user_book_vo.dart';
import 'base_service.dart';

class AccountBookService extends BaseService {
  final AccountBookDao _accountBookDao;
  final RelAccountbookUserDao _relAccountbookUserDao;
  final UserDao _userDao;

  AccountBookService()
      : _accountBookDao = AccountBookDao(DatabaseManager.db),
        _relAccountbookUserDao = RelAccountbookUserDao(DatabaseManager.db),
        _userDao = UserDao(DatabaseManager.db);

  /// 创建账本
  Future<OperateResult<String>> createAccountBook({
    required AccountBook accountBook,
    List<BookMemberVO>? members,
    required String userId,
  }) async {
    try {
      // 1. 检查账本名称是否重复
      final result = await checkBookName(
        bookName: accountBook.name,
        userId: userId,
        bookId: null,
      );
      if (!result.ok) {
        return OperateResult.failWithMessage(result.message, result.exception);
      }

      // 2. 生成账本ID
      final bookId = generateUuid();

      // 创建账本
      await _accountBookDao.insert(AccountBookTableCompanion.insert(
        id: bookId,
        name: accountBook.name,
        description: Value(accountBook.description),
        currencySymbol: Value(accountBook.currencySymbol),
        icon: Value(accountBook.icon),
        createdBy: userId,
        updatedBy: userId,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));

      // 添加创建人为成员，并赋予所有权限
      await _relAccountbookUserDao.insert(
        RelAccountbookUserTableCompanion.insert(
          id: generateUuid(),
          accountBookId: bookId,
          userId: userId,
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

      // 添加其他成员
      if (members != null && members.isNotEmpty) {
        await _relAccountbookUserDao.batchInsert(
          members
              .map((member) => RelAccountbookUserTableCompanion.insert(
                    id: generateUuid(),
                    accountBookId: bookId,
                    userId: member.userId,
                    canViewBook: Value(member.permission.canViewBook),
                    canEditBook: Value(member.permission.canEditBook),
                    canDeleteBook: Value(member.permission.canDeleteBook),
                    canViewItem: Value(member.permission.canViewItem),
                    canEditItem: Value(member.permission.canEditItem),
                    canDeleteItem: Value(member.permission.canDeleteItem),
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    updatedAt: DateTime.now().millisecondsSinceEpoch,
                  ))
              .toList(),
        );
      }
      ServiceManager.accountFundService.addBookToDefaultFund(bookId, userId);
      return OperateResult.success(bookId);
    } catch (e) {
      return OperateResult.failWithMessage(e.toString(), null);
    }
  }

  /// 更新账本信息
  Future<OperateResult<void>> updateAccountBook({
    required AccountBook accountBook,
    List<BookMemberVO>? members,
    required String userId,
  }) async {
    try {
      // 1. 验证账本是否存在
      final existingBook = await _accountBookDao.findById(accountBook.id);
      if (existingBook == null) {
        return OperateResult.failWithMessage('账本不存在', null);
      }

      // 2. 检查账本名称是否重复
      final result = await checkBookName(
        bookName: accountBook.name,
        userId: userId,
        bookId: accountBook.id,
      );
      if (!result.ok) {
        return result;
      }

      // 3. 更新账本基本信息
      await _accountBookDao.update(AccountBookTableCompanion(
        id: Value(accountBook.id),
        name: Value(accountBook.name),
        description: Value(accountBook.description),
        currencySymbol: Value(accountBook.currencySymbol),
        icon: Value(accountBook.icon),
        updatedBy: Value(userId),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        createdAt: Value(existingBook.createdAt),
        createdBy: Value(existingBook.createdBy),
      ));

      // 3. 如果提供了成员列表，则更新成员
      if (members != null) {
        // 3.3 删除现有的非创建者成员
        await (db.delete(db.relAccountbookUserTable)
              ..where((t) =>
                  t.accountBookId.equals(accountBook.id) &
                  t.userId.isNotValue(existingBook.createdBy)))
            .go();

        // 3.4 添加新的成员（排除创建者）
        final newMembers = members
            .where((m) => m.userId != existingBook.createdBy)
            .map((member) => RelAccountbookUserTableCompanion.insert(
                  id: generateUuid(),
                  accountBookId: accountBook.id,
                  userId: member.userId,
                  canViewBook: Value(member.permission.canViewBook),
                  canEditBook: Value(member.permission.canEditBook),
                  canDeleteBook: Value(member.permission.canDeleteBook),
                  canViewItem: Value(member.permission.canViewItem),
                  canEditItem: Value(member.permission.canEditItem),
                  canDeleteItem: Value(member.permission.canDeleteItem),
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  updatedAt: DateTime.now().millisecondsSinceEpoch,
                ))
            .toList();

        if (newMembers.isNotEmpty) {
          await _relAccountbookUserDao.batchInsert(newMembers);
        }
      }

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage('更新账本失败：$e', e as Exception);
    }
  }

  Future<OperateResult<List<AccountBook>>> getAll() async {
    try {
      return OperateResult.success(await _accountBookDao.findAll());
    } catch (e) {
      return OperateResult.failWithMessage('获取所有账本失败：$e', e as Exception);
    }
  }

  /// 获取账本信息
  Future<OperateResult<AccountBook>> getAccountBook(String id) async {
    try {
      final book = await _accountBookDao.findById(id);
      if (book == null) {
        return OperateResult.failWithMessage('账本不存在', null);
      }
      return OperateResult.success(book);
    } catch (e) {
      return OperateResult.failWithMessage('获取账本信息失败：$e', e as Exception);
    }
  }

  /// 获取用户有权限的账本列表
  Future<OperateResult<List<AccountBook>>> getUserPermissionedAccountBooks(
      String userId) async {
    try {
      final books = await _accountBookDao.findPermissionedByUserId(userId);
      return OperateResult.success(books);
    } catch (e) {
      return OperateResult.failWithMessage('获取账本列表失败：$e', e as Exception);
    }
  }

  /// 删除账本
  Future<OperateResult<void>> deleteAccountBook(String id) async {
    try {
      final book = await _accountBookDao.findById(id);
      if (book == null) {
        return OperateResult.failWithMessage('账本不存在', null);
      }

      await _accountBookDao.delete(book);
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage('删除账本失败：$e', e as Exception);
    }
  }

  /// 根据邀请码生成默认成员
  Future<OperateResult<BookMemberVO>> gernerateDefaultMemberByInviteCode(
      String inviteCode) async {
    final user = await _userDao.findByInviteCode(inviteCode);
    if (user == null) {
      return OperateResult.failWithMessage('用户不存在', null);
    }

    return OperateResult.success(BookMemberVO(
      userId: user.id,
      nickname: user.nickname,
      permission: AccountBookPermissionVO(
        canViewBook: true,
        canEditBook: false,
        canDeleteBook: false,
        canViewItem: true,
        canEditItem: false,
        canDeleteItem: false,
      ),
    ));
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
      return OperateResult.failWithMessage('添加成员失败：$e', e as Exception);
    }
  }

  /// 获取用户的账本列表及权限
  Future<OperateResult<List<UserBookVO>>> getBooksByUserId(
      String userId) async {
    try {
      // 1. 从关联表中查询用户的账本权限
      final userBooks = await (db.select(db.relAccountbookUserTable)
            ..where((tbl) => tbl.userId.equals(userId)))
          .get();

      if (userBooks.isEmpty) {
        return OperateResult.success([]);
      }

      // 2. 获取所有账本ID
      final bookIds = userBooks.map((e) => e.accountBookId).toList();

      // 3. 查询账本详细信息
      final books = await _accountBookDao.findByIds(bookIds);

      // 4. 查询所有账本的成员关系
      final allBookMembers = await (db.select(db.relAccountbookUserTable)
            ..where((tbl) => tbl.accountBookId.isIn(bookIds)))
          .get();

      // 5. 获取所有用户ID（包括创建者、更新者和成员）
      final userIds = {
        ...books.map((e) => e.createdBy),
        ...books.map((e) => e.updatedBy),
        ...allBookMembers.map((e) => e.userId),
      };

      // 6. 查询所有用户信息
      final userMap = CollectionUtils.toMap(
        await _userDao.findByIds(userIds.toList()),
        (e) => e.id,
      );

      // 7. 组装VO对象
      final result = books.map((book) {
        // 找到对应的权限记录
        final userBook = userBooks.firstWhere(
          (ub) => ub.accountBookId == book.id,
        );

        // 获取账本成员（排除创建者）
        final members = allBookMembers
            .where(
                (m) => m.accountBookId == book.id && m.userId != book.createdBy)
            .map((m) => BookMemberVO(
                  userId: m.userId,
                  nickname: userMap[m.userId]?.nickname,
                  permission: AccountBookPermissionVO.fromRelAccountbookUser(m),
                ))
            .toList();

        return UserBookVO.fromAccountBook(
          accountBook: book,
          permission: AccountBookPermissionVO.fromRelAccountbookUser(userBook),
          updatedByName: userMap[book.updatedBy]?.nickname,
          createdByName: userMap[book.createdBy]?.nickname,
          members: members,
        );
      }).toList();

      return OperateResult.success(result);
    } catch (e) {
      return OperateResult.failWithMessage('获取账本列表失败：$e', e as Exception);
    }
  }

  /// 检查账本名称是否重复
  /// [bookName] 账本名称
  /// [userId] 用户ID
  /// [bookId] 账本ID（更新时传入，新增时不传）
  Future<OperateResult<void>> checkBookName({
    required String bookName,
    required String userId,
    String? bookId,
  }) async {
    try {
      String checkUserId = userId;
      if (bookId != null) {
        // 1. 获取用户的所有账本
        final book = await _accountBookDao.findById(bookId);
        if (book != null) {
          checkUserId = book.createdBy;
        } else {
          return OperateResult.failWithMessage('账本不存在', null);
        }
      }

      final books = await _accountBookDao.findByCreatedBy(checkUserId);

      // 2. 检查是否存在同名账本（只检查当前用户创建的账本）
      final existingBook = books
          .where((book) =>
              book.name == bookName &&
              book.createdBy == userId &&
              (bookId == null || book.id != bookId))
          .toList();

      if (existingBook.isNotEmpty) {
        return OperateResult.failWithMessage('您已创建过同名账本', null);
      }
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage('检查账本名称失败：$e', e as Exception);
    }
  }

  Future<OperateResult<String>> createDefaultBook(
      String bookName, String userId) async {
    try {
      final bookId = generateUuid();
      await createAccountBook(
        accountBook: AccountBook(
          id: bookId,
          name: bookName,
          createdBy: userId,
          updatedBy: userId,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          currencySymbol: 'CNY',
          icon: null,
        ),
        userId: userId,
      );
      return OperateResult.success(bookId);
    } catch (e) {
      return OperateResult.failWithMessage('创建默认账本失败：$e', e as Exception);
    }
  }
}
