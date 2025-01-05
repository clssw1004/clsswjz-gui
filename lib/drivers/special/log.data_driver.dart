import 'dart:core';
import 'package:clsswjz/constants/symbol_type.dart';
import 'package:clsswjz/drivers/special/log/builder/book.builder.dart';
import 'package:clsswjz/drivers/special/log/builder/builder.dart';
import 'package:clsswjz/enums/fund_type.dart';
import 'package:clsswjz/models/vo/user_fund_vo.dart';
import '../../enums/business_type.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/book_member_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../enums/currency_symbol.dart';
import '../../models/common.dart';
import '../../utils/collection_util.dart';
import '../data_driver.dart';
import '../../constants/account_book_icons.dart';
import 'log/builder/book_category.builder.dart';
import 'log/builder/fund.builder.dart';
import 'log/builder/book_item.builder.dart';
import 'log/builder/book_member.builder.dart';
import 'log/builder/book_shop.builder.dart';
import 'log/builder/book_symbol.builder.dart';
import 'log/builder/fund_relation.builder.dart';

class LogDataDriver implements BookDataDriver {
  @override
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO> members = const []}) async {
    final bookId = await CreateBookLog.builder(userId,
            name: name,
            description: description,
            currencySymbol: currencySymbol ?? CurrencySymbol.cny,
            icon: icon ?? defaultIcon())
        .execute();

    await addBookMember(userId, bookId,
        userId: userId,
        canViewBook: true,
        canEditBook: true,
        canDeleteBook: true,
        canViewItem: true,
        canEditItem: true,
        canDeleteItem: true);
    for (var member in members) {
      await addBookMember(userId, bookId,
          userId: member.userId,
          canViewBook: member.permission.canViewBook,
          canEditBook: member.permission.canEditBook,
          canDeleteBook: member.permission.canDeleteBook,
          canViewItem: member.permission.canViewItem,
          canEditItem: member.permission.canEditItem,
          canDeleteItem: member.permission.canDeleteItem);
    }
    return OperateResult.success(bookId);
  }

  @override
  Future<OperateResult<void>> deleteBook(String userId, String bookId) async {
    await DeleteLog.buildBook(userId, bookId).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<UserBookVO>> getBook(String who, String bookId) async {
    return OperateResult.successIfNotNull(
        await ServiceManager.accountBookService.getAccountBook(who, bookId));
  }

  @override
  Future<OperateResult<List<UserBookVO>>> listBooksByUser(String userId) async {
    List<UserBookVO> books =
        await ServiceManager.accountBookService.getBooksByUserId(userId);
    return OperateResult.success(books);
  }

  @override
  Future<OperateResult<void>> updateBook(String who, String bookId,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      List<BookMemberVO> members = const []}) async {
    await UpdateBookLog.updateBook(who, bookId,
            name: name,
            description: description,
            currencySymbol: currencySymbol,
            icon: icon)
        .execute();
    final book = await getBook(who, bookId);
    final diff =
        CollectionUtil.diff(book.data?.members, members, (e) => e.userId);
    if (diff.added != null && diff.added!.isNotEmpty) {
      for (var member in diff.added!) {
        await addBookMember(who, bookId,
            userId: member.userId,
            canViewBook: member.permission.canViewBook,
            canEditBook: member.permission.canEditBook,
            canDeleteBook: member.permission.canDeleteBook,
            canViewItem: member.permission.canViewItem,
            canEditItem: member.permission.canEditItem,
            canDeleteItem: member.permission.canDeleteItem);
      }
    }
    if (diff.removed != null && diff.removed!.isNotEmpty) {
      for (var member in diff.removed!) {
        await deleteBookMember(who, member.id);
      }
    }

    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<String>> createBookItem(String who, String bookId,
      {required amount,
      String? description,
      required String type,
      String? categoryCode,
      required String accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode}) async {
    final id = await CreateBookItemLog.build(who, bookId,
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
      String who, String bookId, String itemId,
      {double? amount,
      String? description,
      String? type,
      String? categoryCode,
      String? accountDate,
      String? fundId,
      String? shopCode,
      String? tagCode,
      String? projectCode}) async {
    await UpdateBookItemLog.build(who, bookId, itemId,
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
  Future<OperateResult<String>> createBookCategory(String who, String bookId,
      {required String name, required String categoryType}) async {
    final id = await CreateBookCategoryLog.build(who, bookId,
            name: name, categoryType: categoryType)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateBookCategory(
      String who, String bookId, String categoryId,
      {String? name, DateTime? lastAccountItemAt}) async {
    await UpdateBookCategoryLog.build(who, bookId, categoryId,
            name: name, lastAccountItemAt: lastAccountItemAt)
        .execute();
    return OperateResult.success(null);
  }

  // 创建商家
  @override
  Future<OperateResult<String>> createBookShop(String who, String bookId,
      {required String name}) async {
    final id = await CreateBookShopLog.build(who, bookId, name: name).execute();
    return OperateResult.success(id);
  }

  // 更新商家
  @override
  Future<OperateResult<void>> updateBookShop(
      String who, String bookId, String shopId,
      {required String name}) async {
    await UpdateBookShopLog.build(who, bookId, shopId, name: name).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<String>> createBookSymbol(String who, String bookId,
      {required String name, required SymbolType symbolType}) async {
    final id = await CreateBookSymbolLog.build(who, bookId,
            name: name, symbolType: symbolType)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateBookSymbol(
      String who, String bookId, String tagId,
      {required String name}) async {
    await UpdateBookSymbolLog.build(who, bookId, tagId, name: name).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteBookCategory(
      String who, String bookId, String categoryId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.category, categoryId)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteBookItem(
      String who, String bookId, String itemId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.item, itemId)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteBookShop(
      String who, String bookId, String shopId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.shop, shopId)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteBookSymbol(
      String who, String bookId, String symbolId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.symbol, symbolId)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<String>> createFund(
    String who, {
    required String name,
    required FundType fundType,
    String? fundRemark,
    double? fundBalance,
    bool isDefault = false,
    List<FundBookVO>? relatedBooks = const [],
  }) async {
    final id = await CreateFundLog.build(who,
            name: name,
            fundType: fundType,
            fundRemark: fundRemark,
            fundBalance: fundBalance,
            isDefault: isDefault)
        .execute();
    if (relatedBooks != null) {
      for (var book in relatedBooks) {
        await createFundRelation(who, id, book.accountBookId,
            fundIn: book.fundIn, fundOut: book.fundOut);
      }
    }
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateFund(String who, String fundId,
      {String? name,
      FundType? fundType,
      double? fundBalance,
      String? fundRemark,
      List<FundBookVO>? relatedBooks = const []}) async {
    await UpdateFundLog.build(who, fundId,
            name: name,
            fundType: fundType,
            fundBalance: fundBalance,
            fundRemark: fundRemark)
        .execute();
    final fund = await ServiceManager.accountFundService.getFund(fundId);
    final diff = CollectionUtil.diff(
        fund.relatedBooks, relatedBooks ?? [], (e) => e.accountBookId);

    /// new relation
    if (diff.added != null && diff.added!.isNotEmpty) {
      for (var relation in diff.added!) {
        await createFundRelation(who, fundId, relation.accountBookId,
            fundIn: relation.fundIn, fundOut: relation.fundOut);
      }
    }

    /// update relation
    if (diff.updated != null && diff.updated!.isNotEmpty) {
      for (var relation in diff.updated!) {
        await updateFundRelation(who, relation.id,
            fundIn: relation.fundIn, fundOut: relation.fundOut);
      }
    }

    /// remove relation
    if (diff.removed != null && diff.removed!.isNotEmpty) {
      for (var relation in diff.removed!) {
        await deleteFundRelation(who, relation.id);
      }
    }

    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteFund(String who, String fundId) async {
    await DeleteLog.build(who, BusinessType.fund, fundId).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<UserFundVO>> getFund(
      String who, String bookId, String fundId) async {
    final fund = await ServiceManager.accountFundService.getFund(fundId);
    return OperateResult.success(fund);
  }

  Future<OperateResult<String>> createFundRelation(
    String who,
    String fundId,
    String accountBookId, {
    bool fundIn = true,
    bool fundOut = true,
    bool isDefault = false,
  }) async {
    final id = await CreateFundRelationLog.build(who, accountBookId, fundId,
            fundIn: fundIn, fundOut: fundOut)
        .execute();
    return OperateResult.success(id);
  }

  Future<OperateResult<void>> updateFundRelation(String who, String relationId,
      {bool? fundIn, bool? fundOut}) async {
    await UpdateFundRelationLog.build(who, relationId,
            fundIn: fundIn, fundOut: fundOut)
        .execute();
    return OperateResult.success(null);
  }

  Future<OperateResult<void>> deleteFundRelation(
      String who, String relationId) async {
    await DeleteLog.build(who, BusinessType.funBook, relationId).execute();
    return OperateResult.success(null);
  }

  Future<String> addBookMember(String who, String bookId,
      {required String userId,
      bool canViewBook = true,
      bool canEditBook = true,
      bool canDeleteBook = true,
      bool canViewItem = true,
      bool canEditItem = true,
      bool canDeleteItem = true}) async {
    final id = await CreateMemberLog.build(who, bookId,
            userId: userId,
            canViewBook: canViewBook,
            canEditBook: canEditBook,
            canDeleteBook: canDeleteBook,
            canViewItem: canViewItem,
            canEditItem: canEditItem,
            canDeleteItem: canDeleteItem)
        .execute();
    return id;
  }

  Future<void> updateBookMember(String who, String bookId,
      {bool? canViewBook,
      bool? canEditBook,
      bool? canDeleteBook,
      bool? canViewItem,
      bool? canEditItem,
      bool? canDeleteItem}) async {
    await UpdateMemberLog.build(who, bookId,
            canViewBook: canViewBook,
            canEditBook: canEditBook,
            canDeleteBook: canDeleteBook,
            canViewItem: canViewItem,
            canEditItem: canEditItem,
            canDeleteItem: canDeleteItem)
        .execute();
  }

  Future<void> deleteBookMember(String who, String memberId) async {
    await DeleteLog.build(who, BusinessType.bookMember, memberId).execute();
  }

  @override
  Future<OperateResult<List<UserFundVO>>> listFundsByUser(String userId) async {
    final funds =
        await ServiceManager.accountFundService.getFundsByUser(userId);
    return OperateResult.successIfNotNull(funds);
  }

  @override
  Future<OperateResult<UserFundVO>> listFundsByBook(
      String userId, String bookId) {
    // TODO: implement listFundsByBook
    throw UnimplementedError();
  }
}
