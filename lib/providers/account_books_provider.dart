import 'package:clsswjz/drivers/driver_factory.dart';
import 'package:flutter/foundation.dart';
import '../models/vo/user_book_vo.dart';

/// 账本列表状态管理
class AccountBooksProvider extends ChangeNotifier {
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

    try {
      _loading = true;
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

      _loading = false;
      notifyListeners();
    } catch (e) {
      if (_disposed) return;

      _loading = false;
      _error = e.toString();
      _books = const [];
      notifyListeners();
    }
  }
}
