import 'package:flutter/material.dart';

import '../drivers/driver_factory.dart';
import '../manager/app_config_manager.dart';
import '../manager/dao_manager.dart';
import '../models/dto/item_filter_dto.dart';
import '../models/vo/book_meta.dart';
import '../models/vo/user_item_vo.dart';

/// 通用账目列表 Provider（用于独立页面按条件展示账目）
class ItemsProvider extends ChangeNotifier {
  final BookMetaVO bookMeta;
  ItemFilterDTO? _filter;

  final List<UserItemVO> _items = [];
  bool _loading = false;
  bool _hasMore = true;
  bool _loadingMore = false;
  int _page = 1;
  static const int _pageSize = 200;

  ItemsProvider({required this.bookMeta, ItemFilterDTO? initialFilter}) {
    _filter = initialFilter;
  }

  List<UserItemVO> get items => _items;
  bool get loading => _loading;
  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;
  ItemFilterDTO? get filter => _filter;

  void setFilter(ItemFilterDTO? filter) {
    _filter = filter;
    loadItems(refresh: true);
    notifyListeners();
  }

  void setKeyword(String keyword) {
    _filter = (_filter ?? const ItemFilterDTO()).copyWith(keyword: keyword);
    loadItems(refresh: true);
    notifyListeners();
  }

  void clearFilter() {
    _filter = null;
    loadItems(refresh: true);
    notifyListeners();
  }

  Future<void> loadItems({bool refresh = true}) async {
    if (_loading) return;
    _loading = true;
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    notifyListeners();

    try {
      final result = await DriverFactory.driver.listItemsByBook(
        AppConfigManager.instance.userId,
        bookMeta.id,
        offset: (_page - 1) * _pageSize,
        limit: _pageSize,
        filter: _filter,
      );
      if (result.ok) {
        if (refresh) {
          _items.clear();
        }
        _items.addAll(result.data ?? []);
        _hasMore = (result.data?.length ?? 0) >= _pageSize;
        _page++;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    try {
      await loadItems(refresh: false);
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<bool> deleteItem(UserItemVO itemVo) async {
    final item = await DaoManager.itemDao.findById(itemVo.id);
    if (item != null) {
      final result = await DriverFactory.driver.deleteItem(
        AppConfigManager.instance.userId,
        itemVo.accountBookId,
        itemVo.id,
      );
      if (result.ok) {
        _items.remove(itemVo);
        notifyListeners();
      }
      return result.ok;
    }
    return true;
  }
}


