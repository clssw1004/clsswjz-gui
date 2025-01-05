import 'package:clsswjz/constants/symbol_type.dart';
import 'package:clsswjz/drivers/special/log/builder/book.builder.dart';
import 'package:clsswjz/drivers/special/log/builder/builder.dart';

import '../../manager/service_manager.dart';
import '../../models/vo/book_member_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../enums/currency_symbol.dart';
import '../../models/common.dart';
import '../book_data_driver.dart';
import '../../constants/account_book_icons.dart';
import 'log/builder/book_category.builder.dart';
import 'log/builder/book_item.builder.dart';
import 'log/builder/book_member.builder.dart';
import 'log/builder/book_shop.builder.dart';
import 'log/builder/book_symbol.builder.dart';

class LogDataDriver implements BookDataDriver {
  @override
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO> members = const []}) async {
    final id = await CreateBookLog.builder(userId,
            name: name,
            description: description,
            currencySymbol: currencySymbol ?? CurrencySymbol.cny,
            icon: icon ?? defaultIcon())
        .execute();

    await CreateMemberLog.builder(userId,
            accountBookId: id,
            userId: userId,
            canViewBook: true,
            canEditBook: true,
            canDeleteBook: true,
            canViewItem: true,
            canEditItem: true,
            canDeleteItem: true)
        .execute();
    for (var member in members) {
      await CreateMemberLog.builder(userId,
              accountBookId: id,
              userId: member.userId,
              canViewBook: member.permission.canViewBook,
              canEditBook: member.permission.canEditBook,
              canDeleteBook: member.permission.canDeleteBook,
              canViewItem: member.permission.canViewItem,
              canEditItem: member.permission.canEditItem,
              canDeleteItem: member.permission.canDeleteItem)
          .execute();
    }
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> deleteBook(String userId, String bookId) async {
    await DeleteLog.builderBook(userId, bookId).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<UserBookVO>> getBook(String userId, String bookId) {
    throw UnimplementedError();
  }

  @override
  Future<OperateResult<List<UserBookVO>>> listBooksByUser(String userId) async {
    List<UserBookVO> books =
        await ServiceManager.accountBookService.getBooksByUserId(userId);
    return OperateResult.success(books);
  }

  @override
  Future<OperateResult<void>> updateBook(String userId, String bookId,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO> members = const []}) async {
    await UpdateBookLog.updateBook(userId, bookId,
            name: name,
            description: description,
            currencySymbol: currencySymbol,
            icon: icon)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<String>> createBookItem(String userId, String bookId,
      {required amount,
      String? description,
      required String type,
      String? categoryCode,
      required String accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode}) async {
    final id = await CreateBookItemLog.build(userId, bookId,
            amount: amount,
            description: description,
            type: type,
            categoryCode: categoryCode,
            accountDate: accountDate,
            fundId: fundId,
            shopCode: shopCode,
            tagCode: tagCode,
            projectCode: projectCode)
        .execute();
    return OperateResult.success(id);
  }

  @override
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
      String? projectCode}) async {
    await UpdateBookItemLog.build(userId, bookId, itemId,
            amount: amount,
            description: description,
            type: type,
            categoryCode: categoryCode,
            accountDate: accountDate,
            fundId: fundId,
            shopCode: shopCode,
            tagCode: tagCode,
            projectCode: projectCode)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<String>> createBookCategory(String userId, String bookId,
      {required String name, required String categoryType}) async {
    final id = await CreateBookCategoryLog.build(userId, bookId,
            name: name, categoryType: categoryType)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateBookCategory(
      String userId, String bookId, String categoryId,
      {String? name, DateTime? lastAccountItemAt}) async {
    await UpdateBookCategoryLog.build(userId, bookId, categoryId,
            name: name, lastAccountItemAt: lastAccountItemAt)
        .execute();
    return OperateResult.success(null);
  }

  // 创建商家
  @override
  Future<OperateResult<String>> createBookShop(String userId, String bookId,
      {required String name}) async {
    final id =
        await CreateBookShopLog.build(userId, bookId, name: name).execute();
    return OperateResult.success(id);
  }

  // 更新商家
  @override
  Future<OperateResult<void>> updateBookShop(
      String userId, String bookId, String shopId,
      {required String name}) async {
    await UpdateBookShopLog.build(userId, bookId, shopId, name: name).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<String>> createBookSymbol(String userId, String bookId,
      {required String name, required SymbolType symbolType}) async {
    final id = await CreateBookSymbolLog.build(userId, bookId,
            name: name, symbolType: symbolType)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateBookSymbol(
      String userId, String bookId, String tagId,
      {required String name}) async {
    await UpdateBookSymbolLog.build(userId, bookId, tagId, name: name)
        .execute();
    return OperateResult.success(null);
  }
}
