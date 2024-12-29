import 'package:flutter/foundation.dart';
import '../manager/app_config_manager.dart';
import '../models/vo/account_item_vo.dart';
import '../models/vo/user_book_vo.dart';
import '../services/account_item_service.dart';
import '../services/account_book_service.dart';

/// 账目列表状态管理
class AccountItemsProvider with ChangeNotifier {
  /// 账目服务
  final _accountItemService = AccountItemService();
  final _accountBookService = AccountBookService();

  /// 当前选中的账本
  UserBookVO? _selectedBook;
  UserBookVO? get selectedBook => _selectedBook;

  /// 账目列表
  List<AccountItemVO>? _items;
  List<AccountItemVO>? get items => _items;

  /// 是否正在加载
  bool _loading = false;
  bool get loading => _loading;

  /// 初始化
  Future<void> init(String userId) async {
    final result = await _accountBookService.getBooksByUserId(userId);
    if (result.ok && result.data != null && result.data!.isNotEmpty) {
      final defaultBookId = AppConfigManager.instance.defaultBookId;
      await setSelectedBook(
          result.data!.firstWhere((element) => element.id == defaultBookId));
    }
  }

  /// 设置当前账本
  Future<void> setSelectedBook(UserBookVO? book) async {
    if (_selectedBook?.id == book?.id) {
      return;
    }
    _selectedBook = book;
    notifyListeners();

    if (book != null) {
      await loadItems();
    } else {
      _items = null;
      notifyListeners();
    }
  }

  /// 加载账目列表
  Future<void> loadItems() async {
    if (_selectedBook == null) {
      return;
    }

    _loading = true;
    notifyListeners();

    final result = await _accountItemService.getByAccountBookId(
      _selectedBook!.id,
    );

    _loading = false;
    if (result.ok) {
      _items = result.data;
    } else {
      _items = null;
    }
    notifyListeners();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadItems();
  }
}
