import 'dart:async';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../events/event_book.dart';
import '../events/event_bus.dart';
import '../events/event_sync.dart';
import '../manager/app_config_manager.dart';
import '../database/database.dart';

/// 债务列表数据提供者
class DebtListProvider extends ChangeNotifier {
  late final StreamSubscription _bookSubscription;
  late final StreamSubscription _syncSubscription;

  /// 债务列表
  final List<AccountDebt> _debts = [];

  /// 是否正在加载债务列表
  bool _loading = false;

  /// 是否还有更多数据
  bool _hasMore = true;

  /// 当前页码
  int _page = 1;

  /// 每页数量
  static const int _pageSize = 10;

  /// 当前账本ID
  String? _currentBookId;

  /// 是否正在加载更多
  bool _loadingMore = false;

  /// 获取债务列表
  List<AccountDebt> get debts => _debts;

  /// 获取是否正在加载债务列表
  bool get loading => _loading;

  /// 获取是否还有更多数据
  bool get hasMore => _hasMore;

  /// 获取是否正在加载更多
  bool get loadingMore => _loadingMore;

  DebtListProvider() {
    _currentBookId = AppConfigManager.instance.defaultBookId;
    // 监听账本切换事件
    _bookSubscription = EventBus.instance.on<BookChangedEvent>((event) {
      _currentBookId = event.book.id;
      loadDebts();
    });

    // 监听同步完成事件
    _syncSubscription = EventBus.instance.on<SyncCompletedEvent>((event) {
      loadDebts();
    });
  }

  /// 加载债务列表（分页）
  Future<void> loadDebts({bool refresh = true}) async {
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
      final result = await DriverFactory.driver.listDebtsByBook(
        userId,
        bookId,
        offset: (_page - 1) * _pageSize,
        limit: _pageSize,
      );
      if (result.ok) {
        if (refresh) {
          _debts.clear();
        }
        _debts.addAll(result.data ?? []);
        _hasMore = (result.data?.length ?? 0) >= _pageSize;
        _page++;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 加载更多债务
  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;

    _loadingMore = true;
    notifyListeners();

    try {
      await loadDebts(refresh: false);
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  /// 删除债务
  Future<bool> deleteDebt(AccountDebt debt) async {
    final result = await DriverFactory.driver.deleteDebt(
      AppConfigManager.instance.userId,
      debt.accountBookId,
      debt.id,
    );
    if (result.ok) {
      _debts.remove(debt);
      notifyListeners();
    }
    return result.ok;
  }

  @override
  void dispose() {
    _bookSubscription.cancel();
    _syncSubscription.cancel();
    super.dispose();
  }
} 