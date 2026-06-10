import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:clsswjz_gui/enums/gift_card.dart';
import 'package:clsswjz_gui/models/dto/note_filter_dto.dart';

import '../../constants/constant.dart';
import '../../constants/default_book_values.constant.dart';
import '../../database/database.dart';
import '../../enums/account_type.dart';
import '../../enums/business_type.dart';
import '../../enums/debt_clear_state.dart';
import '../../enums/debt_type.dart';
import '../../enums/fund_type.dart';
import '../../enums/gift_card_status.dart';
import '../../enums/note_type.dart';
import '../../enums/symbol_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/dao_manager.dart';
import '../../manager/database_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/dto/attachment_filter_dto.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/attachment_show_vo.dart';
import '../../models/vo/gift_card_vo.dart';
import '../../models/vo/activity_definition_vo.dart';
import '../../models/vo/activity_record_vo.dart';
import '../../models/vo/vehicle_vo.dart';
import '../../models/vo/fuel_record_vo.dart';
import '../../models/vo/fuel_statistics_vo.dart';
import '../../models/dto/fuel_record_filter_dto.dart';
import '../../models/vo/item_relation_vo.dart';
import '../../models/vo/user_share_vo.dart';
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
import 'log/builder/gift_card.builder.dart';
import 'log/builder/activity_definition.builder.dart';
import 'log/builder/activity_record.builder.dart';
import 'log/builder/vehicle.builder.dart';
import 'log/builder/fuel_record.builder.dart';
import 'log/builder/item_relation.builder.dart';
import 'log/builder/book_item.builder.dart';
import 'log/builder/book_member.builder.dart';
import 'log/builder/book_shop.builder.dart';
import 'log/builder/book_symbol.builder.dart';
import 'log/builder/user.builder.dart';
import 'log/builder/user_share.builder.dart';

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
    return OperateResult.success(await VOTransfer.transferItems(items));
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
    final id = await DatabaseManager.db.transaction(() async {
      final debtId = await DebtCULog.create(
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
              sourceId: debtId)
          .execute();
      return debtId;
    });
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

  @override
  Future<OperateResult<List<UserDebtVO>>> listDebts(String userId,
      {int limit = 200, int offset = 0, String? keyword}) async {
    try {
      final sharedBy = await DaoManager.userShareDao
          .findOwnersByTarget(userId, BusinessType.debt.code);
      final debts = await DaoManager.debtDao.findByCreatorOrShared(
          userId, sharedBy,
          limit: limit, offset: offset, keyword: keyword);
      final fundIds = debts.map((d) => d.fundId).toSet().toList();
      final funds = fundIds.isNotEmpty
          ? await DaoManager.fundDao.findByIds(fundIds)
          : <AccountFund>[];
      final fundMap = <String, String>{};
      for (final f in funds) {
        fundMap[f.id] = f.name;
      }
      final vos = debts
          .map((d) => UserDebtVO.fromDebt(
              debt: d,
              totalAmount: 0.0,
              remainAmount: 0.0,
              fundName: fundMap[d.fundId] ?? ''))
          .toList();
      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取债务列表失败：$e', exception: e as Exception);
    }
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

  // ============ 礼物卡相关 ============

  @override
  Future<OperateResult<String>> createGiftCard(
    String userId, {
    required String toUserId,
    String? description,
    int? expiredTime,
  }) async {
    try {
      // 获取当前用户信息作为赠送人
      final fromUser = await DaoManager.userDao.findById(userId);
      if (fromUser == null) {
        return OperateResult.failWithMessage(message: '用户不存在');
      }

      // 获取接收人信息
      final toUser = await DaoManager.userDao.findById(toUserId);
      if (toUser == null) {
        return OperateResult.failWithMessage(message: '接收人不存在');
      }

      final logBuilder = GiftCardCULog.create(
        who: userId,
        fromUserId: userId,
        toUserId: toUserId,
        description: description,
        expiredTime: expiredTime,
      );
      final id = await logBuilder.execute();
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '创建礼物卡失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> deleteGiftCard(
      String userId, String giftCardId) async {
    try {
      final logBuilder = GiftCardCULog.delete(
        who: userId,
        id: giftCardId,
      );
      await logBuilder.execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '删除礼物卡失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> updateGiftCard(
    String userId,
    String giftCardId, {
    String? toUserId,
    String? description,
    int? expiredTime,
    int? sentTime,
    int? receivedTime,
    String? status,
  }) async {
    try {
      final logBuilder = GiftCardCULog.update(
        who: userId,
        id: giftCardId,
        toUserId: toUserId,
        description: description,
        expiredTime: expiredTime,
        sentTime: sentTime,
        receivedTime: receivedTime,
        status: status,
      );
      await logBuilder.execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '更新礼物卡失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<List<GiftCardVO>>> listGiftCards(String userId,
      {GiftCardQueryType type = GiftCardQueryType.all}) async {
    try {
      // 检查并更新过期状态
      await _checkAndUpdateExpiredStatus();

      // 查询数据
      List<GiftCard> giftCards;
      switch (type) {
        case GiftCardQueryType.received:
          giftCards = await DaoManager.giftCardDao.findReceived(userId);
          break;
        case GiftCardQueryType.sent:
          giftCards = await DaoManager.giftCardDao.findSent(userId);
          break;
        case GiftCardQueryType.all:
          giftCards = await DaoManager.giftCardDao.findAll();
          break;
      }

      if (giftCards.isEmpty) {
        return OperateResult.success([]);
      }

      // 收集所有用户ID用于翻译昵称
      final userIds = <String>{};
      for (final card in giftCards) {
        userIds.add(card.fromUserId);
        userIds.add(card.toUserId);
      }

      // 批量查询用户信息
      final users = await DaoManager.userDao.findByIds(userIds.toList());
      final userMap = {for (final u in users) u.id: u.nickname};

      // 翻译昵称
      final vos = giftCards.map((card) {
        return GiftCardVO.withNicknames(
          id: card.id,
          fromUserId: card.fromUserId,
          fromUserNickname: userMap[card.fromUserId] ?? '未知用户',
          toUserId: card.toUserId,
          toUserNickname: userMap[card.toUserId] ?? '未知用户',
          description: card.description,
          expiredTime: card.expiredTime,
          sentTime: card.sentTime,
          receivedTime: card.receivedTime,
          status: GiftCardStatus.fromCode(card.status),
          createdAt: card.createdAt,
          updatedAt: card.updatedAt,
          createdBy: card.createdBy,
          updatedBy: card.updatedBy,
        );
      }).toList();

      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取礼物卡列表失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<GiftCardVO>> getGiftCard(
      String userId, String giftCardId) async {
    try {
      final card = await DaoManager.giftCardDao.findById(giftCardId);
      if (card == null) {
        return OperateResult.failWithMessage(message: '礼物卡不存在');
      }

      // 翻译用户昵称
      final fromUser = await DaoManager.userDao.findById(card.fromUserId);
      final toUser = await DaoManager.userDao.findById(card.toUserId);

      final vo = GiftCardVO.withNicknames(
        id: card.id,
        fromUserId: card.fromUserId,
        fromUserNickname: fromUser?.nickname ?? fromUser?.username ?? '未知用户',
        toUserId: card.toUserId,
        toUserNickname: toUser?.nickname ?? toUser?.username ?? '未知用户',
        description: card.description,
        expiredTime: card.expiredTime,
        sentTime: card.sentTime,
        receivedTime: card.receivedTime,
        status: GiftCardStatus.fromCode(card.status),
        createdAt: card.createdAt,
        updatedAt: card.updatedAt,
        createdBy: card.createdBy,
        updatedBy: card.updatedBy,
      );

      return OperateResult.success(vo);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取礼物卡详情失败：$e', exception: e as Exception);
    }
  }

  /// 检查并更新过期状态
  Future<void> _checkAndUpdateExpiredStatus() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiredCards = await DaoManager.giftCardDao.findExpired(now);

    for (final card in expiredCards) {
      await GiftCardCULog.update(
        who: card.createdBy,
        id: card.id,
        status: GiftCardStatus.expired.code,
      ).execute();
    }
  }

  // ============ 活动记录相关 ============

  @override
  Future<OperateResult<String>> createActivityRecord(
    String userId,
    String bookId, {
    required String activityName,
    required String recordDate,
    String? activityDefId,
    String? location,
    int? createdAt,
    int? maxDailyCount,
  }) async {
    try {
      final logBuilder = ActivityRecordCULog.create(
        who: userId,
        bookId: bookId,
        activityName: activityName,
        recordDate: recordDate,
        activityDefId: activityDefId,
        location: location,
        createdAt: createdAt,
        maxDailyCount: maxDailyCount,
      );
      final id = await logBuilder.execute();
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '创建活动记录失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> updateActivityRecordTime(
    String userId,
    String recordId, {
    required int createdAt,
  }) async {
    try {
      await ActivityRecordCULog.updateTime(
        who: userId,
        id: recordId,
        createdAt: createdAt,
      ).execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '更新活动记录时间失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> deleteActivityRecord(
      String userId, String bookId, String recordId) async {
    try {
      await ActivityRecordCULog.delete(
        who: userId,
        bookId: bookId,
        id: recordId,
      ).execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '删除活动记录失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<List<ActivityRecordVO>>> listActivityRecordsByBook(
    String userId, String bookId, {
    int limit = 200,
    int offset = 0,
    String? startDate,
    String? endDate,
    String? activityDefId,
  }) async {
    try {
      List<ActivityRecord> records;
      if (startDate != null && endDate != null) {
        records = await DaoManager.activityRecordDao
            .listByDateRange(bookId, startDate, endDate, limit: limit, offset: offset, activityDefId: activityDefId);
      } else {
        records = await DaoManager.activityRecordDao
            .listByBook(bookId, limit: limit, offset: offset);
      }
      final vos = records.map((e) => ActivityRecordVO.fromActivityRecord(e)).toList();
      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取活动记录列表失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<List<ActivityRecordVO>>> listActivityRecords(
    String userId, {
    int limit = 200,
    int offset = 0,
    String? startDate,
    String? endDate,
    String? activityDefId,
  }) async {
    try {
      final sharedBy = await DaoManager.userShareDao
          .findOwnersByTarget(userId, BusinessType.activity.code);
      final records = await DaoManager.activityRecordDao
          .findByCreatorOrShared(userId, sharedBy,
              limit: limit, offset: offset,
              activityDefId: activityDefId,
              startDate: startDate, endDate: endDate);
      final vos = records.map((e) => ActivityRecordVO.fromActivityRecord(e)).toList();
      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取活动记录列表失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<List<ActivityDefinitionVO>>> listActivityDefinitions(
      String userId) async {
    try {
      final sharedBy = await DaoManager.userShareDao
          .findOwnersByTarget(userId, BusinessType.activity.code);
      final definitions =
          await DaoManager.activityDefinitionDao.findByCreatorOrShared(userId, sharedBy);
      final vos = definitions
          .map((e) => ActivityDefinitionVO.fromEntity(e))
          .toList();
      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取活动定义列表失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<List<String>>> listDistinctActivityNames(
      String userId, String bookId) async {
    try {
      final names = await DaoManager.activityRecordDao.listDistinctActivityNames(bookId);
      return OperateResult.success(names);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取活动名称列表失败：$e', exception: e as Exception);
    }
  }

  // ============ 活动定义相关 ============

  @override
  Future<OperateResult<String>> createActivityDefinition(
    String userId,
    String bookId, {
    required String name,
    required String emoji,
    required int color,
    int sortOrder = 0,
    int? maxDailyCount,
  }) async {
    try {
      final logBuilder = ActivityDefinitionCULog.create(
        who: userId,
        bookId: bookId,
        name: name,
        emoji: emoji,
        color: color,
        sortOrder: sortOrder,
        maxDailyCount: maxDailyCount,
      );
      final id = await logBuilder.execute();
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '创建活动定义失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> updateActivityDefinition(
    String userId,
    String definitionId, {
    String? name,
    String? emoji,
    int? color,
    int? sortOrder,
    int? maxDailyCount,
  }) async {
    try {
      final logBuilder = ActivityDefinitionCULog.update(
        who: userId,
        id: definitionId,
        name: name,
        emoji: emoji,
        color: color,
        sortOrder: sortOrder,
        maxDailyCount: maxDailyCount,
      );
      await logBuilder.execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '更新活动定义失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> deleteActivityDefinition(
      String userId, String definitionId) async {
    try {
      await ActivityDefinitionCULog.delete(
        who: userId,
        id: definitionId,
      ).execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '删除活动定义失败：$e', exception: e as Exception);
    }
  }

  // ============ 油耗记录相关 ============

  @override
  Future<OperateResult<String>> createVehicle(
    String userId, {
    required String plateNumber,
    required String brand,
    required String model,
    String? remark,
    String? defaultFuelGrade,
  }) async {
    try {
      final logBuilder = VehicleCULog.create(
        who: userId,
        plateNumber: plateNumber,
        brand: brand,
        model: model,
        remark: remark,
        defaultFuelGrade: defaultFuelGrade,
      );
      final id = await logBuilder.execute();
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '创建车辆失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> deleteVehicle(
      String userId, String vehicleId) async {
    try {
      final logBuilder = VehicleCULog.delete(
        who: userId,
        id: vehicleId,
      );
      await logBuilder.execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '删除车辆失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> updateVehicle(
    String userId,
    String vehicleId, {
    String? plateNumber,
    String? brand,
    String? model,
    String? remark,
    String? defaultFuelGrade,
    bool? isActive,
    int? sortOrder,
  }) async {
    try {
      final logBuilder = VehicleCULog.update(
        who: userId,
        id: vehicleId,
        plateNumber: plateNumber,
        brand: brand,
        model: model,
        remark: remark,
        defaultFuelGrade: defaultFuelGrade,
        isActive: isActive != null ? (isActive ? 1 : 0) : null,
        sortOrder: sortOrder,
      );
      await logBuilder.execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '更新车辆失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<List<VehicleVO>>> listVehicles(String userId) async {
    try {
      final sharedBy = await DaoManager.userShareDao
          .findOwnersByTarget(userId, BusinessType.vehicle.code);
      final vehicles =
          await DaoManager.vehicleDao.findByCreatorOrShared(userId, sharedBy);
      final vos = vehicles.map((v) => VehicleVO.fromVehicle(v)).toList();
      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取车辆列表失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<String>> createFuelRecord(
    String userId, {
    required String vehicleId,
    required int mileage,
    required String energyType,
    required String fuelGrade,
    required double volume,
    required double unitPrice,
    required double totalAmount,
    bool isFullTank = false,
    int? isFuelLightOn,
    String? station,
    String? remark,
    int? refuelTime,
  }) async {
    try {
      final logBuilder = FuelRecordCULog.create(
        who: userId,
        vehicleId: vehicleId,
        mileage: mileage,
        energyType: energyType,
        fuelGrade: fuelGrade,
        volume: volume,
        unitPrice: unitPrice,
        totalAmount: totalAmount,
        isFullTank: isFullTank,
        isFuelLightOn: isFuelLightOn,
        station: station,
        remark: remark,
        refuelTime: refuelTime,
      );
      final id = await logBuilder.execute();
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '创建加油记录失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> deleteFuelRecord(
      String userId, String recordId) async {
    try {
      final logBuilder = FuelRecordCULog.delete(
        who: userId,
        id: recordId,
      );
      await logBuilder.execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '删除加油记录失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> updateFuelRecord(
    String userId,
    String recordId, {
    int? mileage,
    String? energyType,
    String? fuelGrade,
    double? volume,
    double? unitPrice,
    double? totalAmount,
    bool? isFullTank,
    int? isFuelLightOn,
    String? station,
    String? remark,
    int? refuelTime,
    String? linkedBookId,
    String? linkedItemId,
  }) async {
    try {
      final logBuilder = FuelRecordCULog.update(
        who: userId,
        id: recordId,
        mileage: mileage,
        energyType: energyType,
        fuelGrade: fuelGrade,
        volume: volume,
        unitPrice: unitPrice,
        totalAmount: totalAmount,
        isFullTank: isFullTank,
        isFuelLightOn: isFuelLightOn,
        station: station,
        remark: remark,
        refuelTime: refuelTime,
        linkedBookId: linkedBookId,
        linkedItemId: linkedItemId,
      );
      await logBuilder.execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '更新加油记录失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<List<FuelRecordVO>>> listFuelRecords(
    String userId,
    String vehicleId, {
    int limit = 20,
    int offset = 0,
    FuelRecordFilterDTO? filter,
  }) async {
    try {
      List<FuelRecord> records;
      if (filter != null) {
        // Query all and apply in-memory filtering
        records = await DaoManager.fuelRecordDao.findByVehicleId(vehicleId);
        if (filter.startDate != null) {
          final start =
              DateTime.parse(filter.startDate!).millisecondsSinceEpoch;
          records = records.where((r) => r.refuelTime >= start).toList();
        }
        if (filter.endDate != null) {
          final end = DateTime.parse(filter.endDate!).millisecondsSinceEpoch;
          records = records.where((r) => r.refuelTime <= end).toList();
        }
        // Apply limit/offset after filtering
        records = records.skip(offset).take(limit).toList();
      } else {
        records = await DaoManager.fuelRecordDao
            .findByVehicleId(vehicleId, limit: limit, offset: offset);
      }

      // Convert to VO with consumption data
      final vos = <FuelRecordVO>[];
      for (final record in records) {
        FuelRecordVO vo = FuelRecordVO.fromFuelRecord(record);
        if (record.isFullTank == 1) {
          final lastFullTank = await DaoManager.fuelRecordDao
              .findLastFullTank(vehicleId, record.mileage);
          if (lastFullTank != null) {
            vo = vo.copyWith(
              lastFullTankMileage: lastFullTank.mileage,
              lastFullTankVolume: lastFullTank.volume,
            );
          }
        }
        vos.add(vo);
      }

      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取加油记录列表失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<FuelRecordVO>> getFuelRecord(
      String userId, String recordId) async {
    try {
      final record = await DaoManager.fuelRecordDao.findById(recordId);
      if (record == null) {
        return OperateResult.failWithMessage(message: '加油记录不存在');
      }

      FuelRecordVO vo = FuelRecordVO.fromFuelRecord(record);
      if (record.isFullTank == 1) {
        final lastFullTank = await DaoManager.fuelRecordDao
            .findLastFullTank(record.vehicleId, record.mileage);
        if (lastFullTank != null) {
          vo = vo.copyWith(
            lastFullTankMileage: lastFullTank.mileage,
            lastFullTankVolume: lastFullTank.volume,
          );
        }
      }

      return OperateResult.success(vo);
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取加油记录详情失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<FuelStatisticsVO>> getFuelStatistics(
      String userId, String vehicleId) async {
    try {
      final records =
          await DaoManager.fuelRecordDao.findByVehicleId(vehicleId);

      if (records.isEmpty) {
        return OperateResult.success(FuelStatisticsVO(
          totalVolume: 0,
          totalAmount: 0,
          totalRecords: 0,
        ));
      }

      double totalVolume = 0;
      double totalAmount = 0;
      int totalRecords = records.length;

      final sortedRecords = List<FuelRecord>.from(records)
        ..sort((a, b) => a.refuelTime.compareTo(b.refuelTime));

      for (final r in sortedRecords) {
        totalVolume += r.volume;
        totalAmount += r.totalAmount;
      }

      // Calculate average fuel consumption from consecutive full tank pairs
      double? averageFuelConsumption;
      final List<double> segmentConsumptions = [];
      int? lastFullTankIndex;

      for (int i = 0; i < sortedRecords.length; i++) {
        if (sortedRecords[i].isFullTank == 1) {
          if (lastFullTankIndex != null) {
            final prevRecord = sortedRecords[lastFullTankIndex];
            final currRecord = sortedRecords[i];
            final distance =
                (currRecord.mileage - prevRecord.mileage).toDouble();
            if (distance > 0) {
              // Volume at current fill is the fuel consumed since last full tank
              segmentConsumptions.add(currRecord.volume / distance * 100);
            }
          }
          lastFullTankIndex = i;
        }
      }

      if (segmentConsumptions.isNotEmpty) {
        averageFuelConsumption = segmentConsumptions
                .reduce((a, b) => a + b) /
            segmentConsumptions.length;
      }

      // Calculate average cost per km
      double? averageCostPerKm;
      if (sortedRecords.length >= 2) {
        int maxMileage = sortedRecords[0].mileage;
        int minMileage = sortedRecords[0].mileage;
        for (final r in sortedRecords) {
          maxMileage = max(maxMileage, r.mileage);
          minMileage = min(minMileage, r.mileage);
        }
        final totalKm = (maxMileage - minMileage).toDouble();
        if (totalKm > 0) {
          averageCostPerKm = totalAmount / totalKm;
        }
      }

      return OperateResult.success(FuelStatisticsVO(
        totalVolume: totalVolume,
        totalAmount: totalAmount,
        totalRecords: totalRecords,
        averageFuelConsumption: averageFuelConsumption,
        averageCostPerKm: averageCostPerKm,
      ));
    } catch (e) {
      return OperateResult.failWithMessage(
          message: '获取油耗统计失败：$e', exception: e as Exception);
    }
  }

  @override
  Future<OperateResult<void>> createItemRelation(String userId, {
    required String itemId,
    required String accountBookId,
    required String relationCode,
    required String relationId,
  }) async {
    try {
      await ItemRelationCULog.create(
        userId,
        itemId: itemId,
        accountBookId: accountBookId,
        relationCode: relationCode,
        relationId: relationId,
      ).execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '创建关联失败：$e',
        exception: e as Exception,
      );
    }
  }

  @override
  Future<OperateResult<void>> deleteItemRelation(String userId, String relationId) async {
    try {
      await ItemRelationCULog.delete(userId, relationId).execute();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '删除关联失败：$e',
        exception: e as Exception,
      );
    }
  }

  @override
  Future<OperateResult<List<String>>> getRelatedItemIds(String userId, {
    required String relationCode,
    required String relationId,
  }) async {
    try {
      final relations = await DaoManager.itemRelationDao.findByRelation(relationCode, relationId);
      final ids = relations.map((r) => r.itemId).toList();
      return OperateResult.success(ids);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '查询关联账目失败：$e',
        exception: e as Exception,
      );
    }
  }

  @override
  Future<OperateResult<List<ItemRelationVO>>> getSourceItemRelations(String userId, {
    required String relationCode,
    required String relationId,
  }) async {
    try {
      final relations = await DaoManager.itemRelationDao.findByRelation(relationCode, relationId);
      final vos = relations.map((r) => ItemRelationVO.fromItemRelation(r)).toList();
      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '查询关联记录失败：$e',
        exception: e as Exception,
      );
    }
  }

  @override
  Future<OperateResult<List<ItemRelationVO>>> getItemRelations(String userId, {
    required String itemId,
  }) async {
    try {
      final relations = await DaoManager.itemRelationDao.findByItemId(itemId);
      final vos = relations.map((r) => ItemRelationVO.fromItemRelation(r)).toList();
      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '查询账目关联失败：$e',
        exception: e as Exception,
      );
    }
  }

  // ==================== 模块共享 ====================

  @override
  Future<OperateResult<void>> setUserShare(
    String userId, {
    required String targetUserId,
    required String businessType,
    required bool isEnabled,
  }) async {
    try {
      if (isEnabled) {
        // Enable: upsert (create or replace)
        await UserShareCULog.create(
          who: userId,
          ownerUserId: userId,
          targetUserId: targetUserId,
          businessType: businessType,
        ).execute();
      } else {
        // Disable: find existing and update isEnabled=false
        final shares = await DaoManager.userShareDao
            .findByOwnerAndTarget(userId, targetUserId, businessType);
        final share = shares.firstOrNull;
        if (share != null) {
          await UserShareCULog.update(
            who: userId,
            id: share.id,
            isEnabled: false,
          ).execute();
        }
      }
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '设置共享失败：$e',
        exception: e as Exception,
      );
    }
  }

  @override
  Future<OperateResult<List<UserShareVO>>> listUserShares(String userId) async {
    try {
      final shares = await DaoManager.userShareDao.findEnabledByOwner(userId);
      final vos = shares.map((s) => UserShareVO.fromUserShare(s)).toList();
      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '获取共享列表失败：$e',
        exception: e as Exception,
      );
    }
  }

  @override
  Future<OperateResult<List<UserShareVO>>> listUserSharesByTarget(String userId) async {
    try {
      final shares = await DaoManager.userShareDao.findEnabledByTarget(userId);
      final vos = shares.map((s) => UserShareVO.fromUserShare(s)).toList();
      return OperateResult.success(vos);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '获取被共享列表失败：$e',
        exception: e as Exception,
      );
    }
  }
}
