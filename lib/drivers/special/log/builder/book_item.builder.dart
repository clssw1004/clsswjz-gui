import 'dart:convert';

import '../../../../database/database.dart';
import '../../../../database/tables/account_item_table.dart';
import '../../../../database/tables/item_rel_field_table.dart';
import '../../../../enums/account_type.dart';
import '../../../../enums/business_type.dart';
import '../../../../enums/operate_type.dart';
import '../../../../manager/dao_manager.dart';
import '../../../../models/vo/attachment_vo.dart';
import 'builder.dart';

class ItemCULog extends LogBuilder<AccountItemTableCompanion, String> {
  List<String>? _tagCodes;

  ItemCULog() : super() {
    doWith(BusinessType.item);
  }

  @override
  Future<String> executeLog() async {
    if (operateType == OperateType.create) {
      await DaoManager.itemDao.insert(data!);
      target(data!.id.value);
      if (_tagCodes != null) {
        for (final code in _tagCodes!) {
          await DaoManager.itemRelFieldDao.insert(
            ItemRelFieldTable.toCreateCompanion(
              itemId: data!.id.value,
              fieldCode: 'TAG',
              fieldValue: code,
            ),
          );
        }
      }
      return data!.id.value;
    } else if (operateType == OperateType.update) {
      await DaoManager.itemDao.update(businessId!, data!);
      await DaoManager.itemRelFieldDao.deleteByItemAndCode(businessId!, 'TAG');
      if (_tagCodes != null) {
        for (final code in _tagCodes!) {
          await DaoManager.itemRelFieldDao.insert(
            ItemRelFieldTable.toCreateCompanion(
              itemId: businessId!,
              fieldCode: 'TAG',
              fieldValue: code,
            ),
          );
        }
      }
    }
    return businessId!;
  }

  @override
  String data2Json() {
    if (data == null) return '';
    if (operateType == OperateType.delete) {
      return data!.toString();
    } else {
      final json =
          AccountItemTable.toJsonString(data as AccountItemTableCompanion);
      final map = jsonDecode(json) as Map<String, dynamic>;
      map.remove('tagCode');
      if (_tagCodes != null && _tagCodes!.isNotEmpty) {
        map['tagCodes'] = _tagCodes;
      }
      return jsonEncode(map);
    }
  }

  static ItemCULog create(String who, String bookId,
      {required double amount,
      String? description,
      required AccountItemType type,
      String? categoryCode,
      required String accountDate,
      String? fundId,
      String? shopCode,
      List<String>? tagCodes,
      String? projectCode,
      String? source,
      String? sourceId,
      List<AttachmentVO>? attachments}) {
    final builder = ItemCULog().who(who).inBook(bookId).doCreate().withData(
        AccountItemTable.toCreateCompanion(who, bookId,
            amount: amount,
            description: description,
            type: type,
            categoryCode: categoryCode,
            accountDate: accountDate,
            fundId: fundId,
            shopCode: shopCode,
            projectCode: projectCode,
            source: source,
            sourceId: sourceId)) as ItemCULog;
    builder._tagCodes = tagCodes;
    return builder;
  }

  static ItemCULog update(String userId, String bookId, String itemId,
      {double? amount,
      String? description,
      AccountItemType? type,
      String? categoryCode,
      String? accountDate,
      String? fundId,
      String? shopCode,
      List<String>? tagCodes,
      String? projectCode}) {
    final builder = ItemCULog()
        .who(userId)
        .inBook(bookId)
        .target(itemId)
        .doUpdate()
        .withData(AccountItemTable.toUpdateCompanion(userId,
            amount: amount,
            description: description,
            type: type,
            categoryCode: categoryCode,
            accountDate: accountDate,
            fundId: fundId,
            shopCode: shopCode,
            projectCode: projectCode)) as ItemCULog;
    builder._tagCodes = tagCodes;
    return builder;
  }

  static ItemCULog fromCreateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    List<String>? tagCodes;
    if (data.containsKey('tagCodes')) {
      tagCodes = (data['tagCodes'] as List).cast<String>();
    } else if (data.containsKey('tagCode') && data['tagCode'] != null) {
      tagCodes = [data['tagCode'] as String];
    }
    data.remove('tagCode');
    data.remove('tagCodes');
    final builder = ItemCULog()
        .who(log.operatorId)
        .inBook(log.parentId)
        .doCreate()
        .withData(AccountItem.fromJson(data).toCompanion(true)) as ItemCULog;
    builder._tagCodes = tagCodes;
    return builder;
  }

  static ItemCULog fromUpdateLog(LogSync log) {
    Map<String, dynamic> data = jsonDecode(log.operateData);
    List<String>? tagCodes;
    if (data.containsKey('tagCodes')) {
      tagCodes = (data['tagCodes'] as List).cast<String>();
    } else if (data.containsKey('tagCode') && data['tagCode'] != null) {
      tagCodes = [data['tagCode'] as String];
    }
    data.remove('tagCode');
    data.remove('tagCodes');
    final builder = ItemCULog.update(
      log.operatorId,
      log.parentId,
      log.businessId,
      amount: data['amount'],
      description: data['description'],
      type:
          data['type'] != null ? AccountItemType.fromCode(data['type']) : null,
      categoryCode: data['categoryCode'],
      accountDate: data['accountDate'],
      fundId: data['fundId'],
      shopCode: data['shopCode'],
      projectCode: data['projectCode'],
    );
    builder._tagCodes = tagCodes;
    return builder;
  }

  static ItemCULog fromLog(LogSync log) {
    return (OperateType.fromCode(log.operateType) == OperateType.create
        ? ItemCULog.fromCreateLog(log)
        : ItemCULog.fromUpdateLog(log));
  }
}
