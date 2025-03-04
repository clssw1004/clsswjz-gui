import 'dart:async';
import 'package:clsswjz/manager/service_manager.dart';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../events/special/event_book.dart';
import '../events/special/event_item.dart';
import '../manager/app_config_manager.dart';
import '../models/vo/book_meta.dart';
import '../models/vo/user_book_vo.dart';
import '../events/event_bus.dart';
import '../events/special/event_sync.dart';

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

    // 监听账目变更事件，更新统计信息
    _itemChangedSubscription =
        EventBus.instance.on<ItemChangedEvent>((event) async {
      // 如果当前选中的账本与变更的账目所属账本一致，则更新统计信息
      if (_selectedBook != null &&
          event.item.accountBookId == _selectedBook!.id) {
        // 统计信息已移动到StatisticsProvider中，这里不再处理
      }
    });
  }

  late final StreamSubscription _subscription;
  late final StreamSubscription _itemChangedSubscription;

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
          setSelectedBook(selectedBook);
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
    notifyListeners();
  }

  /// 删除账本
  Future<bool> deleteBook(String bookId) async {
    try {
      final result = await DriverFactory.driver.deleteBook(
        AppConfigManager.instance.userId,
        bookId,
      );

      if (result.ok) {
        // 如果删除的是当前选中的账本，清除选中状态
        if (_selectedBook?.id == bookId) {
          AppConfigManager.instance.setDefaultBookId(null);
          _selectedBook = null;
        }
        // 重新加载账本列表
        await loadBooks(AppConfigManager.instance.userId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    _itemChangedSubscription.cancel();
    super.dispose();
  }
}
