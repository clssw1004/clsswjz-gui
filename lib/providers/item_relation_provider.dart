import 'package:flutter/material.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../models/common.dart';
import '../../models/vo/item_relation_vo.dart';

class ItemRelationProvider extends ChangeNotifier {
  final Map<String, List<ItemRelationVO>> _relationCache = {};
  final Map<String, List<String>> _reverseCache = {};

  String _cacheKey(String code, String id) => '$code:$id';

  /// 查询某笔账目的所有关联
  Future<List<ItemRelationVO>> getItemRelations(String itemId) async {
    if (_relationCache.containsKey(itemId)) {
      return _relationCache[itemId]!;
    }
    final result = await DriverFactory.driver.getItemRelations(
      AppConfigManager.instance.userId,
      itemId: itemId,
    );
    if (result.ok) {
      _relationCache[itemId] = result.data ?? [];
      return _relationCache[itemId]!;
    }
    return [];
  }

  /// 查询某业务记录关联的账目ID列表
  Future<List<String>> getRelatedItemIds(
    String relationCode,
    String relationId,
  ) async {
    final key = _cacheKey(relationCode, relationId);
    if (_reverseCache.containsKey(key)) {
      return _reverseCache[key]!;
    }
    final result = await DriverFactory.driver.getRelatedItemIds(
      AppConfigManager.instance.userId,
      relationCode: relationCode,
      relationId: relationId,
    );
    if (result.ok) {
      final ids = result.data ?? [];
      _reverseCache[key] = ids;
      return ids;
    }
    return [];
  }

  /// 创建关联
  Future<OperateResult<void>> createRelation({
    required String itemId,
    required String accountBookId,
    required String relationCode,
    required String relationId,
  }) async {
    final result = await DriverFactory.driver.createItemRelation(
      AppConfigManager.instance.userId,
      itemId: itemId,
      accountBookId: accountBookId,
      relationCode: relationCode,
      relationId: relationId,
    );
    if (result.ok) {
      _relationCache.remove(itemId);
      _reverseCache.remove(_cacheKey(relationCode, relationId));
      notifyListeners();
    }
    return result;
  }

  /// 删除关联
  Future<OperateResult<void>> deleteRelation({
    required String relationId,
    required String itemId,
    required String relationCode,
    required String sourceId,
  }) async {
    final result = await DriverFactory.driver.deleteItemRelation(
      AppConfigManager.instance.userId,
      relationId,
    );
    if (result.ok) {
      _relationCache.remove(itemId);
      _reverseCache.remove(_cacheKey(relationCode, sourceId));
      notifyListeners();
    }
    return result;
  }

  /// 清除指定账目的缓存
  void clearCacheForItem(String itemId) {
    _relationCache.remove(itemId);
  }

  /// 清除所有缓存
  void clearAllCache() {
    _relationCache.clear();
    _reverseCache.clear();
  }
}
