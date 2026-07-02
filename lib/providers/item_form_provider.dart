import 'dart:async';

import 'package:flutter/material.dart';
import '../enums/business_type.dart';
import '../enums/operate_type.dart';
import '../enums/symbol_type.dart';
import '../database/database.dart';
import '../enums/account_type.dart';
import '../enums/debt_type.dart';
import '../events/event_bus.dart';
import '../events/special/event_book.dart';
import '../manager/dao_manager.dart';
import '../models/common.dart';
import '../models/vo/book_meta.dart';
import '../models/vo/user_book_vo.dart';
import '../models/vo/user_item_vo.dart';
import '../utils/date_util.dart';
import '../models/vo/attachment_vo.dart';
import '../manager/app_config_manager.dart';
import '../drivers/driver_factory.dart';
import '../manager/service_manager.dart';
import '../services/rule_engine.dart';
import '../services/bookkeeping_rule_service.dart';
import '../models/vo/bookkeeping_rule_vo.dart';

/// 账目表单状态管理
class ItemFormProvider extends ChangeNotifier {
  /// 账本数据
  final BookMetaVO _bookMeta;
  BookMetaVO get bookMeta => _bookMeta;

  /// 账目数据
  UserItemVO _item;
  UserItemVO get item => _item;

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

  /// 所有账本列表
  List<UserBookVO> _allBooks = [];
  List<UserBookVO> get allBooks => _allBooks;

  /// 当前选中的账本
  UserBookVO? get currentBook =>
      _allBooks.cast<UserBookVO?>().firstWhere(
        (b) => b?.id == _item.accountBookId,
        orElse: () => null,
      );

  /// 附件列表
  List<AttachmentVO> _attachments = [];
  List<AttachmentVO> get attachments => _attachments;

  /// 是否正在加载数据
  bool _loading = false;
  bool get loading => _loading;

  /// 规则引擎是否已初始化
  bool _ruleEngineInitialized = false;

  /// 当前账本的激活规则列表
  List<BookkeepingRuleVO> _activeRules = [];

  /// 是否启用自动规则
  bool _ruleEnabled = true;
  bool get ruleEnabled => _ruleEnabled;

  ItemFormProvider(BookMetaVO bookMeta, UserItemVO? item)
      : _bookMeta = bookMeta,
        _item = item ??
            UserItemVO(
              id: '',
              accountBookId: bookMeta.id,
              fundId: bookMeta.defaultFundId,
              type: AccountItemType.expense.code,
              amount: 0,
              accountDate: DateTime.now().toString().substring(0, 10),
              createdBy: AppConfigManager.instance.userId,
              updatedBy: AppConfigManager.instance.userId,
              createdAt: DateUtil.now(),
              updatedAt: DateUtil.now(),
              createdAtString: DateTime.now().toString(),
              updatedAtString: DateTime.now().toString(),
            ) {
    _init();
  }

  Future<void> _init() async {
    // Init rule engine once
    if (!_ruleEngineInitialized) {
      RuleEngine.init();
      _ruleEngineInitialized = true;
    }

    _loading = true;
    notifyListeners();

    await Future.wait([
      loadBooks(),
      loadCategories(item.accountBookId, item.type),
      loadFunds(),
      loadShops(item.accountBookId),
      loadTags(),
      loadProjects(),
      _loadActiveRules(),
    ]);

    _loading = false;
    notifyListeners();
  }

  /// 加载账本列表
  Future<void> loadBooks() async {
    final result = await DriverFactory.driver.listBooksByUser(
      AppConfigManager.instance.userId,
    );
    if (result.ok) {
      _allBooks = result.data ?? [];
    }
  }

  /// 切换账本（仅新增模式可用）
  void changeBook(UserBookVO book) {
    _item = _item.copyWith(
      accountBookId: book.id,
      fundId: book.defaultFundId ?? _item.fundId,
    );
    notifyListeners();
  }

  /// 更新类型并保存
  Future<void> updateTypeAndSave(AccountItemType type) async {
    updateType(type);
    await partUpdate(type: type);
  }

  /// 更新金额并保存
  Future<void> updateAmountAndSave(double amount) async {
    updateAmount(amount);
    await partUpdate(amount: _item.amount);
  }

  /// 更新分类并保存
  Future<void> updateCategoryAndSave(String? code, String? name) async {
    updateCategory(code, name);
    await partUpdate(categoryCode: code);
  }

