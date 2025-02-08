import 'dart:async';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../events/event_book.dart';
import '../events/event_bus.dart';
import '../events/event_sync.dart';
import '../manager/app_config_manager.dart';
import '../models/vo/user_item_vo.dart';
import '../models/dto/item_filter_dto.dart';

/// 账目列表数据提供者
class ItemListProvider extends ChangeNotifier {
  late final StreamSubscription _bookSubscription;
  late final StreamSubscription _syncSubscription;

  /// 账目列表
  final List<UserItemVO> _items = [];

  /// 是否正在加载账目列表
  bool _loading = false;

  /// 是否还有更多数据
  bool _hasMore = true;

  /// 当前筛选条件
  ItemFilterDTO? _filter;

  /// 当前页码
  int _page = 1;

  /// 每页数量
  static const int _pageSize = 200;

  /// 当前账本ID
  String? _currentBookId;

  /// 是否正在加载更多
  bool _loadingMore = false;

  /// 获取账目列表
  List<UserItemVO> get items => _items;

  /// 获取是否正在加载账目列表
  bool get loading => _loading;

  /// 获取是否还有更多数据
  bool get hasMore => _hasMore;

  /// 获取当前筛选条件
  ItemFilterDTO? get filter => _filter;

  /// 获取是否正在加载更多
  bool get loadingMore => _loadingMore;

  /// 设置筛选条件
  void setFilter(ItemFilterDTO? filter) {
    _filter = filter;
    AppConfigManager.instance.setItemFilter(_filter);
    loadItems(refresh: true);
    notifyListeners();
  }

  /// 清除筛选条件
  void clearFilter() {
    _filter = null;
    loadItems(refresh: true);
    notifyListeners();
  }

  ItemListProvider() {
    _currentBookId = AppConfigManager.instance.defaultBookId;
    _filter = AppConfigManager.instance.itemFilter;
    // 监听账本切换事件
    _bookSubscription = EventBus.instance.on<BookChangedEvent>((event) {
      _currentBookId = event.book.id;
      loadItems();
    });

    // 监听同步完成事件
    _syncSubscription = EventBus.instance.on<SyncCompletedEvent>((event) {
      loadItems();
    });
  }

  /// 加载账目列表
  /// [refresh] 是否刷新列表，如果为 true 则清空现有数据并重置页码
  Future<void> loadItems({bool refresh = true}) async {
    final userId = AppConfigManager.instance.userId;
    final bookId = _currentBookId;
    if (_loading || bookId == null) return;
    if (!refresh && !_hasMore) return;

    _loading = true;
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    try {
      final result = await DriverFactory.driver.listItemsByBook(
        userId,
        bookId,
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

  /// 加载更多账目
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

  @override
  void dispose() {
    _bookSubscription.cancel();
    _syncSubscription.cancel();
    super.dispose();
  }

  /// 删除账目
  Future<bool> deleteItem(UserItemVO item) async {
    final result = await DriverFactory.driver.deleteItem(
      AppConfigManager.instance.userId,
      item.accountBookId,
      item.id,
    );
    if (result.ok) {
      _items.remove(item);
      notifyListeners();
    }
    return result.ok;
  }
}
