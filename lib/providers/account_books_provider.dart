import 'package:flutter/foundation.dart';
import '../models/vo/user_book_vo.dart';
import '../services/account_book_service.dart';

/// 账本列表状态管理
class AccountBooksProvider extends ChangeNotifier {
  final AccountBookService _accountBookService = AccountBookService();

  /// 账本列表
  List<UserBookVO>? _books;
  List<UserBookVO> get books => _books ?? [];

  /// 是否正在加载
  bool _loading = false;
  bool get loading => _loading;

  /// 错误信息
  String? _error;
  String? get error => _error;

  /// 加载账本列表
  Future<void> loadBooks(String userId) async {
    if (_loading) return;

    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _accountBookService.getBooksByUserId(userId);

    _loading = false;
    if (result.ok) {
      _books = result.data;
    } else {
      _error = result.message;
    }
    notifyListeners();
  }

  /// 刷新账本列表
  Future<void> refresh(String userId) async {
    _books = null;
    await loadBooks(userId);
  }
}
