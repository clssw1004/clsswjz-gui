import 'dart:core';
import 'dart:io';
import 'package:clsswjz/constants/symbol_type.dart';
import 'package:clsswjz/drivers/special/log/builder/attachment.builder.dart';
import 'package:clsswjz/drivers/special/log/builder/book.builder.dart';
import 'package:clsswjz/drivers/special/log/builder/builder.dart';
import 'package:clsswjz/enums/fund_type.dart';
import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:clsswjz/models/vo/user_fund_vo.dart';
import '../../constants/default_book_values.constant.dart';
import '../../enums/business_type.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/attachment_vo.dart';
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

class LogDataDriver implements BookDataDriver {
  @override
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      String? defaultFundName,
      String? defaultCategoryName,
      String? defaultShopName,
      List<BookMemberVO> members = const []}) async {
    final bookId = await BookCULog.create(userId,
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
    await initDefaultBookData(userId, bookId);
    return OperateResult.success(bookId);
  }

  Future<void> initDefaultBookData(String userId, String bookId) async {
    DefaultBookData defaultData =
        getDefaultDataByLocale(AppConfigManager.instance.locale);
    if (defaultData.category.isNotEmpty) {
      for (var category in defaultData.category) {
        await createBookCategory(userId, bookId,
            name: category.name, categoryType: category.categoryType.code);
      }
    }
    if (defaultData.shop.isNotEmpty) {
      for (var shop in defaultData.shop) {
        await createBookShop(userId, bookId, name: shop);
      }
    }
    if (defaultData.symbols.isNotEmpty) {
      for (var symbol in defaultData.symbols) {
        await createBookSymbol(userId, bookId,
            name: symbol.name, symbolType: symbol.symbolType);
      }
    }
    if (defaultData.funds.isNotEmpty) {
      for (var fund in defaultData.funds) {
        await createFund(userId, bookId,
            name: fund.name, fundType: fund.fundType);
      }
    }
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
    await BookCULog.update(who, bookId,
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
        await deleteBookMember(who, bookId, member.id);
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
      String? projectCode,
      List<File>? files}) async {
    final id = await ItemCULog.create(who, bookId,
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
    if (files != null && files!.isNotEmpty) {
      for (var file in files!) {
        await AttachmentCULog.fromFile(who,
                belongType: BusinessType.item, belongId: id, file: file)
            .execute();
      }
    }
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
      String? projectCode,
      List<AttachmentVO>? attachments}) async {
    await ItemCULog.update(who, bookId, itemId,
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
    final oldAttachments = await ServiceManager.attachmentService
        .getAttachmentsByBusiness(BusinessType.item, itemId);
    final diff = CollectionUtil.diff(oldAttachments, attachments, (e) => e.id);
    if (diff.added != null && diff.added!.isNotEmpty) {
      for (var attachment in diff.added!) {
        await AttachmentCULog.fromVO(who,
                belongType: BusinessType.item, belongId: itemId, vo: attachment)
            .execute();
      }
    }
    if (diff.removed != null && diff.removed!.isNotEmpty) {
      for (var attachment in diff.removed!) {
        await AttachmentDeleteLog.fromAttachmentId(who,
                belongType: BusinessType.item,
                belongId: itemId,
                attachmentId: attachment.id)
            .execute();
      }
    }
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<String>> createBookCategory(String who, String bookId,
      {required String name, required String categoryType}) async {
    final id = await CategoryCULog.create(who, bookId,
            name: name, categoryType: categoryType)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateBookCategory(
      String who, String bookId, String categoryId,
      {String? name, DateTime? lastAccountItemAt}) async {
    await CategoryCULog.update(who, bookId, categoryId,
            name: name, lastAccountItemAt: lastAccountItemAt)
        .execute();
    return OperateResult.success(null);
  }

  // 创建商家
  @override
  Future<OperateResult<String>> createBookShop(String who, String bookId,
      {required String name}) async {
    final id = await ShopCULog.create(who, bookId, name: name).execute();
    return OperateResult.success(id);
  }

  // 更新商家
  @override
  Future<OperateResult<void>> updateBookShop(
      String who, String bookId, String shopId,
      {required String name}) async {
    await ShopCULog.update(who, bookId, shopId, name: name).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<String>> createBookSymbol(String who, String bookId,
      {required String name, required SymbolType symbolType}) async {
    final id = await SymbolCULog.create(who, bookId,
            name: name, symbolType: symbolType)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateBookSymbol(
      String who, String bookId, String tagId,
      {required String name}) async {
    await SymbolCULog.update(who, bookId, tagId, name: name).execute();
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
    String who,
    String bookId, {
    required String name,
    required FundType fundType,
    String? fundRemark,
    double? fundBalance,
    bool isDefault = false,
  }) async {
    final id = await FundCULog.create(who, bookId,
            name: name,
            fundType: fundType,
            fundRemark: fundRemark,
            fundBalance: fundBalance,
            isDefault: isDefault)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateFund(
    String who,
    String bookId,
    String fundId, {
    String? name,
    FundType? fundType,
    double? fundBalance,
    String? fundRemark,
  }) async {
    await FundCULog.update(who, bookId, fundId,
            name: name,
            fundType: fundType,
            fundBalance: fundBalance,
            fundRemark: fundRemark)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteFund(
      String who, String bookId, String fundId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.fund, fundId)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<UserFundVO>> getFund(
      String who, String bookId, String fundId) async {
    final fund = await ServiceManager.accountFundService.getFund(fundId);
    return OperateResult.success(fund);
  }

  Future<String> addBookMember(String who, String bookId,
      {required String userId,
      bool canViewBook = true,
      bool canEditBook = true,
      bool canDeleteBook = true,
      bool canViewItem = true,
      bool canEditItem = true,
      bool canDeleteItem = true}) async {
    final id = await MemberCULog.create(who, bookId,
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

  Future<void> updateBookMember(String who, String bookId, String memberId,
      {bool? canViewBook,
      bool? canEditBook,
      bool? canDeleteBook,
      bool? canViewItem,
      bool? canEditItem,
      bool? canDeleteItem}) async {
    await MemberCULog.update(who, bookId, memberId,
            canViewBook: canViewBook,
            canEditBook: canEditBook,
            canDeleteBook: canDeleteBook,
            canViewItem: canViewItem,
            canEditItem: canEditItem,
            canDeleteItem: canDeleteItem)
        .execute();
  }

  Future<void> deleteBookMember(
      String who, String bookId, String memberId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.bookMember, memberId)
        .execute();
  }

  @override
  Future<OperateResult<List<UserFundVO>>> listFundsByBook(
      String userId, String bookId) async {
    final funds =
        await ServiceManager.accountFundService.getFundsByBook(bookId);
    return OperateResult.successIfNotNull(funds);
  }
}
