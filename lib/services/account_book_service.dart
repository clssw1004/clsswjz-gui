import 'package:clsswjz/manager/dao_manager.dart';
import 'package:clsswjz/utils/collection_util.dart';
import '../database/dao/account_book_dao.dart';
import '../database/dao/user_dao.dart';
import '../database/database.dart';
import '../manager/database_manager.dart';
import '../models/common.dart';
import '../models/vo/account_book_permission_vo.dart';
import '../models/vo/book_member_vo.dart';
import '../models/vo/book_meta.dart';
import '../models/vo/user_book_vo.dart';
import '../utils/id_util.dart';
import 'base_service.dart';

class AccountBookService extends BaseService {
  final AccountBookDao _accountBookDao;
  final UserDao _userDao;

  AccountBookService()
      : _accountBookDao = AccountBookDao(DatabaseManager.db),
        _userDao = UserDao(DatabaseManager.db);

  /// 获取账本信息
  Future<BookMetaVO?> getBookMeta(String userId, String bookId) async {
    UserBookVO? userBook = await getAccountBook(userId, bookId);
    if (userBook == null) {
      return null;
    }

    List<AccountFund> funds = await DaoManager.accountFundDao.findByAccountBookId(bookId);
    List<AccountCategory> categories = await DaoManager.accountCategoryDao.findByAccountBookId(bookId);
    List<AccountSymbol> symbols = await DaoManager.accountSymbolDao.findByAccountBookId(bookId);
    List<AccountShop> shops = await DaoManager.accountShopDao.findByAccountBookId(bookId);

    return BookMetaVO(
      bookInfo: userBook,
      funds: funds,
      categories: categories,
      symbols: symbols,
      shops: shops,
    );
  }

  /// 获取账本信息
  Future<UserBookVO?> getAccountBook(String userId, String bookId) async {
    // 1. 从关联表中查询用户的账本权限
    final userBooks = await (db.select(db.relAccountbookUserTable)..where((tbl) => tbl.accountBookId.equals(bookId))).get();

    if (userBooks.isEmpty) {
      return null;
    }

    final book = await _accountBookDao.findById(bookId);
    if (book == null) {
      return null;
    }

    final userIds = userBooks.map((e) => e.userId).toList();

    final userMap = CollectionUtil.toMap(
      await _userDao.findByIds(userIds.toList()),
      (e) => e.id,
    );

    final userBook = userBooks.firstWhere(
      (ub) => ub.userId == book.createdBy,
    );

    final members = userBooks
        .where((m) => m.accountBookId == book.id && m.userId != book.createdBy)
        .map((m) => BookMemberVO(
              id: m.id,
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
  }

  /// 根据邀请码生成默认成员
  Future<OperateResult<BookMemberVO>> gernerateDefaultMemberByInviteCode(String inviteCode) async {
    final user = await _userDao.findByInviteCode(inviteCode);
    if (user == null) {
      return OperateResult.failWithMessage(message: '用户不存在');
    }

    return OperateResult.success(BookMemberVO(
      id: IdUtil.genId(),
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

  /// 获取用户的账本列表及权限
  Future<List<UserBookVO>> getBooksByUserId(String userId) async {
    // 1. 从关联表中查询用户的账本权限
    final userBooks = await (db.select(db.relAccountbookUserTable)..where((tbl) => tbl.userId.equals(userId))).get();

    if (userBooks.isEmpty) {
      return [];
    }

    // 2. 获取所有账本ID
    final bookIds = userBooks.map((e) => e.accountBookId).toList();

    // 3. 查询账本详细信息
    final books = await _accountBookDao.findByIds(bookIds);

    // 4. 查询所有账本的成员关系
    final allBookMembers = await (db.select(db.relAccountbookUserTable)..where((tbl) => tbl.accountBookId.isIn(bookIds))).get();

    // 5. 获取所有用户ID（包括创建者、更新者和成员）
    final userIds = {
      ...books.map((e) => e.createdBy),
      ...books.map((e) => e.updatedBy),
      ...allBookMembers.map((e) => e.userId),
    };

    // 6. 查询所有用户信息
    final userMap = CollectionUtil.toMap(
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
          .where((m) => m.accountBookId == book.id && m.userId != book.createdBy)
          .map((m) => BookMemberVO(
                id: m.id,
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

    return result;
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
          return OperateResult.failWithMessage(message: '账本不存在');
        }
      }

      final books = await _accountBookDao.findByCreatedBy(checkUserId);

      // 2. 检查是否存在同名账本（只检查当前用户创建的账本）
      final existingBook =
          books.where((book) => book.name == bookName && book.createdBy == userId && (bookId == null || book.id != bookId)).toList();

      if (existingBook.isNotEmpty) {
        return OperateResult.failWithMessage(message: '您已创建过同名账本');
      }
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(message: '检查账本名称失败：$e', exception: e as Exception);
    }
  }
}
