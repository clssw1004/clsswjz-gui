import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../database/database.dart';
import '../../../../database/tables/account_shop_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import '../../../../utils/date_util.dart';
import 'builder.dart';

class ShopCULog extends LogBuilder<AccountShopTableCompanion, String> {
  ShopCULog() : super() {
    doWith(BusinessType.shop);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.shopDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.shopDao.update(businessId!, data!);
    } else if (operateType == OperateType.batchUpdate) {
      for (int i = 0; i < batchData!.length; i++) {
        await DaoManager.shopDao.update(
            batchIds![i], batchData![i] as AccountShopTableCompanion);
      }
    } else if (operateType == OperateType.batchDelete) {
      for (final id in batchIds!) {
        await DaoManager.shopDao.delete(id);
      }
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null && (batchData == null || batchIds == null)) return '';
    if (operateType == OperateType.batchUpdate) {
      return jsonEncode({
        'ids': batchIds,
        'data': (batchData as List<AccountShopTableCompanion>)
            .map((c) => AccountShopTable.toJsonString(c))
            .toList(),
      });
    }
    if (operateType == OperateType.batchDelete) {
      return jsonEncode({'ids': batchIds});
    }
    return AccountShopTable.toJsonString(data as AccountShopTableCompanion);
  }

  static ShopCULog create(String who, String bookId,
      {required String name, String? parentId, int sortOrder = 0}) {
    return ShopCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(AccountShopTable.toCreateCompanion(
          who,
          bookId,
          name: name,
          parentId: parentId,
          sortOrder: sortOrder,
        )) as ShopCULog;
  }

  static ShopCULog update(String userId, String bookId, String shopId,
      {String? name, String? parentId, int? sortOrder, String? lastAccountItemAt}) {
    return ShopCULog()
        .who(userId)
        .inBook(bookId)
        .target(shopId)
        .doUpdate()
        .withData(AccountShopTable.toUpdateCompanion(
          userId,
          name: name,
          parentId: parentId,
          sortOrder: sortOrder,
          lastAccountItemAt: lastAccountItemAt,
        )) as ShopCULog;
  }

  static ShopCULog fromCreateLog(LogSync log) {
    final data = jsonDecode(log.operateData) as Map<String, dynamic>;
    data.putIfAbsent('sortOrder', () => 0);
    return ShopCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .doCreate()
        .withData(AccountShop.fromJson(data).toCompanion(true)) as ShopCULog;
  }

  static ShopCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return ShopCULog.update(log.operatorId, log.parentId, log.businessId,
        name: data['name'],
        parentId: data['parentId'] as String?,
        sortOrder: data['sortOrder'] as int?,
        lastAccountItemAt: data['lastAccountItemAt']);
  }

  static ShopCULog fromBatchUpdateLog(LogSync log) {
    final decoded = jsonDecode(log.operateData) as Map<String, dynamic>;
    final ids = (decoded['ids'] as List).cast<String>();
    final dataList = (decoded['data'] as List).map((d) {
      final map = jsonDecode(d as String) as Map<String, dynamic>;
      return AccountShopTableCompanion(
        updatedBy: Value(log.operatorId),
        updatedAt: Value(DateUtil.now()),
        parentId: Value(map['parentId'] as String?),
        sortOrder: Value.absentIfNull(map['sortOrder'] as int?),
        createdBy: const Value.absent(),
        createdAt: const Value.absent(),
      );
    }).toList();
    return ShopCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .target(ids.first)
        .doUpdateBatch()
        .withBatchIds(ids)
        .withBatchData(dataList) as ShopCULog;
  }

  static ShopCULog fromBatchDeleteLog(LogSync log) {
    final decoded = jsonDecode(log.operateData) as Map<String, dynamic>;
    final ids = (decoded['ids'] as List).cast<String>();
    return ShopCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .target(ids.first)
        .doDeleteBatch()
        .withBatchIds(ids) as ShopCULog;
  }

  /// 批量更新（拖拽排序/改父级）
  static ShopCULog updateBatch(String userId, String bookId,
      {required List<String> ids,
      required List<AccountShopTableCompanion> updates}) {
    return ShopCULog()
        .who(userId)
        .inBook(bookId)
        .target(ids.first)
        .doUpdateBatch()
        .withBatchIds(ids)
        .withBatchData(updates) as ShopCULog;
  }

  /// 批量删除（调用方需先展开所有子孙节点ID）
  static ShopCULog deleteBatch(String userId, String bookId,
      {required List<String> ids}) {
    return ShopCULog()
        .who(userId)
        .inBook(bookId)
        .target(ids.first)
        .doDeleteBatch()
        .withBatchIds(ids) as ShopCULog;
  }

  static ShopCULog fromLog(LogSync log) {
    final operateType = OperateType.fromCode(log.operateType);
    switch (operateType) {
      case OperateType.create:
        return ShopCULog.fromCreateLog(log);
      case OperateType.batchUpdate:
        return ShopCULog.fromBatchUpdateLog(log);
      case OperateType.batchDelete:
        return ShopCULog.fromBatchDeleteLog(log);
      default:
        return ShopCULog.fromUpdateLog(log);
    }
  }
}
