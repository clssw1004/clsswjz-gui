import 'package:flutter/material.dart';
import 'package:clsswjz_gui/database/database.dart';
import 'package:clsswjz_gui/drivers/driver_factory.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/models/common.dart';
import 'package:clsswjz_gui/models/vo/tree_node_vo.dart';

class ShopProvider extends ChangeNotifier {
  List<TreeNode<AccountShop>> _tree = [];
  List<TreeNode<AccountShop>> get tree => _tree;

  List<AccountShop> _rawList = [];
  List<AccountShop> get rawList => _rawList;

  bool _includeChildren = false;
  bool get includeChildren => _includeChildren;

  set includeChildren(bool value) {
    _includeChildren = value;
    notifyListeners();
  }

  final Set<String> _expandedIds = {};
  Set<String> get expandedIds => _expandedIds;

  final Set<String> _batchSelectedIds = {};
  Set<String> get batchSelectedIds => Set.unmodifiable(_batchSelectedIds);

  bool _isBatchMode = false;
  bool get isBatchMode => _isBatchMode;

  void enterBatchMode() {
    _isBatchMode = true;
    notifyListeners();
  }

  void exitBatchMode() {
    _isBatchMode = false;
    _batchSelectedIds.clear();
    notifyListeners();
  }

  void toggleBatchSelect(String id) {
    if (_batchSelectedIds.contains(id)) {
      _batchSelectedIds.remove(id);
    } else {
      _batchSelectedIds.add(id);
    }
    if (_batchSelectedIds.isEmpty) {
      _isBatchMode = false;
    }
    notifyListeners();
  }

    void toggleExpand(String id) {
    if (_expandedIds.contains(id)) {
      _expandedIds.remove(id);
    } else {
      _expandedIds.add(id);
    }
    notifyListeners();
  }

  String? _currentBookId;

  Future<void> loadTree(String bookId) async {
    _currentBookId = bookId;
    final result = await DriverFactory.driver.listAllShopsByBook(
      AppConfigManager.instance.userId,
      bookId,
    );
    if (result.ok && result.data != null) {
      _rawList = result.data!;
      rebuildTree();
    }
  }

  void rebuildTree() {
    _tree = TreeBuilder.buildTree(
      _rawList,
      getId: (c) => c.id,
      getParentId: (c) => c.parentId,
      getLastUsedAt: (c) => c.lastAccountItemAt,
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
    final result = await DriverFactory.driver.createShop(
      AppConfigManager.instance.userId,
      _currentBookId!,
      name: name,
      parentId: parentId,
    );
    if (result.ok) {
      await loadTree(_currentBookId!);
    }
    return result;
  }

  Future<OperateResult<void>> update(String id, {String? name, bool? isBookkeepingSelectable}) async {
    final result = await DriverFactory.driver.updateShop(
      AppConfigManager.instance.userId,
      _currentBookId!,
      id,
      name: name,
      isBookkeepingSelectable: isBookkeepingSelectable,
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
    final result = await DriverFactory.driver.deleteShops(
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
    final result = await DriverFactory.driver.updateShops(
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

    Future<void> batchMove(String? targetParentId) async {
    if (_batchSelectedIds.isEmpty) return;
    final ids = _batchSelectedIds.toList();
    final parentIds = ids.map((_) => targetParentId).toList();
    final sortOrders = List.generate(ids.length, (_) => 0);
    await batchUpdatePositions(ids: ids, parentIds: parentIds, sortOrders: sortOrders);
    exitBatchMode();
  }
}

