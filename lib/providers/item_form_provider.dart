
import 'package:flutter/material.dart';
import '../enums/business_type.dart';
import '../enums/operate_type.dart';
import '../enums/symbol_type.dart';
import '../database/database.dart';
import '../enums/account_type.dart';
import '../events/event_bus.dart';
import '../events/special/event_book.dart';
import '../manager/dao_manager.dart';
import '../models/common.dart';
import '../models/vo/book_meta.dart';
import '../models/vo/user_item_vo.dart';
import '../utils/date_util.dart';
import '../models/vo/attachment_vo.dart';
import '../manager/app_config_manager.dart';
import '../drivers/driver_factory.dart';
import '../manager/service_manager.dart';

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

  /// 附件列表
  List<AttachmentVO> _attachments = [];
  List<AttachmentVO> get attachments => _attachments;

  /// 是否正在加载数据
  bool _loading = false;
  bool get loading => _loading;

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
    _loading = true;
    notifyListeners();

    await Future.wait([
      loadCategories(),
      loadFunds(),
      loadShops(),
      loadTags(),
      loadProjects(),
    ]);

    _loading = false;
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
    await partUpdate(amount: amount);
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
  Future<void> updateTagAndSave(String? code, String? name) async {
    updateTag(code, name);
    await partUpdate(tagCode: code);
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
  Future<void> loadCategories() async {
    final result = await DriverFactory.driver.listCategoriesByBook(
        AppConfigManager.instance.userId, item.accountBookId);
    _categories = result.data ?? [];
    notifyListeners();
  }

  /// 加载账户
  Future<void> loadFunds() async {
    final result = await DriverFactory.driver
        .listFundsByBook(AppConfigManager.instance.userId, item.accountBookId);
    _funds = result.data ?? [];
    notifyListeners();
  }

  /// 加载商户
  Future<void> loadShops() async {
    final result = await DriverFactory.driver
        .listShopsByBook(AppConfigManager.instance.userId, item.accountBookId);
    _shops = result.data ?? [];
    notifyListeners();
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
      tagCode: _item.tagCode,
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
    String? tagCode,
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
        tagCode: tagCode,
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
    notifyListeners();
  }

  /// 更新金额
  void updateAmount(double amount) {
    // 根据类型转换金额正负
    final finalAmount = _item.type == AccountItemType.expense.code
        ? -amount.abs()
        : amount.abs();
    _item = _item.copyWith(amount: finalAmount);
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

  /// 更新附件列表
  void updateAttachments(List<AttachmentVO> attachments) {
    _attachments = attachments;
    notifyListeners();
  }
}
