import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:clsswjz/manager/service_manager.dart';
import 'package:clsswjz/models/vo/user_book_vo.dart';
import 'package:flutter/material.dart';
import '../constants/constant.dart';
import '../database/database.dart';
import '../enums/account_type.dart';
import '../models/vo/account_item_vo.dart';
import '../services/account_item_service.dart';

/// 账目表单状态管理
class AccountItemFormProvider extends ChangeNotifier {
  final AccountItemService _accountItemService = AccountItemService();

  /// 账本数据
  final UserBookVO _accountBook;
  UserBookVO get accountBook => _accountBook;

  /// 账目数据
  AccountItemVO _item;
  AccountItemVO get item => _item;

  /// 是否为新增
  bool get isNew => _item.id.isEmpty;

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

  AccountItemFormProvider(UserBookVO accountBook, AccountItemVO? item)
      : _accountBook = accountBook,
        _item = item ??
            AccountItemVO(
              id: '',
              accountBookId: accountBook.id,
              type: AccountItemType.expense.code,
              amount: 0,
              accountDate: DateTime.now().toString().substring(0, 10),
              createdBy: AppConfigManager.instance.userId!,
              updatedBy: AppConfigManager.instance.userId!,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
              createdAtString: DateTime.now().toString(),
              updatedAtString: DateTime.now().toString(),
            ) {
    _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    if (_loading) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        loadCategories(),
        loadFunds(),
        loadShops(),
        loadSymbols(),
      ]);
    } catch (e) {
      _error = '加载数据失败：$e';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 加载分类
  Future<void> loadCategories() async {
    final result = await ServiceManager.accountCategoryService
        .getCategoriesByAccountBook(item.accountBookId);
    _categories = result.data ?? [];
    notifyListeners();
  }

  /// 加载账户
  Future<void> loadFunds() async {
    final result = await ServiceManager.accountFundService
        .getFundsByAccountBook(item.accountBookId);
    _funds = result.data ?? [];
    notifyListeners();
  }

  /// 加载商户
  Future<void> loadShops() async {
    final result = await ServiceManager.accountShopService
        .getShopsByAccountBook(item.accountBookId);
    _shops = result.data ?? [];
    notifyListeners();
  }

  /// 加载标签和项目
  Future<void> loadSymbols() async {
    final result = await ServiceManager.accountSymbolService
        .getSymbolsByAccountBook(item.accountBookId);
    final symbols = result.data as List<AccountSymbol>;
    _tags = symbols
        .where((symbol) => symbol.symbolType == SYMBOL_TYPE_TAG)
        .toList();
    _projects = symbols
        .where((symbol) => symbol.symbolType == SYMBOL_TYPE_PROJECT)
        .toList();
    notifyListeners();
  }

  /// 加载标签
  Future<void> loadTags() async {
    final result = await ServiceManager.accountSymbolService
        .getSymbolsByType(item.accountBookId, SYMBOL_TYPE_TAG);
    _tags = result.data ?? [];
    notifyListeners();
  }

  /// 加载项目
  Future<void> loadProjects() async {
    final result = await ServiceManager.accountSymbolService
        .getSymbolsByType(item.accountBookId, SYMBOL_TYPE_PROJECT);
    _projects = result.data ?? [];
    notifyListeners();
  }

  /// 保存账目
  Future<bool> save() async {
    if (_saving) return false;

    _saving = true;
    _error = null;
    notifyListeners();

    try {
      final result = isNew
          ? await _accountItemService.createAccountItem(
              accountBookId: _item.accountBookId,
              userId: _item.updatedBy,
              type: _item.type,
              amount: _item.amount,
              description: _item.description,
              categoryCode: _item.categoryCode,
              fundId: _item.fundId,
              shopCode: _item.shopCode,
              tagCode: _item.tagCode,
              projectCode: _item.projectCode,
              accountDate: _item.accountDate,
            )
          : await _accountItemService.updateAccountItem(
              id: _item.id,
              userId: _item.updatedBy,
              amount: _item.amount,
              description: _item.description,
              categoryCode: _item.categoryCode,
              fundId: _item.fundId,
              shopCode: _item.shopCode,
              tagCode: _item.tagCode,
              projectCode: _item.projectCode,
              accountDate: _item.accountDate,
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

  /// 更新类型
  void updateType(String type) {
    _item = _item.copyWith(
      type: type,
      categoryCode: null,
    );
    notifyListeners();
  }

  /// 更新金额
  void updateAmount(double amount) {
    _item = _item.copyWith(amount: amount);
    notifyListeners();
  }

  /// 更新描述
  void updateDescription(String? description) {
    _item = _item.copyWith(description: description);
    notifyListeners();
  }

  /// 更新分类
  void updateCategory(String? code, String? name) {
    _item = _item.copyWith(
      categoryCode: code,
      categoryName: name,
    );
    notifyListeners();
  }

  /// 更新账户
  void updateFund(String? id, String? name) {
    _item = _item.copyWith(
      fundId: id,
      fundName: name,
    );
    notifyListeners();
  }

  /// 更新商户
  void updateShop(String? code, String? name) {
    _item = _item.copyWith(
      shopCode: code,
      shopName: name,
    );
    notifyListeners();
  }

  /// 更新标签
  void updateTag(String? code, String? name) {
    _item = _item.copyWith(
      tagCode: code,
      tagName: name,
    );
    notifyListeners();
  }

  /// 更新项目
  void updateProject(String? code, String? name) {
    _item = _item.copyWith(
      projectCode: code,
      projectName: name,
    );
    notifyListeners();
  }
}
