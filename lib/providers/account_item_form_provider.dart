import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:clsswjz/manager/service_manager.dart';
import 'package:clsswjz/models/vo/user_book_vo.dart';
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
              type: 'expense',
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
    _item = AccountItemVO(
      id: _item.id,
      accountBookId: _item.accountBookId,
      type: type,
      amount: _item.amount,
      description: _item.description,
      categoryCode: null,
      accountDate: _item.accountDate,
      fundId: _item.fundId,
      shopCode: _item.shopCode,
      tagCode: _item.tagCode,
      projectCode: _item.projectCode,
      createdBy: _item.createdBy,
      updatedBy: _item.updatedBy,
      createdAt: _item.createdAt,
      updatedAt: _item.updatedAt,
      createdAtString: _item.createdAtString,
      updatedAtString: _item.updatedAtString,
    );
    notifyListeners();
  }

  /// 更新金额
  void updateAmount(double amount) {
    _item = AccountItemVO(
      id: _item.id,
      accountBookId: _item.accountBookId,
      type: _item.type,
      amount: amount,
      description: _item.description,
      categoryCode: _item.categoryCode,
      accountDate: _item.accountDate,
      fundId: _item.fundId,
      shopCode: _item.shopCode,
      tagCode: _item.tagCode,
      projectCode: _item.projectCode,
      createdBy: _item.createdBy,
      updatedBy: _item.updatedBy,
      createdAt: _item.createdAt,
      updatedAt: _item.updatedAt,
      createdAtString: _item.createdAtString,
      updatedAtString: _item.updatedAtString,
    );
    notifyListeners();
  }

  /// 更新描述
  void updateDescription(String? description) {
    _item = AccountItemVO(
      id: _item.id,
      accountBookId: _item.accountBookId,
      type: _item.type,
      amount: _item.amount,
      description: description,
      categoryCode: _item.categoryCode,
      accountDate: _item.accountDate,
      fundId: _item.fundId,
      shopCode: _item.shopCode,
      tagCode: _item.tagCode,
      projectCode: _item.projectCode,
      createdBy: _item.createdBy,
      updatedBy: _item.updatedBy,
      createdAt: _item.createdAt,
      updatedAt: _item.updatedAt,
      createdAtString: _item.createdAtString,
      updatedAtString: _item.updatedAtString,
    );
    notifyListeners();
  }

  /// 更新分类
  void updateCategory(String? code, String? name) {
    _item = AccountItemVO(
      id: _item.id,
      accountBookId: _item.accountBookId,
      type: _item.type,
      amount: _item.amount,
      description: _item.description,
      categoryCode: code,
      categoryName: name,
      accountDate: _item.accountDate,
      fundId: _item.fundId,
      shopCode: _item.shopCode,
      tagCode: _item.tagCode,
      projectCode: _item.projectCode,
      createdBy: _item.createdBy,
      updatedBy: _item.updatedBy,
      createdAt: _item.createdAt,
      updatedAt: _item.updatedAt,
      createdAtString: _item.createdAtString,
      updatedAtString: _item.updatedAtString,
    );
    notifyListeners();
  }

  /// 更新账户
  void updateFund(String? id, String? name) {
    _item = AccountItemVO(
      id: _item.id,
      accountBookId: _item.accountBookId,
      type: _item.type,
      amount: _item.amount,
      description: _item.description,
      categoryCode: _item.categoryCode,
      categoryName: _item.categoryName,
      accountDate: _item.accountDate,
      fundId: id,
      fundName: name,
      shopCode: _item.shopCode,
      tagCode: _item.tagCode,
      projectCode: _item.projectCode,
      createdBy: _item.createdBy,
      updatedBy: _item.updatedBy,
      createdAt: _item.createdAt,
      updatedAt: _item.updatedAt,
      createdAtString: _item.createdAtString,
      updatedAtString: _item.updatedAtString,
    );
    notifyListeners();
  }

  /// 更新商户
  void updateShop(String? code, String? name) {
    _item = AccountItemVO(
      id: _item.id,
      accountBookId: _item.accountBookId,
      type: _item.type,
      amount: _item.amount,
      description: _item.description,
      categoryCode: _item.categoryCode,
      categoryName: _item.categoryName,
      accountDate: _item.accountDate,
      fundId: _item.fundId,
      fundName: _item.fundName,
      shopCode: code,
      shopName: name,
      tagCode: _item.tagCode,
      projectCode: _item.projectCode,
      createdBy: _item.createdBy,
      updatedBy: _item.updatedBy,
      createdAt: _item.createdAt,
      updatedAt: _item.updatedAt,
      createdAtString: _item.createdAtString,
      updatedAtString: _item.updatedAtString,
    );
    notifyListeners();
  }

  /// 更新标签
  void updateTag(String? code, String? name) {
    _item = AccountItemVO(
      id: _item.id,
      accountBookId: _item.accountBookId,
      type: _item.type,
      amount: _item.amount,
      description: _item.description,
      categoryCode: _item.categoryCode,
      categoryName: _item.categoryName,
      accountDate: _item.accountDate,
      fundId: _item.fundId,
      fundName: _item.fundName,
      shopCode: _item.shopCode,
      shopName: _item.shopName,
      tagCode: code,
      tagName: name,
      projectCode: _item.projectCode,
      createdBy: _item.createdBy,
      updatedBy: _item.updatedBy,
      createdAt: _item.createdAt,
      updatedAt: _item.updatedAt,
      createdAtString: _item.createdAtString,
      updatedAtString: _item.updatedAtString,
    );
    notifyListeners();
  }

  /// 更新项目
  void updateProject(String? code, String? name) {
    _item = AccountItemVO(
      id: _item.id,
      accountBookId: _item.accountBookId,
      type: _item.type,
      amount: _item.amount,
      description: _item.description,
      categoryCode: _item.categoryCode,
      categoryName: _item.categoryName,
      accountDate: _item.accountDate,
      fundId: _item.fundId,
      fundName: _item.fundName,
      shopCode: _item.shopCode,
      shopName: _item.shopName,
      tagCode: _item.tagCode,
      tagName: _item.tagName,
      projectCode: code,
      projectName: name,
      createdBy: _item.createdBy,
      updatedBy: _item.updatedBy,
      createdAt: _item.createdAt,
      updatedAt: _item.updatedAt,
      createdAtString: _item.createdAtString,
      updatedAtString: _item.updatedAtString,
    );
    notifyListeners();
  }
}
