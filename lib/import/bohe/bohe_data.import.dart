import 'dart:io';

import 'package:clsswjz/drivers/driver_factory.dart';
import 'package:clsswjz/enums/import_source.dart';
import 'package:clsswjz/manager/dao_manager.dart';
import 'package:clsswjz/models/common.dart';
import 'package:clsswjz/models/vo/book_meta.dart';
import 'package:clsswjz/utils/collection_util.dart';
import 'package:csv/csv.dart';

import '../../enums/account_type.dart';
import '../../enums/symbol_type.dart';
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
  Future<void> importData(String who, Function(double percent, String message) importProgress,
      {required BookMetaVO bookMeta, required ImportSource source, required File file}) async {
    // 读取CSV文件
    final records = await readBoheData(file);
    if (records.isEmpty) {
      return;
    }
    Map<String, AccountCategory> categoryMap = CollectionUtil.toMap(bookMeta.categories, (e) => e.name);
    Map<String, AccountFund> fundMap = CollectionUtil.toMap(bookMeta.funds, (e) => e.name);
    Map<String, AccountShop> shopMap = CollectionUtil.toMap(bookMeta.shops, (e) => e.name);
    Map<String, AccountSymbol> projectMap = CollectionUtil.toMap(
        bookMeta.symbols?.where((e) => SymbolType.fromCode(e.symbolType) == SymbolType.project).toList(), (e) => e.name);
    Map<String, AccountSymbol> tagMap =
        CollectionUtil.toMap(bookMeta.symbols?.where((e) => SymbolType.fromCode(e.symbolType) == SymbolType.tag).toList(), (e) => e.name);
    await DatabaseManager.db.transaction(() async {
      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        final percent = i / records.length;
        await progressDelegate(importProgress, percent, '正在导入第${i + 1}条记录');
        AccountCategory? category = await getOrCreateCategory(who, (String message) => progressDelegate(importProgress, percent, message),
            bookId: bookMeta.id, categoryMap: categoryMap, record: record);
        AccountFund? fund = await getOrCreateFund(who, (String message) => progressDelegate(importProgress, percent, message),
            bookId: bookMeta.id, fundMap: fundMap, record: record);
        AccountShop? shop = await getOrCreateShop(who, (String message) => progressDelegate(importProgress, percent, message),
            bookId: bookMeta.id, shopMap: shopMap, record: record);
        AccountSymbol? tag = await getOrCreateSymbol(who, (String message) => progressDelegate(importProgress, percent, message),
            bookId: bookMeta.id, symbolMap: tagMap, symbolType: SymbolType.tag, record: record);
        AccountSymbol? project = await getOrCreateSymbol(who, (String message) => progressDelegate(importProgress, percent, message),
            bookId: bookMeta.id, symbolMap: projectMap, symbolType: SymbolType.project, record: record);
        await DriverFactory.driver.createItem(who, bookMeta.id,
            amount: record.amount,
            type: AccountItemType.fromCode(record.type) ?? AccountItemType.expense,
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

  Future<AccountCategory?> getOrCreateCategory(String userId, Function(String message) importProgress,
      {required String bookId, required Map<String, AccountCategory> categoryMap, required BoheRecord record}) async {
    final categoryName = record.category;
    if (categoryName.isEmpty) return null;
    if (categoryMap.containsKey(categoryName)) {
      return categoryMap[categoryName];
    }
    importProgress('正在创建分类 `$categoryName`');
    OperateResult<String> result = await DriverFactory.driver.createCategory(userId, bookId,
        name: categoryName, categoryType: record.amount.isNegative ? AccountItemType.expense.code : AccountItemType.income.code);
    if (result.ok && result.data != null) {
      AccountCategory? category = await DaoManager.categoryDao.findById(result.data!);
      if (category != null) {
        categoryMap[categoryName] = category;
      }
      importProgress('创建分类 `$categoryName` 成功');
      return category;
    }
    return null;
  }

  Future<AccountFund?> getOrCreateFund(String userId, Function(String message) importProgress,
      {required String bookId, required Map<String, AccountFund> fundMap, required BoheRecord record}) async {
    final fundName = record.account;
    if (fundName.isEmpty) return null;
    if (fundMap.containsKey(fundName)) {
      return fundMap[fundName];
    }
    importProgress('正在创建账户 `$fundName`');
    OperateResult<String> result = await DriverFactory.driver.createFund(userId, bookId, name: fundName, fundType: FundType.cash);
    if (result.ok && result.data != null) {
      AccountFund? fund = await DaoManager.fundDao.findById(result.data!);
      if (fund != null) {
        fundMap[fundName] = fund;
      }
      importProgress('创建账户 `$fundName` 成功');
      return fund;
    }
    return null;
  }

  Future<AccountShop?> getOrCreateShop(String userId, Function(String message) importProgress,
      {required String bookId, required Map<String, AccountShop> shopMap, required BoheRecord record}) async {
    final shopName = record.merchant;
    if (shopName.isEmpty) return null;
    if (shopMap.containsKey(shopName)) {
      return shopMap[shopName];
    }
    importProgress('正在创建商户 `$shopName`');
    OperateResult<String> result = await DriverFactory.driver.createShop(userId, bookId, name: shopName);
    if (result.ok && result.data != null) {
      AccountShop? shop = await DaoManager.shopDao.findById(result.data!);
      if (shop != null) {
        shopMap[shopName] = shop;
      }
      importProgress('创建商户 `$shopName` 成功');
      return shop;
    }
    return null;
  }

  Future<AccountSymbol?> getOrCreateSymbol(String userId, Function(String message) importProgress,
      {required String bookId,
      required Map<String, AccountSymbol> symbolMap,
      required SymbolType symbolType,
      required BoheRecord record}) async {
    final symbolName = symbolType == SymbolType.tag ? record.tag : record.project;
    if (symbolName.isEmpty) return null;
    if (symbolMap.containsKey(symbolName)) {
      return symbolMap[symbolName];
    }
    importProgress('正在创建 `${symbolType.name}` `$symbolName`');
    OperateResult<String> result = await DriverFactory.driver.createSymbol(userId, bookId, name: symbolName, symbolType: symbolType);
    if (result.ok && result.data != null) {
      AccountSymbol? symbol = await DaoManager.symbolDao.findById(result.data!);
      if (symbol != null) {
        symbolMap[symbolName] = symbol;
      }
      importProgress('创建 `${symbolType.name}` `$symbolName` 成功');
      return symbol;
    }
    return null;
  }
}
