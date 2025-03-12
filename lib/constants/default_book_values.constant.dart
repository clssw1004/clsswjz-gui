import 'dart:ui';


import '../enums/account_type.dart';
import '../enums/debt_type.dart';
import '../enums/fund_type.dart';
import '../enums/symbol_type.dart';

class DefaultBookData {
  final List<CategoryData> category;
  final List<String> shop;
  final List<SymbolData> symbols;
  final List<FundData> funds;

  DefaultBookData({
    this.category = const [],
    this.shop = const [],
    this.symbols = const [],
    this.funds = const [],
  });
}

final _debtCategoryData = [
  CategoryData(
      name: DebtType.borrow.text,
      categoryType: AccountItemType.transfer,
      code: DebtType.borrow.code),
  CategoryData(
      name: DebtType.lend.text,
      categoryType: AccountItemType.transfer,
      code: DebtType.lend.code),
  CategoryData(
      name: DebtType.lend.operationText,
      categoryType: AccountItemType.transfer,
      code: DebtType.lend.operationCategory),
  CategoryData(
      name: DebtType.borrow.operationText,
      categoryType: AccountItemType.transfer,
      code: DebtType.borrow.operationCategory),
];

class CategoryData {
  final String name;
  final String? code;
  final AccountItemType categoryType;

  CategoryData({required this.name, required this.categoryType, this.code});
}

class SymbolData {
  final String name;
  final SymbolType symbolType;

  SymbolData({required this.name, required this.symbolType});
}

class FundData {
  final String name;
  final FundType fundType;

  FundData({required this.name, required this.fundType});
}

final _defaultBookDataCN = DefaultBookData(
  category: [
    CategoryData(name: '餐饮', categoryType: AccountItemType.expense),
    CategoryData(name: '购物', categoryType: AccountItemType.expense),
    CategoryData(name: '交通', categoryType: AccountItemType.expense),
    CategoryData(name: '娱乐', categoryType: AccountItemType.expense),
    CategoryData(name: '其他', categoryType: AccountItemType.expense),
    CategoryData(name: '工资', categoryType: AccountItemType.income),
    CategoryData(name: '奖金', categoryType: AccountItemType.income),
    CategoryData(name: '投资', categoryType: AccountItemType.income),
    CategoryData(name: '其他', categoryType: AccountItemType.income),
    ..._debtCategoryData,
  ],
  shop: const ['淘宝', '京东', '美团', '饿了么'],
  symbols: [
    SymbolData(name: '外卖', symbolType: SymbolType.tag),
    SymbolData(name: '网购', symbolType: SymbolType.tag),
    SymbolData(name: '线下', symbolType: SymbolType.tag),
    SymbolData(name: '恩格尔系数', symbolType: SymbolType.project)
  ],
  funds: [
    FundData(name: '现金', fundType: FundType.cash),
    FundData(name: '信用卡', fundType: FundType.creditCard),
    FundData(name: '支付宝', fundType: FundType.alipay),
    FundData(name: '微信', fundType: FundType.wechat),
  ],
);

final _defaultBookDataEN = DefaultBookData(
  category: [
    CategoryData(name: 'Food', categoryType: AccountItemType.expense),
    CategoryData(name: 'Shopping', categoryType: AccountItemType.expense),
    CategoryData(name: 'Transportation', categoryType: AccountItemType.expense),
    CategoryData(name: 'Entertainment', categoryType: AccountItemType.expense),
    CategoryData(name: 'Other', categoryType: AccountItemType.expense),
    CategoryData(name: 'Salary', categoryType: AccountItemType.income),
    CategoryData(name: 'Bonus', categoryType: AccountItemType.income),
    CategoryData(name: 'Investment', categoryType: AccountItemType.income),
    CategoryData(name: 'Other', categoryType: AccountItemType.income),
    ..._debtCategoryData,
  ],
  shop: const ['AMAZON'],
  symbols: [
    SymbolData(name: 'Takeaway', symbolType: SymbolType.tag),
    SymbolData(name: 'Grid', symbolType: SymbolType.tag),
    SymbolData(name: 'Offline', symbolType: SymbolType.tag)
  ],
  funds: [
    FundData(name: 'Cash', fundType: FundType.cash),
    FundData(name: 'Credit Card', fundType: FundType.creditCard),
    FundData(name: 'Alipay', fundType: FundType.alipay),
    FundData(name: 'Wechat', fundType: FundType.wechat),
  ],
);

DefaultBookData getDefaultDataByLocale(Locale locale) {
  if (locale.languageCode == 'zh') {
    return _defaultBookDataCN;
  } else {
    return _defaultBookDataEN;
  }
}
