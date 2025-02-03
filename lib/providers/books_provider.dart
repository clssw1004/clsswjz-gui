import 'dart:async';
import 'package:clsswjz/manager/service_manager.dart';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../events/event_book.dart';
import '../manager/app_config_manager.dart';
import '../models/vo/book_meta.dart';
import '../models/vo/user_book_vo.dart';
import '../events/event_bus.dart';
import '../events/event_sync.dart';

/// 账本数据提供者
class BooksProvider extends ChangeNotifier {
  BooksProvider() {
    // 监听同步完成事件
    _subscription = EventBus.instance.on<SyncCompletedEvent>((event) async {
      // 重置状态
      _loading = false;
      notifyListeners();

      // 刷新账本列表
      await loadBooks(AppConfigManager.instance.userId);
    });
  }

  late final StreamSubscription _subscription;

  /// 账本列表
  final List<UserBookVO> _books = [];

  /// 选中的账本
  BookMetaVO? _selectedBook;

  /// 是否正在加载账本列表
  bool _loading = false;

  /// 获取账本列表
  List<UserBookVO> get books => _books;

  /// 获取选中的账本
  BookMetaVO? get selectedBook => _selectedBook;

  /// 获取是否正在加载账本列表
  bool get loading => _loading;

  /// 初始化
  Future<void> init(String userId) async {
    await loadBooks(userId);
  }

  /// 加载账本列表
  Future<void> loadBooks(String userId) async {
    if (_loading) return;

    _loading = true;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.listBooksByUser(userId);
      if (result.ok) {
        _books.clear();
        _selectedBook = null;
        notifyListeners();

        _books.addAll(result.data ?? []);

        // 获取默认账本ID
        final defaultBookId = AppConfigManager.instance.defaultBookId;
        UserBookVO? selectedBook;
        if (defaultBookId != null && _books.isNotEmpty) {
          // 尝试找到默认账本
          selectedBook = _books.firstWhere(
            (book) => book.id == defaultBookId,
            orElse: () => _books.first,
          );
        } else if (_books.isNotEmpty) {
          selectedBook = _books.first;
        }
        // 如果有选中的账本，发送切换事件
        if (selectedBook != null) {
          if (defaultBookId == null) {
            AppConfigManager.instance.setDefaultBookId(selectedBook.id);
          }
          _selectedBook =
              await ServiceManager.accountBookService.toBookMeta(selectedBook);
          EventBus.instance.emit(BookChangedEvent(_selectedBook!));
        }
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 设置选中的账本
  void setSelectedBook(UserBookVO book) async {
    _selectedBook = await ServiceManager.accountBookService.toBookMeta(book);
    AppConfigManager.instance.setDefaultBookId(book.id);
    EventBus.instance.emit(BookChangedEvent(book));
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
