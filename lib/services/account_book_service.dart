import 'package:clsswjz/utils/collection_util.dart';
import 'package:drift/drift.dart';
import '../database/dao/account_book_dao.dart';
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
      return OperateResult.failWithMessage('创建账本失败：$e', e as Exception);
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
        return OperateResult.failWithMessage('账本不存在', null);
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

  /// 获取用户的账本列表
  Future<OperateResult<List<AccountBook>>> getUserAccountBooks(
      String userId) async {
    try {
      final books = await _accountBookDao.findByUserId(userId);
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

        // 获取账本成员（排除创���者）
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
}
