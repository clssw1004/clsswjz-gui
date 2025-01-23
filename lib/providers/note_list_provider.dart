import 'dart:async';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../events/event_bus.dart';
import '../events/event_sync.dart';
import '../events/event_book.dart';
import '../manager/app_config_manager.dart';
import '../manager/user_config_manager.dart';
import '../models/vo/user_note_vo.dart';

class NoteListProvider extends ChangeNotifier {
  late final StreamSubscription _subscription;
  late final StreamSubscription _syncSubscription;

  /// 笔记列表
  final List<UserNoteVO> _notes = [];
  List<UserNoteVO> get notes => _notes;

  /// 是否加载中
  bool _loading = false;
  bool get loading => _loading;

  /// 是否还有更多数据
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// 当前页码
  int _page = 1;

  /// 每页数量
  static const int _pageSize = 20;

  String? _currentBookId;

  NoteListProvider() {
    _currentBookId = AppConfigManager.instance.defaultBookId;
    _subscription = EventBus.instance.on<BookChangedEvent>((event) {
      _currentBookId = event.book.id;
      loadNotes();
    });

    _syncSubscription = EventBus.instance.on<SyncCompletedEvent>((event) {
      loadNotes();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _syncSubscription.cancel();
    super.dispose();
  }

  /// 加载笔记列表
  Future<void> loadNotes() async {
    if (_loading || _currentBookId == null) return;

    _loading = true;
    _page = 1;

    try {
      final result = await DriverFactory.driver.listNotesByBook(
        UserConfigManager.currentUserId!,
        _currentBookId!,
        offset: (_page - 1) * _pageSize,
        limit: _pageSize,
      );
      _notes.clear();
      if (result.ok && result.data != null) {
        _notes.addAll(result.data!);
        _hasMore = result.data!.length >= _pageSize;
      } else {
        _hasMore = false;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 加载更多笔记
  Future<void> loadMore() async {
    if (_loading || !_hasMore || _currentBookId == null) return;

    _loading = true;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.listNotesByBook(
        UserConfigManager.currentUserId!,
        _currentBookId!,
        offset: _page * _pageSize,
        limit: _pageSize,
      );
      if (result.ok && result.data != null && result.data!.isNotEmpty) {
        _notes.addAll(result.data!);
        _page++;
        _hasMore = result.data!.length >= _pageSize;
      } else {
        _hasMore = false;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
