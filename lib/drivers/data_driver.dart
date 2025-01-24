import 'dart:io';

import 'package:clsswjz/enums/symbol_type.dart';
import 'package:clsswjz/models/vo/user_book_vo.dart';
import '../database/database.dart';
import '../enums/currency_symbol.dart';
import '../enums/fund_type.dart';
import '../models/common.dart';
import '../models/vo/user_item_vo.dart';
import '../models/vo/attachment_vo.dart';
import '../models/vo/user_fund_vo.dart';
import '../models/vo/user_vo.dart';
import '../models/vo/user_note_vo.dart';

abstract class BookDataDriver {
  /// 账本相关
  /// 创建账本
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      String? defaultFundName,
      String? defaultCategoryName,
      String? defaultShopName,
      List<BookMemberVO> members = const []});

  /// 更新账本
  Future<OperateResult<void>> updateBook(String userId, String bookId,
      {String? name, String? description, CurrencySymbol? currencySymbol, String? icon, List<BookMemberVO> members = const []});

  /// 删除账本
  Future<OperateResult<void>> deleteBook(String userId, String bookId);

  /// 获取账本
  Future<OperateResult<UserBookVO>> getBook(String userId, String bookId);

  /// 获取用户账本列表
  Future<OperateResult<List<UserBookVO>>> listBooksByUser(String userId);

  /// 获取账本账目列表
  Future<OperateResult<List<UserItemVO>>> listItemsByBook(String userId, String bookId, {int limit = 200, int offset = 0});

  /// 账目相关
  /// 创建账目
  Future<OperateResult<String>> createItem(String userId, String bookId,
      {required double amount,
      String? description,
      required String type,
      String? categoryCode,
      required String accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode,
      List<File>? files});

  /// 更新账目
  Future<OperateResult<void>> updateItem(
    String userId,
    String bookId,
    String itemId, {
    double? amount,
    String? description,
    String? type,
    String? categoryCode,
    String? accountDate,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    List<AttachmentVO>? attachments,
  });

  /// 删除账目
  Future<OperateResult<void>> deleteItem(String userId, String bookId, String itemId);

  /// 分类相关
  /// 获取账本分类列表
  Future<OperateResult<List<AccountCategory>>> listCategoriesByBook(String userId, String bookId, {String? categoryType});

  /// 创建分类
  Future<OperateResult<String>> createCategory(String userId, String bookId, {required String name, required String categoryType});

  /// 更新分类
  Future<OperateResult<void>> updateCategory(String userId, String bookId, String categoryId, {String? name, DateTime? lastAccountItemAt});

  /// 删除分类
  Future<OperateResult<void>> deleteCategory(String userId, String bookId, String categoryId);

  /// 商家相关
  /// 获取账本商家列表
  Future<OperateResult<List<AccountShop>>> listShopsByBook(String userId, String bookId);

  /// 创建商家
  Future<OperateResult<String>> createShop(String userId, String bookId, {required String name});

  /// 更新商家
  Future<OperateResult<void>> updateShop(String userId, String bookId, String shopId, {required String name});

  /// 删除商家
  Future<OperateResult<void>> deleteShop(String userId, String bookId, String shopId);

  /// 其它账本标识
  /// 获取账本标识列表
  Future<OperateResult<List<AccountSymbol>>> listSymbolsByBook(String userId, String bookId, {SymbolType? symbolType});

  /// 创建账本标识
  Future<OperateResult<String>> createSymbol(String userId, String bookId, {required String name, required SymbolType symbolType});

  /// 更新账本标识
  Future<OperateResult<void>> updateSymbol(String userId, String bookId, String tagId, {required String name});

  /// 删除账本标识
  Future<OperateResult<void>> deleteSymbol(String userId, String bookId, String symbolId);

  /// 账本资金相关
  /// 获取账本资金列表
  Future<OperateResult<List<UserFundVO>>> listFundsByBook(String userId, String bookId);

  /// 获取账本资金
  Future<OperateResult<UserFundVO>> getFund(String userId, String bookId, String fundId);

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

  /// 更新账本资金
  Future<OperateResult<void>> updateFund(String userId, String bookId, String fundId,
      {String? name, FundType? fundType, double? fundBalance, String? fundRemark});

  /// 删除账本资金
  Future<OperateResult<void>> deleteFund(String userId, String bookId, String fundId);

  /// 用户相关
  Future<OperateResult<UserVO>> getUserInfo(String id);

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

  /// 记事相关
  /// 获取用户记事列表
  Future<OperateResult<List<UserNoteVO>>> listNotesByBook(String who, String bookId, {int limit = 200, int offset = 0});

  Future<OperateResult<String>> createNote(String who, String bookId, {String? title, required String content});

  Future<OperateResult<void>> deleteNote(String who, String bookId, String noteId);

  Future<OperateResult<void>> updateNote(String who, String bookId, String noteId, {String? title, String? content});
}
