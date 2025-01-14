import 'dart:io';

import 'package:clsswjz/drivers/driver_factory.dart';
import 'package:clsswjz/enums/import_source.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import 'package:clsswjz/models/common.dart';
import 'package:clsswjz/models/vo/book_meta.dart';
import 'package:clsswjz/utils/collection_util.dart';
import 'package:csv/csv.dart';

import '../../constants/symbol_type.dart';
import '../../database/database.dart';
import '../../enums/fund_type.dart';
import '../../manager/database_manager.dart';
import '../import.dart';
import 'bohe_record.dart';

class BoheDataImport extends ImportInterface {
  /// 从CSV文件中读取薄荷记账数据
  Future<List<BoheRecord>> readBoheData(File file) async {
    try {
      // 读取CSV文件内容，使用UTF-16编码
      final bytes = await file.readAsBytes();
      // UTF-16文件开头有BOM标记，跳过前两个字节
      final input = String.fromCharCodes(bytes.buffer.asUint16List(2));

      // 使用CSV解析器解析内容
      final rows = const CsvToListConverter(
        fieldDelimiter: '\t', // 使用制表符作为分隔符
        eol: '\n', // 使用换行符作为行结束符
      ).convert(input);

      // 跳过标题行，处理数据行
      final records = rows.skip(1).map((row) {
        // 确保行数据完整
        if (row.length < 19) {
          row.addAll(List.filled(19 - row.length, '')); // 补充缺失的字段为空字符串
        }
        return BoheRecord.fromCsv(row.map((e) => e.toString()).toList());
      }).toList();

      return records;
    } catch (e) {
      rethrow; // 向上抛出异常，由调用者处理
    }
  }

  @override
  Future<void> importData(String who, {required BookMetaVO bookMeta, required ImportSource source, required File file}) async {
    // 读取CSV文件
    final records = await readBoheData(file);
    if (records.isEmpty) {
      return;
    }
    Map<String, AccountCategory> categoryMap = CollectionUtil.toMap(bookMeta.categories, (e) => e.name);
    Map<String, AccountFund> fundMap = CollectionUtil.toMap(bookMeta.funds, (e) => e.name);
    Map<String, AccountShop> shopMap = CollectionUtil.toMap(bookMeta.shops, (e) => e.name);
    Map<String, AccountSymbol> projectMap = CollectionUtil.toMap(
        bookMeta.symbols?.where((e) => SymbolType.fromString(e.symbolType) == SymbolType.project).toList(), (e) => e.name);
    Map<String, AccountSymbol> tagMap =
        CollectionUtil.toMap(bookMeta.symbols?.where((e) => SymbolType.fromString(e.symbolType) == SymbolType.tag).toList(), (e) => e.name);
    await DatabaseManager.db.transaction(() async {
      for (final record in records) {
        AccountCategory? category = await getOrCreateCategory(who, bookMeta.id, categoryMap, record);
        AccountFund? fund = await getOrCreateFund(who, bookMeta.id, fundMap, record);
        AccountShop? shop = await getOrCreateShop(who, bookMeta.id, shopMap, record);
        AccountSymbol? tag = await getOrCreateSymbol(who, bookMeta.id, tagMap, SymbolType.tag, record);
        AccountSymbol? project = await getOrCreateSymbol(who, bookMeta.id, projectMap, SymbolType.project, record);
        await DriverFactory.driver.createItem(who, bookMeta.id,
            amount: record.amount,
            type: record.type,
            description: record.description,
            accountDate: record.date.toString(),
            categoryCode: category?.code,
            fundId: fund?.id,
            shopCode: shop?.code,
            tagCode: tag?.code,
            projectCode: project?.code);
      }
    });
  }

  Future<AccountCategory?> getOrCreateCategory(
      String userId, String bookId, Map<String, AccountCategory> categoryMap, BoheRecord record) async {
    final categoryName = record.category;
    if (categoryName.isEmpty) return null;
    if (categoryMap.containsKey(categoryName)) {
      return categoryMap[categoryName];
    }
    OperateResult<String> result = await DriverFactory.driver
        .createCategory(userId, bookId, name: categoryName, categoryType: record.amount.isNegative ? 'expense' : 'income');
    if (result.ok && result.data != null) {
      AccountCategory? category = await DaoManager.accountCategoryDao.findById(result.data!);
      if (category != null) {
        categoryMap[categoryName] = category;
      }
      return category;
    }
    return null;
  }

  Future<AccountFund?> getOrCreateFund(String userId, String bookId, Map<String, AccountFund> fundMap, BoheRecord record) async {
    final fundName = record.account;
    if (fundName.isEmpty) return null;
    if (fundMap.containsKey(fundName)) {
      return fundMap[fundName];
    }
    OperateResult<String> result = await DriverFactory.driver.createFund(userId, bookId, name: fundName, fundType: FundType.cash);
    if (result.ok && result.data != null) {
      AccountFund? fund = await DaoManager.accountFundDao.findById(result.data!);
      if (fund != null) {
        fundMap[fundName] = fund;
      }
      return fund;
    }
    return null;
  }

  Future<AccountShop?> getOrCreateShop(String userId, String bookId, Map<String, AccountShop> shopMap, BoheRecord record) async {
    final shopName = record.merchant;
    if (shopName.isEmpty) return null;
    if (shopMap.containsKey(shopName)) {
      return shopMap[shopName];
    }
    OperateResult<String> result = await DriverFactory.driver.createShop(userId, bookId, name: shopName);
    if (result.ok && result.data != null) {
      AccountShop? shop = await DaoManager.accountShopDao.findById(result.data!);
      if (shop != null) {
        shopMap[shopName] = shop;
      }
      return shop;
    }
    return null;
  }

  Future<AccountSymbol?> getOrCreateSymbol(
      String userId, String bookId, Map<String, AccountSymbol> symbolMap, SymbolType symbolType, BoheRecord record) async {
    final symbolName = symbolType == SymbolType.tag ? record.tag : record.project;
    if (symbolName.isEmpty) return null;
    if (symbolMap.containsKey(symbolName)) {
      return symbolMap[symbolName];
    }
    OperateResult<String> result = await DriverFactory.driver.createSymbol(userId, bookId, name: symbolName, symbolType: symbolType);
    if (result.ok && result.data != null) {
      AccountSymbol? symbol = await DaoManager.accountSymbolDao.findById(result.data!);
      if (symbol != null) {
        symbolMap[symbolName] = symbol;
      }
      return symbol;
    }
    return null;
  }
}
