import 'package:flutter/foundation.dart';
import '../models/vo/user_book_vo.dart';
import '../services/account_book_service.dart';

/// 账本列表状态管理
class AccountBooksProvider extends ChangeNotifier {
  final AccountBookService _accountBookService = AccountBookService();

  /// 账本列表
  List<UserBookVO>? _books;
  List<UserBookVO> get books => _books ?? const [];

  /// 是否正在加载
  bool _loading = false;
  bool get loading => _loading;

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

  /// 加载账本列表
  Future<void> loadBooks(String userId) async {
    if (_loading || _disposed) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _accountBookService.getBooksByUserId(userId);

      if (_disposed) return;

      _loading = false;
      _initialized = true;
      if (result.ok) {
        _books = result.data ?? const [];
      } else {
        _error = result.message;
        _books = const [];
      }
      notifyListeners();
    } catch (e) {
      if (_disposed) return;

      _loading = false;
      _initialized = true;
      _error = e.toString();
      _books = const [];
      notifyListeners();
    }
  }

  /// 刷新账本列表
  Future<void> refresh(String userId) async {
    if (_disposed) return;
    _books = null;
    _initialized = false;
    notifyListeners();
    await loadBooks(userId);
  }
}
