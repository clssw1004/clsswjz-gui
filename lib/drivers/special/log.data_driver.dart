import 'dart:core';
import 'dart:io';
import 'package:clsswjz_gui/models/dto/note_filter_dto.dart';

import '../../constants/constant.dart';
import '../../constants/default_book_values.constant.dart';
import '../../database/database.dart';
import '../../enums/account_type.dart';
import '../../enums/business_type.dart';
import '../../enums/debt_clear_state.dart';
import '../../enums/debt_type.dart';
import '../../enums/fund_type.dart';
import '../../enums/note_type.dart';
import '../../enums/symbol_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/dao_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/dto/attachment_filter_dto.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/attachment_show_vo.dart';
import '../../models/vo/user_debt_vo.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../models/vo/attachment_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../enums/currency_symbol.dart';
import '../../models/common.dart';
import '../../models/vo/user_note_vo.dart';
import '../../models/vo/user_vo.dart';
import '../../utils/collection_util.dart';
import '../../utils/digest_util.dart';
import '../data_driver.dart';
import '../../constants/account_book_icons.dart';
import '../vo_transfer.dart';
import 'log/builder/attachment.builder.dart';
import 'log/builder/book.builder.dart';
import 'log/builder/book_category.builder.dart';
import 'log/builder/book_debt.build.dart';
import 'log/builder/book_note.build.dart';
import 'log/builder/builder.dart';
import 'log/builder/fund.builder.dart';
import 'log/builder/book_item.builder.dart';
import 'log/builder/book_member.builder.dart';
import 'log/builder/book_shop.builder.dart';
import 'log/builder/book_symbol.builder.dart';
import 'log/builder/user.builder.dart';

class LogDataDriver implements BookDataDriver {
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
    final id = await UserCULog.create(
            userId: userId,
            username: username,
            password: password,
            nickname: nickname,
            email: email,
            phone: phone)
        .execute();
    return OperateResult.success(id);
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
      attachId = await AttachmentCULog.fromFile(userId,
              belongType: BusinessType.user, belongId: userId, file: avatar)
          .execute();
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

  /// 获取用户信息
  @override
  Future<OperateResult<UserVO>> getUserInfo(String id) async {
    final user = await DaoManager.userDao.findById(id);
    if (user == null) {
      return OperateResult.failWithMessage(message: '用户不存在');
    }
    return OperateResult.success(UserVO.fromUser(
        user: user,
        avatar: user.avatar != defaultAvatar
            ? await ServiceManager.attachmentService.getAttachment(user.avatar)
            : null));
  }

