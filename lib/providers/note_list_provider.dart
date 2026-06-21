import 'dart:async';
import 'package:flutter/material.dart';
import '../database/database.dart';
import '../drivers/driver_factory.dart';
import '../events/event_bus.dart';
import '../events/special/event_sync.dart';
import '../events/special/event_book.dart';
import '../manager/app_config_manager.dart';
import '../manager/dao_manager.dart';
import '../models/common.dart';
import '../models/vo/user_note_vo.dart';
import '../models/dto/note_filter_dto.dart';

/// 笔记列表筛选类型
enum NoteFilterType {
  /// 显示报表
  report,
}

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

  /// 筛选类型（报表等）
  NoteFilterType? _filterType;
  NoteFilterType? get filterType => _filterType;

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
    _filterType = null;
    loadNotes(true);
  }

  /// 设置筛选类型（报表等）
  Future<void> setFilterType(NoteFilterType? type) async {
    _filterType = type;
    if (type != null) _groupCodes = null;
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
      final noteType = _filterType == NoteFilterType.report ? 'REPORT' : null;
      final filter = NoteFilterDTO(
        keyword: _keyword,
        groupCodes: _groupCodes,
        noteType: noteType,
      );

      // 并行查询：账本笔记 + 全局笔记
      final results = await Future.wait([
        DriverFactory.driver.listNotesByBook(
          AppConfigManager.instance.userId,
          _currentBookId!,
          offset: (_page - 1) * _pageSize,
          limit: _pageSize,
          filter: filter,
        ),
        DaoManager.noteDao.listGlobalNotes(
          limit: _pageSize,
          filter: NoteFilterDTO(keyword: _keyword, noteType: noteType),
        ),
      ]);

      final bookResult = results[0] as OperateResult<List<UserNoteVO>>;
      final globalNotes = results[1] as List<AccountNote>;

      if (refresh) {
        _notes.clear();
      }

      if (bookResult.ok) {
        _notes.addAll(bookResult.data ?? []);
        _hasMore = (bookResult.data?.length ?? 0) >= _pageSize;
      }

      // 合并全局笔记，按更新时间排序
      for (final gn in globalNotes) {
        final vo = UserNoteVO.fromAccountNote(gn, null);
        // 去重：全局笔记在 listNotesByBook 中可能已存在（根据 noteType 区分）
        if (!_notes.any((n) => n.id == vo.id)) {
          _notes.add(vo);
        }
      }
      _notes.sort((a, b) =>
          (b.updatedAt ?? b.createdAt ?? 0)
              .compareTo((a.updatedAt ?? a.createdAt ?? 0)));
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
