import 'package:flutter/material.dart';
import 'package:clsswjz_gui/database/database.dart';
import 'package:clsswjz_gui/drivers/driver_factory.dart';
import 'package:clsswjz_gui/enums/account_type.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/models/common.dart';
import 'package:clsswjz_gui/models/vo/tree_node_vo.dart';

class CategoryProvider extends ChangeNotifier {
  List<TreeNode<AccountCategory>> _tree = [];
  List<TreeNode<AccountCategory>> get tree => _tree;

  List<AccountCategory> _rawList = [];
  List<AccountCategory> get rawList => _rawList;

  String _selectedType = AccountItemType.expense.code;
  String get selectedType => _selectedType;

  set selectedType(String value) {
    if (_selectedType != value) {
      _selectedType = value;
      notifyListeners();
    }
  }

  bool _includeChildren = false;
  bool get includeChildren => _includeChildren;

  set includeChildren(bool value) {
    _includeChildren = value;
    notifyListeners();
  }

  final Set<String> _expandedIds = {};
  Set<String> get expandedIds => _expandedIds;

  void toggleExpand(String id) {
    if (_expandedIds.contains(id)) {
      _expandedIds.remove(id);
    } else {
      _expandedIds.add(id);
    }
    notifyListeners();
  }

  String? _currentBookId;

  Future<void> loadTree(String bookId, {String? categoryType}) async {
    _currentBookId = bookId;
    final result = await DriverFactory.driver.listAllCategoriesByBook(
      AppConfigManager.instance.userId,
      bookId,
      categoryType: categoryType ?? _selectedType,
    );
    if (result.ok && result.data != null) {
      _rawList = result.data!;
      _rawList.sort((a, b) {
        final aT = a.lastAccountItemAt;
        final bT = b.lastAccountItemAt;
        if (aT == null && bT == null) return 0;
        if (aT == null) return 1;
        if (bT == null) return -1;
        return bT.compareTo(aT);
      });
      rebuildTree();
    }
  }

  void rebuildTree() {
    _tree = TreeBuilder.buildTree(
      _rawList,
      getId: (c) => c.id,
      getParentId: (c) => c.parentId,
    );
    notifyListeners();
  }

  List<String> expandCodes(String code) {
    return TreeBuilder.getDescendantIds(
      _tree,
      code,
      idGetter: (c) => c.code,
    );
  }

  Future<OperateResult<String>> create({
    required String name,
    String? parentId,
  }) async {
    final result = await DriverFactory.driver.createCategory(
      AppConfigManager.instance.userId,
      _currentBookId!,
      name: name,
      categoryType: _selectedType,
      parentId: parentId,
    );
    if (result.ok) {
      await loadTree(_currentBookId!);
    }
    return result;
  }

  Future<OperateResult<void>> update(String id, {String? name}) async {
    final result = await DriverFactory.driver.updateCategory(
      AppConfigManager.instance.userId,
      _currentBookId!,
      id,
      name: name,
    );
    if (result.ok) {
      await loadTree(_currentBookId!);
    }
    return result;
  }

  Future<OperateResult<void>> delete(String id) async {
    final allIds = TreeBuilder.getDescendantIds(
      _tree,
      id,
      idGetter: (c) => c.id,
    );
    final result = await DriverFactory.driver.deleteCategories(
      AppConfigManager.instance.userId,
      _currentBookId!,
      allIds,
    );
    if (result.ok) {
      await loadTree(_currentBookId!);
    }
    return result;
  }

  Future<OperateResult<void>> batchUpdatePositions({
    required List<String> ids,
    required List<String?> parentIds,
    required List<int> sortOrders,
  }) async {
    final result = await DriverFactory.driver.updateCategories(
      AppConfigManager.instance.userId,
      _currentBookId!,
      ids: ids,
      parentIds: parentIds,
      sortOrders: sortOrders,
    );
    if (result.ok) {
      await loadTree(_currentBookId!);
    }
    return result;
  }
}
