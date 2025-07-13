import 'dart:async';
import 'package:flutter/material.dart';
import '../drivers/driver_factory.dart';
import '../events/event_bus.dart';
import '../events/special/event_sync.dart';
import '../events/special/event_book.dart';
import '../manager/app_config_manager.dart';
import '../models/vo/user_note_vo.dart';
import '../models/dto/note_filter_dto.dart';

class NoteListProvider extends ChangeNotifier {
  late final StreamSubscription _bookSubscription;
  late final StreamSubscription _syncSubscription;
  late final StreamSubscription _noteChangedSubscription;

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

  /// 搜索关键字
  String? _keyword;
  String? get keyword => _keyword;

  /// 分组筛选代码列表
  List<String>? _groupCodes;
  List<String>? get groupCodes => _groupCodes;

  NoteListProvider() {
    _currentBookId = AppConfigManager.instance.defaultBookId;
    _bookSubscription = EventBus.instance.on<BookChangedEvent>((event) {
      _currentBookId = event.book.id;
      loadNotes();
    });

    _syncSubscription = EventBus.instance.on<SyncCompletedEvent>((event) {
      loadNotes();
    });

    _noteChangedSubscription = EventBus.instance.on<NoteChangedEvent>((event) {
      // 保持当前的筛选状态，只刷新数据
      loadNotes(true);
    });
  }

  @override
  void dispose() {
    _bookSubscription.cancel();
    _syncSubscription.cancel();
    _noteChangedSubscription.cancel();
    super.dispose();
  }

  Future<void> setKeyword(String keyword) async {
    _keyword = keyword;
    loadNotes(true);
  }

  /// 设置分组筛选
  Future<void> setGroupCodes(List<String>? groupCodes) async {
    _groupCodes = groupCodes;
    loadNotes(true);
  }

  /// 加载笔记列表
  /// [refresh] 是否刷新列表，如果为 true 则清空现有数据并重置页码
  Future<void> loadNotes([bool refresh = true]) async {
    if (_loading || _currentBookId == null) return;
    if (!refresh && !_hasMore) return;

    _loading = true;
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }
    try {
      // 创建筛选条件
      final filter = NoteFilterDTO(_keyword, _groupCodes);
      
      final result = await DriverFactory.driver.listNotesByBook(
        AppConfigManager.instance.userId,
        _currentBookId!,
        offset: (_page - 1) * _pageSize,
        limit: _pageSize,
        filter: filter,
      );
      if (result.ok) {
        if (refresh) {
          _notes.clear();
        }
        _notes.addAll(result.data ?? []);
        _hasMore = (result.data?.length ?? 0) >= _pageSize;
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 加载更多笔记
  Future<void> loadMore() async {
    _page++;
    await loadNotes(false);
  }

  /// 删除笔记
  Future<bool> deleteNote(UserNoteVO note) async {
    final result = await DriverFactory.driver
        .deleteNote(AppConfigManager.instance.userId, _currentBookId!, note.id);
    if (result.ok) {
      _notes.remove(note);
      notifyListeners();
    }
    return result.ok;
  }
}
