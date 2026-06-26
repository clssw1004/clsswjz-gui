import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/account_category_table.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import 'builder.dart';

class CategoryCULog extends LogBuilder<AccountCategoryTableCompanion, String> {
  CategoryCULog() : super() {
    doWith(BusinessType.category);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.categoryDao.insert(data!);
      target(data!.id.value);
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.categoryDao.update(businessId!, data!);
    } else if (operateType == OperateType.batchUpdate) {
      for (int i = 0; i < batchData!.length; i++) {
        await DaoManager.categoryDao.update(
            batchIds![i], batchData![i] as AccountCategoryTableCompanion);
      }
    } else if (operateType == OperateType.batchDelete) {
      for (final id in batchIds!) {
        await DaoManager.categoryDao.delete(id);
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
        'data': (batchData as List<AccountCategoryTableCompanion>)
            .map((c) => AccountCategoryTable.toJsonString(c))
            .toList(),
      });
    }
    if (operateType == OperateType.batchDelete) {
      return jsonEncode({'ids': batchIds});
    }
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      return AccountCategoryTable.toJsonString(
          data as AccountCategoryTableCompanion);
    }
  }

  static CategoryCULog create(String who, String bookId,
      {required String name, required String categoryType, String? code, String? parentId, int sortOrder = 0}) {
    return CategoryCULog()
        .who(who)
        .inBook(bookId)
        .doCreate()
        .withData(AccountCategoryTable.toCreateCompanion(
          who,
          bookId,
          name: name,
          categoryType: categoryType,
          code: code,
          parentId: parentId,
          sortOrder: sortOrder,
        )) as CategoryCULog;
  }

  static CategoryCULog update(String userId, String bookId, String categoryId,
      {String? name, String? parentId, int? sortOrder, String? lastAccountItemAt}) {
    return CategoryCULog()
        .who(userId)
        .inBook(bookId)
        .target(categoryId)
        .doUpdate()
        .withData(AccountCategoryTable.toUpdateCompanion(
          userId,
          name: name,
          parentId: parentId,
          sortOrder: sortOrder,
          lastAccountItemAt: lastAccountItemAt,
        )) as CategoryCULog;
  }

  /// 批量更新（拖拽排序/改父级）
  static CategoryCULog updateBatch(String userId, String bookId,
      {required List<String> ids,
      required List<AccountCategoryTableCompanion> updates}) {
    return CategoryCULog()
        .who(userId)
        .inBook(bookId)
        .target(ids.first)
        .doUpdateBatch()
        .withBatchIds(ids)
        .withBatchData(updates) as CategoryCULog;
  }

  /// 批量删除（调用方需先展开所有子孙节点ID）
  static CategoryCULog deleteBatch(String userId, String bookId,
      {required List<String> ids}) {
    return CategoryCULog()
        .who(userId)
        .inBook(bookId)
        .target(ids.first)
        .doDeleteBatch()
        .withBatchIds(ids) as CategoryCULog;
  }

  static CategoryCULog fromLog(LogSync log) {
    final operateType = OperateType.fromCode(log.operateType);
    switch (operateType) {
      case OperateType.create:
        return CategoryCULog.fromCreateLog(log);
      case OperateType.batchUpdate:
        return CategoryCULog.fromBatchUpdateLog(log);
      case OperateType.batchDelete:
        return CategoryCULog.fromBatchDeleteLog(log);
      default:
        return CategoryCULog.fromUpdateLog(log);
    }
  }

  static CategoryCULog fromCreateLog(LogSync log) {
    return CategoryCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .doCreate()
        .withData(AccountCategory.fromJson(jsonDecode(log.operateData))
            .toCompanion(true)) as CategoryCULog;
  }

  static CategoryCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    return CategoryCULog.update(log.operatorId, log.parentId, log.businessId,
        name: data['name'],
        parentId: data['parentId'] as String?,
        sortOrder: data['sortOrder'] as int?,
        lastAccountItemAt: data['lastAccountItemAt']);
  }

  static CategoryCULog fromBatchUpdateLog(LogSync log) {
    final decoded = jsonDecode(log.operateData) as Map<String, dynamic>;
    final ids = (decoded['ids'] as List).cast<String>();
    final dataList = (decoded['data'] as List).map((d) {
      final map = jsonDecode(d as String) as Map<String, dynamic>;
      return AccountCategoryTable.toUpdateCompanion(
        log.operatorId,
        parentId: map['parentId'] as String?,
        sortOrder: map['sortOrder'] as int?,
      );
    }).toList();
    return CategoryCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .target(ids.first)
        .doUpdateBatch()
        .withBatchIds(ids)
        .withBatchData(dataList) as CategoryCULog;
  }

  static CategoryCULog fromBatchDeleteLog(LogSync log) {
    final decoded = jsonDecode(log.operateData) as Map<String, dynamic>;
    final ids = (decoded['ids'] as List).cast<String>();
    return CategoryCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .target(ids.first)
        .doDeleteBatch()
        .withBatchIds(ids) as CategoryCULog;
  }
}
