import 'package:clsswjz/constants/symbol_type.dart';
import 'package:clsswjz/models/vo/user_book_vo.dart';
import '../enums/currency_symbol.dart';
import '../enums/fund_type.dart';
import '../models/common.dart';
import '../models/vo/book_member_vo.dart';
import '../models/vo/user_fund_vo.dart';

abstract class BookDataDriver {
  /// 账本相关
  /// 创建账本
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO> members = const []});

  /// 更新账本
  Future<OperateResult<void>> updateBook(String userId, String bookId,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO> members = const []});

  /// 删除账本
  Future<OperateResult<void>> deleteBook(String userId, String bookId);

  /// 获取账本
  Future<OperateResult<UserBookVO>> getBook(String userId, String bookId);

  /// 获取用户账本列表
  Future<OperateResult<List<UserBookVO>>> listBooksByUser(String userId);

  /// 账目相关
  /// 创建账目
  Future<OperateResult<String>> createBookItem(String userId, String bookId,
      {required amount,
      String? description,
      required String type,
      String? categoryCode,
      required String accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode});

  /// 更新账目
  Future<OperateResult<void>> updateBookItem(
      String userId, String bookId, String itemId,
      {double? amount,
      String? description,
      String? type,
      String? categoryCode,
      String? accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode});

  /// 删除账目
  Future<OperateResult<void>> deleteBookItem(
      String userId, String bookId, String itemId);

  /// 分类相关
  /// 创建分类
  Future<OperateResult<String>> createBookCategory(String userId, String bookId,
      {required String name, required String categoryType});

  /// 更新分类
  Future<OperateResult<void>> updateBookCategory(
      String userId, String bookId, String categoryId,
      {String? name, DateTime? lastAccountItemAt});

  /// 删除分类
  Future<OperateResult<void>> deleteBookCategory(
      String userId, String bookId, String categoryId);

  /// 商家相关
  /// 创建商家
  Future<OperateResult<String>> createBookShop(String userId, String bookId,
      {required String name});

  /// 更新商家
  Future<OperateResult<void>> updateBookShop(
      String userId, String bookId, String shopId,
      {required String name});

  /// 删除商家
  Future<OperateResult<void>> deleteBookShop(
      String userId, String bookId, String shopId);

  /// 其它账本标识
  /// 创建账本标识
  Future<OperateResult<String>> createBookSymbol(String userId, String bookId,
      {required String name, required SymbolType symbolType});

  /// 更新账本标识
  Future<OperateResult<void>> updateBookSymbol(
      String userId, String bookId, String tagId,
      {required String name});

  /// 删除账本标识
  Future<OperateResult<void>> deleteBookSymbol(
      String userId, String bookId, String symbolId);

  /// 账本资金相关
  /// 获取账本资金
  Future<OperateResult<UserFundVO>> getFund(
      String userId, String bookId, String fundId);

  /// 创建账本资金
  Future<OperateResult<String>> createFund(
    String userId, {
    required String name,
    required FundType fundType,
    String? fundRemark,
    double? fundBalance,
    List<FundBookVO>? relatedBooks = const [],
  });

  /// 更新账本资金
  Future<OperateResult<void>> updateFund(String userId, String fundId,
      {String? name,
      FundType? fundType,
      double? fundBalance,
      String? fundRemark,
      List<FundBookVO>? relatedBooks = const []});

  /// 删除账本资金
  Future<OperateResult<void>> deleteFund(String userId, String fundId);
}
