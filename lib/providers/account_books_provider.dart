import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../manager/app_config_manager.dart';
import '../models/vo/account_item_vo.dart';
import '../models/vo/user_book_vo.dart';

/// 账本数据提供者
class AccountBooksProvider extends ChangeNotifier {
  /// 账本列表
  final List<UserBookVO> _books = [];

  /// 账目列表
  final List<AccountItemVO> _items = [];

  /// 选中的账本
  UserBookVO? _selectedBook;

  /// 是否正在加载账本列表
  bool _loadingBooks = false;

  /// 是否正在加载账目列表
  bool _loadingItems = false;

  /// 是否还有更多数据
  bool _hasMore = true;

  /// 当前页码
  int _page = 1;

  /// 每页数量
  static const int _pageSize = 50;

  /// 获取账本列表
  List<UserBookVO> get books => _books;

  /// 获取账目列表
  List<AccountItemVO> get items => _items;

  /// 获取选中的账本
  UserBookVO? get selectedBook => _selectedBook;

  /// 获取是否正在加载账本列表
  bool get loadingBooks => _loadingBooks;

  /// 获取是否正在加载账目列表
  bool get loadingItems => _loadingItems;

  /// 获取是否还有更多数据
  bool get hasMore => _hasMore;

  /// 初始化
  Future<void> init(String userId) async {
    await loadBooks(userId);
  }

  /// 加载账本列表
  Future<void> loadBooks(String userId) async {
    if (_loadingBooks) return;

    _loadingBooks = true;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.listBooksByUser(userId);
      if (result.ok) {
        _books.clear();
        _books.addAll(result.data ?? []);

        if (_selectedBook != null) {
          _selectedBook = _books.firstWhere(
            (book) => book.id == _selectedBook!.id,
            orElse: () => _books.first,
          );
          await loadItems();
        } else if (_books.isNotEmpty) {
          _selectedBook = _books.first;
          await loadItems();
        }
      }
    } finally {
      _loadingBooks = false;
      notifyListeners();
    }
  }

  /// 加载账目列表
  /// [refresh] 是否刷新列表，如果为 true 则清空现有数据并重置页码
  Future<void> loadItems([bool refresh = true]) async {
    if (_loadingItems || _selectedBook == null) return;
    if (!refresh && !_hasMore) return;

    _loadingItems = true;
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    notifyListeners();

    try {
      final result = await DriverFactory.driver.listItemsByBook(
        AppConfigManager.instance.userId!,
        _selectedBook!.id,
        offset: (_page - 1) * _pageSize,
        limit: _pageSize,
      );
      if (result.ok) {
        if (refresh) {
          _items.clear();
        }
        _items.addAll(result.data ?? []);
        _hasMore = (result.data?.length ?? 0) >= _pageSize;
        if (!refresh) {
          _page++;
        }
      }
    } finally {
      _loadingItems = false;
      notifyListeners();
    }
  }

  /// 加载更多账目
  Future<void> loadMore() => loadItems(false);

  /// 设置选中的账本
  Future<void> setSelectedBook(UserBookVO book) async {
    _selectedBook = book;
    await loadItems();
  }
}
