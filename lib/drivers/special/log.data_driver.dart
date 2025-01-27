import 'dart:core';
import 'dart:io';
import 'package:clsswjz/database/database.dart';
import 'package:clsswjz/drivers/special/log/builder/book_note.build.dart';
import 'package:clsswjz/drivers/special/log/builder/user.builder.dart';
import 'package:clsswjz/drivers/vo_transfer.dart';
import 'package:clsswjz/enums/symbol_type.dart';
import 'package:clsswjz/drivers/special/log/builder/attachment.builder.dart';
import 'package:clsswjz/drivers/special/log/builder/book.builder.dart';
import 'package:clsswjz/drivers/special/log/builder/builder.dart';
import 'package:clsswjz/enums/fund_type.dart';
import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import 'package:clsswjz/models/vo/user_fund_vo.dart';
import 'package:clsswjz/models/vo/user_note_vo.dart';
import 'package:clsswjz/utils/digest_util.dart';
import '../../constants/constant.dart';
import '../../constants/default_book_values.constant.dart';
import '../../enums/business_type.dart';
import '../../manager/service_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/attachment_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../enums/currency_symbol.dart';
import '../../models/common.dart';
import '../../models/vo/user_vo.dart';
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
            name: name, description: description, currencySymbol: currencySymbol ?? CurrencySymbol.cny, icon: icon ?? defaultIcon())
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
    DefaultBookData defaultData = getDefaultDataByLocale(AppConfigManager.instance.locale);
    if (defaultData.category.isNotEmpty) {
      for (var category in defaultData.category) {
        await createCategory(userId, bookId, name: category.name, categoryType: category.categoryType.code);
      }
    }
    if (defaultData.shop.isNotEmpty) {
      for (var shop in defaultData.shop) {
        await createShop(userId, bookId, name: shop);
      }
    }
    if (defaultData.symbols.isNotEmpty) {
      for (var symbol in defaultData.symbols) {
        await createSymbol(userId, bookId, name: symbol.name, symbolType: symbol.symbolType);
      }
    }
    if (defaultData.funds.isNotEmpty) {
      for (var fund in defaultData.funds) {
        await createFund(userId, bookId, name: fund.name, fundType: fund.fundType);
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
    return OperateResult.successIfNotNull(await ServiceManager.accountBookService.getAccountBook(who, bookId));
  }

  @override
  Future<OperateResult<List<UserBookVO>>> listBooksByUser(String userId) async {
    List<UserBookVO> books = await ServiceManager.accountBookService.getBooksByUserId(userId);
    return OperateResult.success(books);
  }

  @override
  Future<OperateResult<void>> updateBook(String who, String bookId,
      {String? name, String? description, CurrencySymbol? currencySymbol, String? icon, List<BookMemberVO> members = const []}) async {
    await BookCULog.update(who, bookId, name: name, description: description, currencySymbol: currencySymbol, icon: icon).execute();
    final book = await getBook(who, bookId);
    final diff = CollectionUtil.diff(book.data?.members, members, (e) => e.userId);
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
  Future<OperateResult<List<UserItemVO>>> listItemsByBook(String userId, String bookId,
      {int limit = 20, int offset = 0, ItemFilterDTO? filter}) async {
    final items = await DaoManager.itemDao.listByBook(bookId, limit: limit, offset: offset, filter: filter);
    return OperateResult.success(await VOTransfer.transferAccountItem(items));
  }

  @override
  Future<OperateResult<String>> createItem(String who, String bookId,
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
    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        await AttachmentCULog.fromFile(who, belongType: BusinessType.item, belongId: id, file: file).execute();
      }
    }
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateItem(String who, String bookId, String itemId,
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
    final oldAttachments = await ServiceManager.attachmentService.getAttachmentsByBusiness(BusinessType.item, itemId);
    final diff = CollectionUtil.diff(oldAttachments, attachments, (e) => e.id);
    if (diff.added != null && diff.added!.isNotEmpty) {
      for (var attachment in diff.added!) {
        await AttachmentCULog.fromVO(who, belongType: BusinessType.item, belongId: itemId, vo: attachment).execute();
      }
    }
    if (diff.removed != null && diff.removed!.isNotEmpty) {
      for (var attachment in diff.removed!) {
        await AttachmentDeleteLog.fromAttachmentId(who, belongType: BusinessType.item, belongId: itemId, attachmentId: attachment.id)
            .execute();
      }
    }
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<String>> createCategory(String who, String bookId, {required String name, required String categoryType}) async {
    final id = await CategoryCULog.create(who, bookId, name: name, categoryType: categoryType).execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateCategory(String who, String bookId, String categoryId,
      {String? name, DateTime? lastAccountItemAt}) async {
    await CategoryCULog.update(who, bookId, categoryId, name: name, lastAccountItemAt: lastAccountItemAt).execute();
    return OperateResult.success(null);
  }

  // 创建商家
  @override
  Future<OperateResult<String>> createShop(String who, String bookId, {required String name}) async {
    final id = await ShopCULog.create(who, bookId, name: name).execute();
    return OperateResult.success(id);
  }

  // 更新商家
  @override
  Future<OperateResult<void>> updateShop(String who, String bookId, String shopId, {required String name}) async {
    await ShopCULog.update(who, bookId, shopId, name: name).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<String>> createSymbol(String who, String bookId, {required String name, required SymbolType symbolType}) async {
    final id = await SymbolCULog.create(who, bookId, name: name, symbolType: symbolType).execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> updateSymbol(String who, String bookId, String tagId, {required String name}) async {
    await SymbolCULog.update(who, bookId, tagId, name: name).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteCategory(String who, String bookId, String categoryId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.category, categoryId).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteItem(String who, String bookId, String itemId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.item, itemId).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteShop(String who, String bookId, String shopId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.shop, shopId).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteSymbol(String who, String bookId, String symbolId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.symbol, symbolId).execute();
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
            name: name, fundType: fundType, fundRemark: fundRemark, fundBalance: fundBalance, isDefault: isDefault)
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
    await FundCULog.update(who, bookId, fundId, name: name, fundType: fundType, fundBalance: fundBalance, fundRemark: fundRemark).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> deleteFund(String who, String bookId, String fundId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.fund, fundId).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<UserFundVO>> getFund(String who, String bookId, String fundId) async {
    final fund = await DaoManager.fundDao.findById(fundId);
    return OperateResult.successIfNotNull(await VOTransfer.transferFund(fund));
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
      {bool? canViewBook, bool? canEditBook, bool? canDeleteBook, bool? canViewItem, bool? canEditItem, bool? canDeleteItem}) async {
    await MemberCULog.update(who, bookId, memberId,
            canViewBook: canViewBook,
            canEditBook: canEditBook,
            canDeleteBook: canDeleteBook,
            canViewItem: canViewItem,
            canEditItem: canEditItem,
            canDeleteItem: canDeleteItem)
        .execute();
  }

  Future<void> deleteBookMember(String who, String bookId, String memberId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.bookMember, memberId).execute();
  }

  @override
  Future<OperateResult<List<UserFundVO>>> listFundsByBook(String userId, String bookId) async {
    final funds = await DaoManager.fundDao.listByBook(bookId);
    return OperateResult.successIfNotNull(await VOTransfer.transferFunds(funds));
  }

  @override
  Future<OperateResult<String>> register(
      {String? userId,
      required String username,
      required String password,
      required String nickname,
      String? email,
      String? phone,
      String? language,
      String? timezone,
      String? avatar}) async {
    // 检查用户名是否已存在
    if (await DaoManager.userDao.isUsernameExists(username)) {
      return OperateResult.failWithMessage(message: '用户名已存在');
    }
    final id =
        await UserCULog.create(userId: userId, username: username, password: password, nickname: nickname, email: email, phone: phone)
            .execute();
    return OperateResult.success(id);
  }

  /// 获取用户信息
  @override
  Future<OperateResult<UserVO>> getUserInfo(String id) async {
    final user = await DaoManager.userDao.findById(id);
    if (user == null) {
      return OperateResult.failWithMessage(message: '用户不存在');
    }
    return OperateResult.success(UserVO.fromUser(
        user: user, avatar: user.avatar != defaultAvatar ? await ServiceManager.attachmentService.getAttachment(user.avatar) : null));
  }

  @override
  Future<OperateResult<void>> updateUser(String userId,
      {String? oldPassword,
      String? newPassword,
      String? nickname,
      String? email,
      String? phone,
      String? language,
      String? timezone,
      File? avatar}) async {
    String? attachId;
    if (avatar != null) {
      attachId = await AttachmentCULog.fromFile(userId, belongType: BusinessType.user, belongId: userId, file: avatar).execute();
    }

    String? hashedPassword;
    if (newPassword != null && oldPassword != null) {
      final user = await DaoManager.userDao.findById(userId);
      if (user == null) {
        return OperateResult.failWithMessage(message: '用户不存在');
      }
      if (!await verifyPassword(user, oldPassword)) {
        return OperateResult.failWithMessage(message: '旧密码错误');
      }
      hashedPassword = encryptPassword(newPassword);
    }
    await UserCULog.update(userId,
            password: hashedPassword,
            nickname: nickname,
            email: email,
            phone: phone,
            language: language,
            timezone: timezone,
            avatar: attachId)
        .execute();
    return OperateResult.success(null);
  }

  /// 验证密码
  Future<bool> verifyPassword(User user, String password) async {
    final hashedPassword = encryptPassword(password);
    return user.password == hashedPassword;
  }

  String encryptPassword(String password) {
    return DigestUtil.toSha256(password);
  }

  @override
  Future<OperateResult<List<AccountCategory>>> listCategoriesByBook(String userId, String bookId, {String? categoryType}) async {
    final categories = await DaoManager.categoryDao.listCategoriesByBook(bookId, categoryType: categoryType);
    return OperateResult.success(categories);
  }

  @override
  Future<OperateResult<List<AccountShop>>> listShopsByBook(String userId, String bookId) async {
    final shops = await DaoManager.shopDao.listByBook(bookId);
    return OperateResult.success(shops);
  }

  @override
  Future<OperateResult<List<AccountSymbol>>> listSymbolsByBook(String userId, String bookId, {SymbolType? symbolType}) async {
    final symbols = await DaoManager.symbolDao.listSymbolsByBook(bookId, symbolType: symbolType);
    return OperateResult.success(symbols);
  }

  @override
  Future<OperateResult<List<UserNoteVO>>> listNotesByBook(String userId, String bookId, {int limit = 200, int offset = 0}) async {
    final notes = await DaoManager.noteDao.listByBook(bookId, limit: limit, offset: offset);
    return OperateResult.success(await VOTransfer.transferNote(notes));
  }

  @override
  Future<OperateResult<String>> createNote(String who, String bookId, {String? title, required String content}) async {
    final id = await NoteCULog.create(who, bookId, title: title, content: content).execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> deleteNote(String who, String bookId, String noteId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.note, noteId).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> updateNote(String who, String bookId, String noteId,
      {String? title, String? content, String? noteDate}) async {
    await NoteCULog.update(who, bookId, noteId, title: title, content: content, noteDate: noteDate).execute();
    return OperateResult.success(null);
  }
}
