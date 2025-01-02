import 'package:flutter/foundation.dart';
import '../drivers/driver_factory.dart';
import '../manager/app_config_manager.dart';
import '../models/vo/account_item_vo.dart';
import '../models/vo/user_book_vo.dart';
import '../services/account_item_service.dart';

/// 账本状态管理
class AccountBooksProvider extends ChangeNotifier {
  /// 账目服务
  final _accountItemService = AccountItemService();

  /// 账本列表
  List<UserBookVO>? _books;
  List<UserBookVO> get books => _books ?? const [];

  /// 当前选中的账本
  UserBookVO? _selectedBook;
  UserBookVO? get selectedBook => _selectedBook;

  /// 当前账本的账目列表
  List<AccountItemVO>? _items;
  List<AccountItemVO>? get items => _items;

  /// 是否正在加载账本列表
  bool _loadingBooks = false;
  bool get loadingBooks => _loadingBooks;

  /// 是否正在加载账目列表
  bool _loadingItems = false;
  bool get loadingItems => _loadingItems;

  /// 错误信息
  String? _error;
  String? get error => _error;

  /// 是否已销毁
  bool _disposed = false;

  /// 是否已初始化
  bool _initialized = false;
  bool get initialized => _initialized;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  /// 初始化
  Future<void> init(String userId) async {
    if (_disposed || _initialized) return;

    try {
      _loadingBooks = true;
      _error = null;
      notifyListeners();

      final result = await DriverFactory.bookDataDriver.listBooksByUser(userId);

      if (_disposed) return;

      if (result.ok) {
        _books = result.data ?? const [];
        _initialized = true;

        // 如果有账本，选择默认账本
        if (_books!.isNotEmpty) {
          final defaultBookId = AppConfigManager.instance.defaultBookId;
          if (defaultBookId != null) {
            final defaultBook = _books!.firstWhere(
              (book) => book.id == defaultBookId,
              orElse: () => _books!.first,
            );
            await setSelectedBook(defaultBook);
          }
        }
      } else {
        _error = result.message;
        _books = const [];
      }

      _loadingBooks = false;
      notifyListeners();
    } catch (e) {
      if (_disposed) return;

      _loadingBooks = false;
      _initialized = true;
      _error = e.toString();
      _books = const [];
      notifyListeners();
    }
  }

  /// 加载账本列表
  Future<void> loadBooks(String userId) async {
    if (_loadingBooks || _disposed) return;

    try {
      _loadingBooks = true;
      _error = null;
      notifyListeners();

      final result = await DriverFactory.bookDataDriver.listBooksByUser(userId);

      if (_disposed) return;

      if (result.ok) {
        _books = result.data ?? const [];
      } else {
        _error = result.message;
        _books = const [];
      }

      _loadingBooks = false;
      notifyListeners();
    } catch (e) {
      if (_disposed) return;

      _loadingBooks = false;
      _error = e.toString();
      _books = const [];
      notifyListeners();
    }
  }

  /// 设置当前账本
  Future<void> setSelectedBook(UserBookVO? book) async {
    if (_selectedBook?.id == book?.id) {
      return;
    }

    _selectedBook = book;
    _items = null;
    notifyListeners();

    if (book != null) {
      await AppConfigManager.instance.setDefaultBookId(book.id);
      await loadItems();
    }
  }

  /// 加载账目列表
  Future<void> loadItems() async {
    if (_selectedBook == null || _loadingItems || _disposed) {
      return;
    }

    try {
      _loadingItems = true;
      notifyListeners();

      final result =
          await _accountItemService.getByAccountBookId(_selectedBook!.id);

      if (_disposed) return;

      if (result.ok) {
        _items = result.data;
      } else {
        _error = result.message;
        _items = null;
      }

      _loadingItems = false;
      notifyListeners();
    } catch (e) {
      if (_disposed) return;

      _loadingItems = false;
      _error = e.toString();
      _items = null;
      notifyListeners();
    }
  }

  /// 刷新当前数据
  Future<void> refresh(String userId) async {
    await loadBooks(userId);
    if (_selectedBook != null) {
      await loadItems();
    }
  }
}