  /// 更新账户并保存
  Future<void> updateFundAndSave(String? id, String? name) async {
    updateFund(id, name);
    await partUpdate(fundId: id);
  }

  /// 更新商户并保存
  Future<void> updateShopAndSave(String? code, String? name) async {
    updateShop(code, name);
    await partUpdate(shopCode: code);
  }

  /// 更新标签并保存
  Future<void> updateTagsAndSave(List<AccountSymbol> tags) async {
    updateTags(tags);
    await partUpdate(tagCodes: tags.map((t) => t.code).toList());
  }

  /// 更新项目并保存
  Future<void> updateProjectAndSave(String? code, String? name) async {
    updateProject(code, name);
    await partUpdate(projectCode: code);
  }

  /// 更新描述并保存
  Future<void> updateDescriptionAndSave(String? description) async {
    updateDescription(description);
    await partUpdate(description: description);
  }

  /// 更新日期时间并保存
  Future<void> updateDateTimeAndSave(String date, String time) async {
    _item.updateDateTime(date, time);
    await partUpdate(accountDate: '$date $time');
  }

  /// 更新附件并保存
  Future<void> updateAttachmentsAndSave(List<AttachmentVO> attachments) async {
    updateAttachments(attachments);
    await partUpdate(attachments: attachments);
  }

  /// 加载分类
  Future<void> loadCategories(String bookId, String type) async {
    final result = await DriverFactory.driver.listAllCategoriesByBook(
      AppConfigManager.instance.userId,
      bookId,
      categoryType: type,
    );
    if (result.ok) {
      _categories = result.data ?? [];
      notifyListeners();
    }
  }

  /// 加载账户
  Future<void> loadFunds() async {
    final result = await DriverFactory.driver
        .listFundsByBook(AppConfigManager.instance.userId, item.accountBookId);
    _funds = result.data ?? [];
    notifyListeners();
  }

  /// 加载商户
  Future<void> loadShops(String bookId) async {
    final result = await DriverFactory.driver.listAllShopsByBook(
      AppConfigManager.instance.userId,
      bookId,
    );
    if (result.ok) {
      _shops = result.data ?? [];
      notifyListeners();
    }
  }

  /// 加载标签和项目
  Future<void> loadSymbols() async {
    final result = await DriverFactory.driver.listSymbolsByBook(
        AppConfigManager.instance.userId, item.accountBookId);
    final symbols = result.data as List<AccountSymbol>;
    _tags = symbols
        .where((symbol) => symbol.symbolType == SymbolType.tag.code)
        .toList();
    _projects = symbols
        .where((symbol) => symbol.symbolType == SymbolType.project.code)
        .toList();
    notifyListeners();
  }

  /// 加载标签
  Future<void> loadTags() async {
    final result = await DriverFactory.driver.listSymbolsByBook(
        AppConfigManager.instance.userId, item.accountBookId,
        symbolType: SymbolType.tag);
    _tags = result.data ?? [];
    notifyListeners();
  }

  /// 加载项目
  Future<void> loadProjects() async {
    final result = await DriverFactory.driver.listSymbolsByBook(
      AppConfigManager.instance.userId,
      item.accountBookId,
      symbolType: SymbolType.project,
    );
    _projects = result.data ?? [];
    notifyListeners();
  }

  /// 加载附件列表
  Future<void> loadAttachments() async {
    if (item.id.isEmpty) return;

    _attachments =
        await ServiceManager.attachmentService.getAttachmentsByBusiness(
      BusinessType.item,
      item.id,
    );
    notifyListeners();
  }

  /// 加载当前账本的激活规则
  Future<void> _loadActiveRules() async {
    try {
      final rules = await DaoManager.bookkeepingRuleDao.findByBookWithFilter(
        _item.accountBookId,
        isActive: true,
      );
      _activeRules = rules
          .map((r) => BookkeepingRuleVO.fromBookkeepingRule(r))
          .toList();
      BookkeepingRuleService.sortByPriority(_activeRules);
    } catch (_) {
      _activeRules = [];
    }
  }

