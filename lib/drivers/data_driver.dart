import 'dart:io';

import 'package:clsswjz_gui/enums/gift_card.dart';
import 'package:clsswjz_gui/models/dto/attachment_filter_dto.dart';
import 'package:clsswjz_gui/models/dto/note_filter_dto.dart';

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
import '../models/vo/attachment_show_vo.dart';
import '../models/vo/user_book_vo.dart';
import '../models/vo/user_debt_vo.dart';
import '../models/vo/user_item_vo.dart';
import '../models/vo/attachment_vo.dart';
import '../models/vo/user_fund_vo.dart';
import '../models/vo/user_vo.dart';
import '../models/vo/user_note_vo.dart';
import '../models/vo/gift_card_vo.dart';
import '../models/vo/activity_record_vo.dart';
import '../models/vo/activity_statistic_vo.dart';
import '../models/vo/vehicle_vo.dart';
import '../models/vo/fuel_record_vo.dart';
import '../models/vo/fuel_statistics_vo.dart';
import '../models/dto/fuel_record_filter_dto.dart';

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
      String? groupCode,
      List<AttachmentVO>? attachments});

  /// 删除记事
  Future<OperateResult<void>> deleteNote(
      String who, String bookId, String noteId);

  /// 更新记事
  Future<OperateResult<void>> updateNote(
      String who, String bookId, String noteId,
      {String? title,
      String? content,
      String? plainContent,
      String? groupCode,
      List<AttachmentVO>? attachments});

  /// 获取用户记事列表
  Future<OperateResult<List<UserNoteVO>>> listNotesByBook(
      String who, String bookId,
      {int limit = 200, int offset = 0, NoteFilterDTO? filter});

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

  /// 获取账本附件列表
  Future<OperateResult<List<AttachmentShowVO>>> listAttachments(
      String userId,
      {int limit = 200,
      int offset = 0,
      AttachmentFilterDTO? filter});

  // ============ 礼物卡相关 ============

  /// 创建礼物卡
  Future<OperateResult<String>> createGiftCard(
    String userId, {
    required String toUserId,
    String? description,
    int? expiredTime,
  });

  /// 删除礼物卡
  Future<OperateResult<void>> deleteGiftCard(String userId, String giftCardId);

  /// 更新礼物卡
  Future<OperateResult<void>> updateGiftCard(
    String userId,
    String giftCardId, {
    String? toUserId,
    String? description,
    int? expiredTime,
    int? sentTime,
    int? receivedTime,
    String? status,
  });

  /// 获取礼物卡列表
  /// [type] 查询类型：received(我收到的), sent(我送出的), all(全部)
  Future<OperateResult<List<GiftCardVO>>> listGiftCards(String userId, {GiftCardQueryType type = GiftCardQueryType.all});

  /// 获取单个礼物卡详情
  Future<OperateResult<GiftCardVO>> getGiftCard(String userId, String giftCardId);

  // ============ 活动记录相关 ============

  /// 创建活动记录
  Future<OperateResult<String>> createActivityRecord(
    String userId,
    String bookId, {
    required String activityName,
    required String recordDate,
    String? location,
    int? createdAt,
  });

  /// 删除活动记录
  Future<OperateResult<void>> deleteActivityRecord(
    String userId, String bookId, String recordId);

  /// 获取活动记录列表（按日期范围筛选）
  Future<OperateResult<List<ActivityRecordVO>>> listActivityRecordsByBook(
    String userId, String bookId, {
    int limit = 200,
    int offset = 0,
    String? startDate,
    String? endDate,
  });

  /// 获取去重的活动名称列表（用于自动补全）
  Future<OperateResult<List<String>>> listDistinctActivityNames(
    String userId, String bookId);

  /// 获取活动统计（按活动名聚合）
  Future<OperateResult<List<ActivityStatisticVO>>> getActivityStatistics(
    String userId, String bookId, {
    required String startDate,
    required String endDate,
  });

  // ============ 油耗记录相关 ============

  /// 创建车辆
  Future<OperateResult<String>> createVehicle(
    String userId, {
    required String plateNumber,
    required String brand,
    required String model,
    String? remark,
    String? defaultFuelGrade,
  });

  /// 删除车辆
  Future<OperateResult<void>> deleteVehicle(String userId, String vehicleId);

  /// 更新车辆
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
  });

  /// 获取车辆列表
  Future<OperateResult<List<VehicleVO>>> listVehicles(String userId);

  /// 创建加油记录
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
    String? station,
    String? remark,
    int? refuelTime,
  });

  /// 删除加油记录
  Future<OperateResult<void>> deleteFuelRecord(String userId, String recordId);

  /// 更新加油记录
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
    String? station,
    String? remark,
    int? refuelTime,
    String? linkedBookId,
    String? linkedItemId,
  });

  /// 获取车辆加油记录列表
  Future<OperateResult<List<FuelRecordVO>>> listFuelRecords(
    String userId,
    String vehicleId, {
    int limit = 20,
    int offset = 0,
    FuelRecordFilterDTO? filter,
  });

  /// 获取加油记录详情
  Future<OperateResult<FuelRecordVO>> getFuelRecord(String userId, String recordId);

  /// 获取车辆油耗统计
  Future<OperateResult<FuelStatisticsVO>> getFuelStatistics(String userId, String vehicleId);
}
