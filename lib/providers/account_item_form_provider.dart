import 'package:clsswjz/manager/service_manager.dart';
import 'package:clsswjz/models/vo/user_book_vo.dart';
import 'package:clsswjz/utils/collection_util.dart';
import 'package:flutter/material.dart';
import '../constants/constant.dart';
import '../database/database.dart';
import '../models/vo/account_item_vo.dart';
import '../services/account_item_service.dart';

/// 账目表单状态管理
class AccountItemFormProvider extends ChangeNotifier {
  final AccountItemService _accountItemService = AccountItemService();

  /// 账本数据
  UserBookVO _accountBook;
  UserBookVO get accountBook => _accountBook;

  /// 账目数据
  AccountItemVO _item;
  AccountItemVO get item => _item;

  /// 是否正在保存
  bool _saving = false;
  bool get saving => _saving;

  /// 错误信息
  String? _error;
  String? get error => _error;

  /// 分类列表
  List<dynamic> _categories = [];
  List<dynamic> get categories => _categories;

  /// 账户列表
  List<dynamic> _funds = [];
  List<dynamic> get funds => _funds;

  /// 商户列表
  List<dynamic> _shops = [];
  List<dynamic> get shops => _shops;

  /// 标签列表
  List<dynamic> _tags = [];
  List<dynamic> get tags => _tags;

  /// 项目列表
  List<dynamic> _projects = [];
  List<dynamic> get projects => _projects;

  /// 是否正在加载数据
  bool _loading = false;
  bool get loading => _loading;

  AccountItemFormProvider(UserBookVO accountBook, AccountItemVO item)
      : _accountBook = accountBook,
        _item = item {
    _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    if (_loading) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ServiceManager.accountCategoryService
            .getCategoriesByAccountBook(item.accountBookId),
        ServiceManager.accountFundService
            .getFundsByAccountBook(item.accountBookId),
        ServiceManager.accountShopService
            .getShopsByAccountBook(item.accountBookId),
        ServiceManager.accountSymbolService
            .getSymbolsByAccountBook(item.accountBookId),
      ]);

      _categories = results[0].data ?? [];
      _funds = results[1].data ?? [];
      _shops = results[2].data ?? [];
      final symbols = results[3].data as List<AccountSymbol>;
      _tags = symbols
          .where((symbol) => symbol.symbolType == SYMBOL_TYPE_TAG)
          .toList();
      _projects = symbols
          .where((symbol) => symbol.symbolType == SYMBOL_TYPE_PROJECT)
          .toList();
    } catch (e) {
      _error = '加载数据失败：$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 更新金额
  void updateAmount(double amount) {
    _item.amount = amount;
    notifyListeners();
  }

  /// 更新类型
  void updateType(String type) {
    _item.type = type;
    notifyListeners();
  }

  /// 更新描述
  void updateDescription(String? description) {
    _item.description = description;
    notifyListeners();
  }

  /// 更新分类
  void updateCategory(String? categoryCode, String? categoryName) {
    _item.categoryCode = categoryCode;
    _item.categoryName = categoryName;
    notifyListeners();
  }

  /// 更新账户
  void updateFund(String? fundId, String? fundName) {
    _item.fundId = fundId;
    _item.fundName = fundName;
    notifyListeners();
  }

  /// 更新商户
  void updateShop(String? shopCode, String? shopName) {
    _item.shopCode = shopCode;
    _item.shopName = shopName;
    notifyListeners();
  }

  /// 更新标签
  void updateTag(String? tagCode, String? tagName) {
    _item.tagCode = tagCode;
    _item.tagName = tagName;
    notifyListeners();
  }

  /// 更新项目
  void updateProject(String? projectCode, String? projectName) {
    _item.projectCode = projectCode;
    _item.projectName = projectName;
    notifyListeners();
  }

  /// 保存账目
  Future<bool> save() async {
    if (_saving) return false;

    _saving = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _accountItemService.updateAccountItem(
        id: _item.id,
        userId: _item.updatedBy,
        amount: _item.amount,
        description: _item.description,
        categoryCode: _item.categoryCode,
        fundId: _item.fundId,
        shopCode: _item.shopCode,
        tagCode: _item.tagCode,
        projectCode: _item.projectCode,
      );

      if (result.ok) {
        return true;
      } else {
        _error = result.message;
        return false;
      }
    } catch (e) {
      _error = '保存失败：$e';
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  /// 重新加载数据
  Future<void> reload() => _loadData();
}