  @override
  Future<OperateResult<String>> createBook(String userId,
      {required String name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      String? defaultFundId,
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

  @override
  Future<OperateResult<void>> deleteBook(String userId, String bookId) async {
    await BookDLog.delete(userId, bookId).execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> updateBook(String who, String bookId,
      {String? name,
      String? description,
      CurrencySymbol? currencySymbol,
      String? icon,
      String? defaultFundId,
      List<BookMemberVO> members = const []}) async {
    await BookCULog.update(who, bookId,
            name: name,
            description: description,
            currencySymbol: currencySymbol,
            icon: icon,
            defaultFundId: defaultFundId)
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
  Future<OperateResult<String>> createItem(String who, String bookId,
      {required amount,
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
            projectCode: projectCode,
            source: source,
            sourceId: sourceId)
        .execute();
    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        await AttachmentCULog.fromFile(who,
                belongType: BusinessType.item, belongId: id, file: file)
            .execute();
      }
    }
    if (categoryCode != null) {
      final category =
          await DaoManager.categoryDao.findByBookAndCode(bookId, categoryCode);
      if (category != null) {
        updateCategory(who, bookId, category.id,
            lastAccountItemAt: accountDate);
      }
    }
    if (shopCode != null) {
      final shop = await DaoManager.shopDao.findByBookAndCode(bookId, shopCode);
      if (shop != null) {
        updateShop(who, bookId, shop.id, lastAccountItemAt: accountDate);
      }
    }
    if (tagCode != null) {
      final tag = await DaoManager.symbolDao
          .findByBookAndCode(bookId, SymbolType.tag.code, tagCode);
      if (tag != null) {
        updateSymbol(who, bookId, tag.id, lastAccountItemAt: accountDate);
      }
    }
    if (projectCode != null) {
      final project = await DaoManager.symbolDao
          .findByBookAndCode(bookId, SymbolType.project.code, projectCode);
      if (project != null) {
        updateSymbol(who, bookId, project.id, lastAccountItemAt: accountDate);
      }
    }
    if (fundId != null) {
      final fund = await DaoManager.fundDao.findById(fundId);
      if (fund != null) {
        updateFund(who, bookId, fund.id, lastAccountItemAt: accountDate);
      }
    }
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> deleteItem(
      String who, String bookId, String itemId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.item, itemId)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> updateItem(
      String who, String bookId, String itemId,
      {double? amount,
      String? description,
      AccountItemType? type,
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
    await updateAttachments(who, BusinessType.item, itemId, attachments ?? []);
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<List<UserItemVO>>> listItemsByBook(
      String userId, String bookId,
      {int limit = 20, int offset = 0, ItemFilterDTO? filter}) async {
    final items = await DaoManager.itemDao
        .listByBook(bookId, limit: limit, offset: offset, filter: filter);
    return OperateResult.success(await VOTransfer.transferAccountItem(items));
  }

  @override
  Future<OperateResult<String>> createCategory(String who, String bookId,
      {required String name,
      required String categoryType,
      String? code}) async {
    final category =
        await DaoManager.categoryDao.findByBookAndName(bookId, name);
    if (category != null) {
      return OperateResult.success(category.id);
    }
    final id = await CategoryCULog.create(who, bookId,
            name: name, categoryType: categoryType, code: code)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> deleteCategory(
      String who, String bookId, String categoryId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.category, categoryId)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> updateCategory(
      String who, String bookId, String categoryId,
      {String? name, String? lastAccountItemAt}) async {
    await CategoryCULog.update(who, bookId, categoryId,
            name: name, lastAccountItemAt: lastAccountItemAt)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<List<AccountCategory>>> listCategoriesByBook(
      String userId, String bookId,
      {String? categoryType}) async {
    final categories = await DaoManager.categoryDao
        .listCategoriesByBook(bookId, categoryType: categoryType);
    return OperateResult.success(categories);
  }

  // 创建商家
  @override
  Future<OperateResult<String>> createShop(String who, String bookId,
      {required String name}) async {
    final shop = await DaoManager.shopDao.findByBookAndName(bookId, name);
    if (shop != null) {
      return OperateResult.success(shop.id);
    }
    final id = await ShopCULog.create(who, bookId, name: name).execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> deleteShop(
      String who, String bookId, String shopId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.shop, shopId)
        .execute();
    return OperateResult.success(null);
  }

  // 更新商家
  @override
  Future<OperateResult<void>> updateShop(
      String who, String bookId, String shopId,
      {String? name, String? lastAccountItemAt}) async {
    await ShopCULog.update(who, bookId, shopId,
            name: name, lastAccountItemAt: lastAccountItemAt)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<List<AccountShop>>> listShopsByBook(
      String userId, String bookId) async {
    final shops = await DaoManager.shopDao.listByBook(bookId);
    return OperateResult.success(shops);
  }

  @override
  Future<OperateResult<String>> createSymbol(String who, String bookId,
      {required String name, required SymbolType symbolType}) async {
    final symbol = await DaoManager.symbolDao.findByBookAndName(bookId, name);
    if (symbol != null) {
      return OperateResult.success(symbol.id);
    }
    final id = await SymbolCULog.create(who, bookId,
            name: name, symbolType: symbolType)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> deleteSymbol(
      String who, String bookId, String symbolId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.symbol, symbolId)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> updateSymbol(
      String who, String bookId, String tagId,
      {String? name, String? lastAccountItemAt}) async {
    await SymbolCULog.update(who, bookId, tagId,
            name: name, lastAccountItemAt: lastAccountItemAt)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<List<AccountSymbol>>> listSymbolsByBook(
      String userId, String bookId,
      {SymbolType? symbolType}) async {
    final symbols = await DaoManager.symbolDao
        .listSymbolsByBook(bookId, symbolType: symbolType);
    return OperateResult.success(symbols);
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
  Future<OperateResult<void>> deleteFund(
      String who, String bookId, String fundId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.fund, fundId)
        .execute();
    return OperateResult.success(null);
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
    String? lastAccountItemAt,
  }) async {
    await FundCULog.update(who, bookId, fundId,
            name: name,
            fundType: fundType,
            fundBalance: fundBalance,
            fundRemark: fundRemark,
            lastAccountItemAt: lastAccountItemAt)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<UserFundVO>> getFund(
      String who, String bookId, String fundId) async {
    final fund = await DaoManager.fundDao.findById(fundId);
    return OperateResult.successIfNotNull(await VOTransfer.transferFund(fund));
  }

  @override
  Future<OperateResult<List<UserFundVO>>> listFundsByBook(
      String userId, String bookId) async {
    final funds = await DaoManager.fundDao.listByBook(bookId);
    return OperateResult.successIfNotNull(
        await VOTransfer.transferFunds(funds));
  }

  @override
  Future<OperateResult<String>> createNote(String who, String bookId,
      {String? title,
      required NoteType noteType,
      required String content,
      required String plainContent,
      String? groupCode,
      List<AttachmentVO>? attachments}) async {
    final id = await NoteCULog.create(who, bookId,
            title: title,
            noteType: noteType,
            content: content,
            plainContent: plainContent,
            groupCode: groupCode)
        .execute();
    if (attachments != null && attachments.isNotEmpty) {
      for (var attachment in attachments) {
        final vo = attachment.copyWith(businessId: id);
        await AttachmentCULog.fromVO(who,
                belongType: BusinessType.note, belongId: id, vo: vo)
            .execute();
      }
    }
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> deleteNote(
      String who, String bookId, String noteId) async {
    await DeleteLog.buildBookSub(who, bookId, BusinessType.note, noteId)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> updateNote(
      String who, String bookId, String noteId,
      {String? title,
      String? content,
      String? plainContent,
      String? groupCode,
      List<AttachmentVO>? attachments}) async {
    await NoteCULog.update(who, bookId, noteId,
            title: title,
            content: content,
            plainContent: plainContent,
            groupCode: groupCode)
        .execute();
    await updateAttachments(who, BusinessType.note, noteId, attachments ?? []);
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<List<UserNoteVO>>> listNotesByBook(
      String userId, String bookId,
      {int limit = 200, int offset = 0, NoteFilterDTO? filter}) async {
    final notes = await DaoManager.noteDao
        .listByBook(bookId, limit: limit, offset: offset, filter: filter);
    return OperateResult.success(await VOTransfer.transferNote(notes));
  }

  @override
  Future<OperateResult<String>> createDebt(String userId, String bookId,
      {required String debtor,
      required DebtType debtType,
      required double amount,
      required String fundId,
      required String debtDate,
      String? expectedClearDate,
      DebtClearState? clearState}) async {
    final id = await DebtCULog.create(
      userId,
      bookId,
      debtor: debtor,
      debtType: debtType,
      amount: amount,
      fundId: fundId,
      debtDate: debtDate,
      expectedClearDate: expectedClearDate,
    ).execute();
    await ItemCULog.create(userId, bookId,
            amount: amount,
            type: AccountItemType.transfer,
            accountDate: '$debtDate 00:00:00',
            fundId: fundId,
            categoryCode: debtType.code,
            description: '${debtType.text} $debtor',
            source: BusinessType.debt.code,
            sourceId: id)
        .execute();
    return OperateResult.success(id);
  }

  @override
  Future<OperateResult<void>> deleteDebt(
      String userId, String bookId, String debtId) async {
    await DeleteLog.buildBookSub(userId, bookId, BusinessType.debt, debtId)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<void>> updateDebt(
      String userId, String bookId, String debtId,
      {String? debtor,
      double? amount,
      String? fundId,
      String? debtDate,
      String? expectedClearDate,
      String? clearDate,
      DebtClearState? clearState}) async {
    await DebtCULog.update(userId, bookId, debtId,
            debtor: debtor,
            amount: amount,
            fundId: fundId,
            debtDate: debtDate,
            expectedClearDate: expectedClearDate,
            clearDate: clearDate,
            clearState: clearState)
        .execute();
    return OperateResult.success(null);
  }

  @override
  Future<OperateResult<List<UserDebtVO>>> listDebtsByBook(
      String userId, String bookId,
      {int limit = 200, int offset = 0, String? keyword}) async {
    final debts = await DaoManager.debtDao
        .listByBook(bookId, limit: limit, offset: offset, keyword: keyword);
    return OperateResult.success(
        await VOTransfer.transferDebts(bookId, userId, debts));
  }

  Future<void> initDefaultBookData(String userId, String bookId) async {
    DefaultBookData defaultData =
        getDefaultDataByLocale(AppConfigManager.instance.locale);
    if (defaultData.category.isNotEmpty) {
      for (var category in defaultData.category) {
        await createCategory(userId, bookId,
            name: category.name,
            categoryType: category.categoryType.code,
            code: category.code);
      }
    }
    if (defaultData.shop.isNotEmpty) {
      for (var shop in defaultData.shop) {
        await createShop(userId, bookId, name: shop);
      }
    }
    if (defaultData.symbols.isNotEmpty) {
      for (var symbol in defaultData.symbols) {
        await createSymbol(userId, bookId,
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

  /// 验证密码
  Future<bool> verifyPassword(User user, String password) async {
    final hashedPassword = encryptPassword(password);
    return user.password == hashedPassword;
  }

  String encryptPassword(String password) {
    return DigestUtil.toSha256(password);
  }

  Future<void> updateAttachments(String who, BusinessType businessType,
      String businessId, List<AttachmentVO> attachments) async {
    final oldAttachments = await ServiceManager.attachmentService
        .getAttachmentsByBusiness(businessType, businessId);
    final diff = CollectionUtil.diff(oldAttachments, attachments, (e) => e.id);
    if (diff.added != null && diff.added!.isNotEmpty) {
      for (var attachment in diff.added!) {
        await AttachmentCULog.fromVO(who,
                belongType: businessType, belongId: businessId, vo: attachment)
            .execute();
      }
    }
    if (diff.removed != null && diff.removed!.isNotEmpty) {
      for (var attachment in diff.removed!) {
        await AttachmentDeleteLog.fromAttachmentId(who,
                belongType: businessType,
                belongId: businessId,
                attachmentId: attachment.id)
            .execute();
      }
    }
  }

  @override
  Future<OperateResult<List<AttachmentShowVO>>> listAttachments(String userId,
      {int limit = 200, int offset = 0, AttachmentFilterDTO? filter}) async {
    final attachments = await DaoManager.attachmentDao
        .listByBook(userId, limit: limit, offset: offset, filter: filter);
    return OperateResult.success(
        await VOTransfer.transferAttachments(attachments));
  }
}
