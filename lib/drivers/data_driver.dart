import 'dart:io';

import '../database/database.dart';
import '../enums/account_type.dart';
import '../enums/currency_symbol.dart';
import '../enums/debt_clear_state.dart';
import '../enums/debt_type.dart';
import '../enums/fund_type.dart';
import '../enums/note_type.dart';
import '../enums/symbol_type.dart';
import '../models/common.dart';
import '../models/dto/item_filter_dto.dart';
import '../models/vo/user_book_vo.dart';
import '../models/vo/user_debt_vo.dart';
import '../models/vo/user_item_vo.dart';
import '../models/vo/attachment_vo.dart';
import '../models/vo/user_fund_vo.dart';
import '../models/vo/user_vo.dart';
import '../models/vo/user_note_vo.dart';

abstract class BookDataDriver {
  /// 用户相关
  /// 注册用户
  Future<OperateResult<String>> register({
    String? userId,
    required String username,
    required String password,
    required String nickname,
    String? email,
    String? phone,
    String? language,
    String? timezone,
    String? avatar,
  });

  /// 更新用户信息
  Future<OperateResult<void>> updateUser(
    String userId, {
    String? oldPassword,
    String? newPassword,
    String? nickname,
    String? email,
    String? phone,
    String? language,
    String? timezone,
    File? avatar,
  });

  /// 获取用户信息
  Future<OperateResult<UserVO>> getUserInfo(String id);

  /// 账本相关
  /// 创建账本
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      String? defaultFundId,
      String? defaultFundName,
      String? defaultCategoryName,
      String? defaultShopName,
      List<BookMemberVO> members = const []});

  /// 删除账本
  Future<OperateResult<void>> deleteBook(String userId, String bookId);

  /// 更新账本
  Future<OperateResult<void>> updateBook(String userId, String bookId,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      String? defaultFundId,
      List<BookMemberVO> members = const []});

  /// 获取账本
  Future<OperateResult<UserBookVO>> getBook(String userId, String bookId);

  /// 获取用户账本列表
  Future<OperateResult<List<UserBookVO>>> listBooksByUser(String userId);

  /// 账目相关
  /// 创建账目
  Future<OperateResult<String>> createItem(String userId, String bookId,
      {required double amount,
      String? description,
      required AccountItemType type,
      String? categoryCode,
      required String accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode,
      String? source,
      String? sourceId,
      List<File>? files});

  /// 删除账目
  Future<OperateResult<void>> deleteItem(
      String userId, String bookId, String itemId);

  /// 更新账目
  Future<OperateResult<void>> updateItem(
    String userId,
    String bookId,
    String itemId, {
    double? amount,
    String? description,
    AccountItemType? type,
    String? categoryCode,
    String? accountDate,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    List<AttachmentVO>? attachments,
  });

  /// 获取账本账目列表
  Future<OperateResult<List<UserItemVO>>> listItemsByBook(
      String userId, String bookId,
      {int limit = 200, int offset = 0, ItemFilterDTO? filter});

  /// 分类相关
  /// 创建分类
  Future<OperateResult<String>> createCategory(String userId, String bookId,
      {required String name, required String categoryType});

  /// 删除分类
  Future<OperateResult<void>> deleteCategory(
      String userId, String bookId, String categoryId);

  /// 更新分类
  Future<OperateResult<void>> updateCategory(
      String userId, String bookId, String categoryId,
      {String? name, String? lastAccountItemAt});

  /// 获取账本分类列表
  Future<OperateResult<List<AccountCategory>>> listCategoriesByBook(
      String userId, String bookId,
      {String? categoryType});

  /// 商家相关
  /// 创建商家
  Future<OperateResult<String>> createShop(String userId, String bookId,
      {required String name});

  /// 删除商家
  Future<OperateResult<void>> deleteShop(
      String userId, String bookId, String shopId);

  /// 更新商家
  Future<OperateResult<void>> updateShop(
      String userId, String bookId, String shopId,
      {String? name, String? lastAccountItemAt});

  /// 获取账本商家列表
  Future<OperateResult<List<AccountShop>>> listShopsByBook(
      String userId, String bookId);

  /// 其它账本标识
  /// 创建账本标识
  Future<OperateResult<String>> createSymbol(String userId, String bookId,
      {required String name, required SymbolType symbolType});

  /// 删除账本标识
  Future<OperateResult<void>> deleteSymbol(
      String userId, String bookId, String symbolId);

  /// 更新账本标识
  Future<OperateResult<void>> updateSymbol(
      String userId, String bookId, String tagId,
      {String? name, String? lastAccountItemAt});

  /// 获取账本标识列表
  Future<OperateResult<List<AccountSymbol>>> listSymbolsByBook(
      String userId, String bookId,
      {SymbolType? symbolType});

  /// 账本资金相关
  /// 创建账本资金
  Future<OperateResult<String>> createFund(
    String userId,
    String bookId, {
    required String name,
    required FundType fundType,
    String? fundRemark,
    double? fundBalance,
    bool isDefault = false,
  });

  /// 删除账本资金
  Future<OperateResult<void>> deleteFund(
      String userId, String bookId, String fundId);

  /// 更新账本资金
  Future<OperateResult<void>> updateFund(
      String userId, String bookId, String fundId,
      {String? name,
      FundType? fundType,
      double? fundBalance,
      String? fundRemark,
      String? lastAccountItemAt});

  /// 获取账本资金
  Future<OperateResult<UserFundVO>> getFund(
      String userId, String bookId, String fundId);

  /// 获取账本资金列表
  Future<OperateResult<List<UserFundVO>>> listFundsByBook(
      String userId, String bookId);

  /// 记事相关
  /// 创建记事
  Future<OperateResult<String>> createNote(String who, String bookId,
      {String? title,
      required NoteType noteType,
      required String content,
      required String plainContent,
      List<File>? files});

  /// 删除记事
  Future<OperateResult<void>> deleteNote(
      String who, String bookId, String noteId);

  /// 更新记事
  Future<OperateResult<void>> updateNote(
      String who, String bookId, String noteId,
      {String? title, String? content, String? plainContent,List<AttachmentVO>? attachments});

  /// 获取用户记事列表
  Future<OperateResult<List<UserNoteVO>>> listNotesByBook(
      String who, String bookId,
      {int limit = 200, int offset = 0, String? keyword});

  /// 债务相关
  /// 创建债务
  Future<OperateResult<String>> createDebt(String userId, String bookId,
      {required String debtor,
      required DebtType debtType,
      required double amount,
      required String fundId,
      required String debtDate,
      String? expectedClearDate,
      DebtClearState? clearState});

  /// 删除债务
  Future<OperateResult<void>> deleteDebt(
      String userId, String bookId, String debtId);

  /// 更新债务
  Future<OperateResult<void>> updateDebt(
      String userId, String bookId, String debtId,
      {String? debtor,
      double? amount,
      String? fundId,
      String? debtDate,
      String? expectedClearDate,
      String? clearDate,
      DebtClearState? clearState});

  /// 获取债务列表
  Future<OperateResult<List<UserDebtVO>>> listDebtsByBook(
      String userId, String bookId,
      {int limit = 200, int offset = 0, String? keyword});
}