  /// 应用规则引擎
  void _applyRules(String changedField) {
    if (!_ruleEnabled || _activeRules.isEmpty) return;

    final engineModifiedFields = RuleEngine.evaluate(
      changedField: changedField,
      item: _item,
      rules: _activeRules,
    );

    if (engineModifiedFields.isNotEmpty) {
      // 规则引擎写入的标签只有 code 没有 name，用已加载列表解析真实名称
      bool tagsModified = false;
      if (engineModifiedFields.contains('tagCode') ||
          engineModifiedFields.contains('tagCodes')) {
        final resolved = _item.tags.map((t) {
          final match = _tags.cast<AccountSymbol>().where(
            (a) => a.code == t.code,
          ).firstOrNull;
          return match ?? t;
        }).toList();
        _item.tags = resolved;
        tagsModified = true;
      }
      notifyListeners();
      // 编辑模式（已有 ID）下，规则触发的标签变更需落库
      if (tagsModified && _item.id.isNotEmpty) {
        unawaited(partUpdate(tagCodes: _item.tags.map((t) => t.code).toList()));
      }
    }
  }

  /// 保存账目
  Future<bool> create() async {
    final userId = AppConfigManager.instance.userId;
    OperateResult result;
    // 保存账目信息
    result = await DriverFactory.driver.createItem(
      userId,
      _item.accountBookId,
      type: AccountItemType.fromCode(item.type) ?? AccountItemType.expense,
      amount: _item.amount,
      description: _item.description,
      categoryCode: _item.categoryCode,
      fundId: _item.fundId,
      shopCode: _item.shopCode,
      tagCodes: _item.tags.map((t) => t.code).toList(),
      projectCode: _item.projectCode,
      accountDate: _item.accountDate,
      files: _attachments
          .where((attachment) => attachment.file != null)
          .map((attachment) => attachment.file!)
          .toList(),
    );
    _item = _item.copyWith(id: result.data!);
    if (result.ok) {
      final item = await DaoManager.itemDao.findById(result.data!);
      EventBus.instance.emit(ItemChangedEvent(OperateType.create, item!));
    } else {
      _error = result.message;
      return false;
    }
    return true;
  }

  /// 保存账目
  Future<bool> partUpdate({
    AccountItemType? type,
    double? amount,
    String? description,
    String? categoryCode,
    String? fundId,
    String? shopCode,
    List<String>? tagCodes,
    String? projectCode,
    String? accountDate,
    List<AttachmentVO>? attachments,
  }) async {
    if (_saving) return true;

    _saving = true;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.updateItem(
        AppConfigManager.instance.userId,
        _bookMeta.id,
        _item.id,
        type: type,
        amount: amount,
        accountDate: accountDate,
        description: description,
        categoryCode: categoryCode,
        fundId: fundId,
        shopCode: shopCode,
        tagCodes: tagCodes,
        projectCode: projectCode,
        attachments: attachments,
      );
      if (result.ok) {
        final item = await DaoManager.itemDao.findById(_item.id);
        EventBus.instance.emit(ItemChangedEvent(OperateType.update, item!));
      } else {
        _error = result.message;
        return false;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  /// 更新类型
  void updateType(AccountItemType type) {
    _item = _item.copyWith(
      type: type.code,
      categoryCode: null,
    );
    _applyRules('type');
    notifyListeners();
    // 切换类型后重载对应分类
    unawaited(loadCategories(_item.accountBookId, type.code));
  }

  /// 更新金额
  void updateAmount(double amount) {
    // 根据类型或债务分类转换金额正负
    // 支出、借出(LEND)、还款(REPAYMENT)为负数
    final isNegative = _item.type == AccountItemType.expense.code ||
        _item.categoryCode == DebtType.lend.code ||
        _item.categoryCode == DebtType.borrow.operationCategory;
    final finalAmount = isNegative ? -amount.abs() : amount.abs();
    _item = _item.copyWith(amount: finalAmount);
    _applyRules('amount');
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
    _applyRules('categoryCode');
    notifyListeners();
  }

  /// 更新账户
  void updateFund(String? id, String? name) {
    _item = _item.copyWith(
      fundId: id,
      fundName: name,
    );
    _applyRules('fundId');
    notifyListeners();
  }

  /// 更新商户
  void updateShop(String? code, String? name) {
    _item = _item.copyWith(
      shopCode: code,
      shopName: name,
    );
    _applyRules('shopCode');
    notifyListeners();
  }

  /// 更新标签
  void updateTags(List<AccountSymbol> tags) {
    _item.tags = tags;
    _applyRules('tagCodes');
    notifyListeners();
  }

  /// 更新项目
  void updateProject(String? code, String? name) {
    _item = _item.copyWith(
      projectCode: code,
      projectName: name,
    );
    _applyRules('projectCode');
    notifyListeners();
  }

  /// 更新附件列表
  void updateAttachments(List<AttachmentVO> attachments) {
    _attachments = attachments;
    notifyListeners();
  }
}
